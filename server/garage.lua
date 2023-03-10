ESX.RegisterServerCallback('mgd_gangbuilder:storeVehicle', function(source, cb, gangName, vehicleProps, vehiclePlate)
    local _src = source

    ServerGangsData[gangName].data.garage[vehiclePlate] = vehicleProps
    MySQL.update('UPDATE `mgdgangbuilder_gangs` SET `data` = ? WHERE `name` = ?', {
        json.encode(ServerGangsData[gangName].data),
        gangName
    }, function(rowsChange)
        if rowsChange then
            TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                author = _src,
                action = "gangStoreVehicle",
                data = {
                    {fieldName = "Gang", value = gangName},
                    {fieldName = "Plaque", value = vehiclePlate}
                }
            })
            TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
            cb(true, _('success_storeVehicle'))
        else
            cb(false, _('error_storeVehicle'))
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:exitVehicle', function(source, cb, gangName, vehiclePlate)
    local _src = source
    if ServerGangsData[gangName].data.garage[vehiclePlate] then
        ServerGangsData[gangName].data.garage[vehiclePlate] = nil
        MySQL.update('UPDATE `mgdgangbuilder_gangs` SET `data` = ? WHERE `name` = ?', {
            json.encode(ServerGangsData[gangName].data),
            gangName
        }, function(rowsChange)
            if rowsChange then
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangExitVehicle",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "Plaque", value = vehiclePlate}
                    }
                })
                TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                cb(true, _('success_exitVehicle'))
            else
                cb(false, _('error_exitVehicle'))
            end
        end)
    else
        cb(false, _('error_exitVehicle'))
    end
end)