RegisterNetEvent('mgd_gangbuilder:dLogs')
AddEventHandler('mgd_gangbuilder:dLogs', function(logType, data)
    if Config.discordLogs then
        local webhook = Config.discordWebhooks[logType]
        local colors = {
            adminCreate = 0x429c06,
            adminDelete = 0x9c0606,
            adminEdit = 0x9c6d06
        }
        local author = ESX.GetPlayerFromId(data.author)
        local authorIdentity = author.get('firstName') .." ".. author.get('lastName') 
        local fields = {}
        for k,v in pairs(data.data) do
            table.insert(fields, {
                ["name"] = v.fieldName,
                ["value"] = v.value,
                ["inline"] = true
            })
        end
        local embeds = {
            {
                ["type"] = "rich",
                ["color"] = colors[data.action],
                ["title"] = "**" .. authorIdentity .. "** *(ID ".. data.author .." - " .. author.identifier .. ")* " .. _('wording_'.. data.action ..''),
                ["fields"] = fields,
                ["footer"] = {
                    ["text"] = "Le " .. os.date("%d/%m/%Y à %H:%M:%S")
                }
            }
        }

        if webhook and embeds then
            PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = embeds}), { ['Content-Type'] = 'application/json' })
        end
    end
end)