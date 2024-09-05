
# MG Développement - Gang Builder
🔫 A Gang Builder for FiveM doesn't need a reboot to update ! Uses a custom data named 'gang' in the player data to avoid using job or job2

## V2.0

- Simplified installation
- Optimization
- Clean code
- Use ox_lib to manage markers
- Use ox_lib to notify
- Add a check at resource start for the presence of the default gang 'none'
- Add 'en' locale
- Add a configuration to the garage to choose between unique vehicles or spawn by a list
- Invite member is now with ox_target
- Add possibility to fire a member with ox_target
- Add ox_inventory support
- Remove command 'myid'

## HOW TO INSTALL
- Put 'mgd_gangbuilder' in your resources folder
- Add 'ensure mgd_gangbuilder' in your server.cfg
- Import 'mgd_gangbuilder.sql' in your database
- In your 'es_extended' (server/classes/player.lua) :
    - add in beginning of function 'CreateExtendedPlayer', below `local targetOverrides`
        ```lua
        local targetMoreFunctions = Core.MorePlayerFunction['MGD_GangBuilder'] or {}
        ```
    - add in function 'CreateExtendedPlayer', below `self.admin = Core.IsPlayerAdmin(playerId)` :
        ```lua
        self.gang = {}
        ```
    - add at the end of function 'CreateExtendedPlayer', above `return self` :
        ```lua
        for fnName, fn in pairs(targetMoreFunctions) do
            self[fnName] = fn(self)
        end
        ```
- In your 'es_extended' (server/classes/overrides), add in the file 'mgd_gangbuilder.lua'

If you don't use ox_inventory :
- In your 'esx_datastore' (server/main.lua), add :
```lua
AddEventHandler('mgd_gangbuilderXesx_datastore:createDataStore', function(name, data)
	SharedDataStores[name] = CreateDataStore(name, nil, json.decode(data))
end)

AddEventHandler('mgd_gangbuilderXesx_datastore:deleteDataStore', function(name)
	SharedDataStores[name] = nil
end)
```

## VIDEO PREVIEW
[![VIDEO PREVIEW](https://img.youtube.com/vi/jgYIVFZsLFE/0.jpg)](https://www.youtube.com/watch?v=jgYIVFZsLFE)