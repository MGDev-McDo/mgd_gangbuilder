-- IF NEED HELP COME ON DISCORD


-------------------------------------------------------------------------------------------------------------------------------
--|| FILE : esx_datastore > server > main.lua

AddEventHandler('mgd_gangbuilderXesx_datastore:createDataStore', function(name, data)
	SharedDataStores[name] = CreateDataStore(name, nil, json.decode(data))
end)

AddEventHandler('mgd_gangbuilderXesx_datastore:deleteDataStore', function(name)
	SharedDataStores[name] = nil
end)