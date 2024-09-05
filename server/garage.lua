ESX.RegisterServerCallback('mgd_gangbuilder:storeVehicle', function(source, cb, vehicleProps, vehiclePlate, modelLabel)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name

    ServerGangsData[gangName].data.garage[vehiclePlate] = vehicleProps  
    GlobalState['mgd_gangbuilder'] = ServerGangsData

    MySQL.update('UPDATE `mgdgangbuilder_gangs` SET `data` = @data WHERE `name` = @name', {
        ['@data'] = json.encode(GlobalState['mgd_gangbuilder'][gangName].data),
        ['@name'] = gangName
    }, function(rowsChange)
        if rowsChange then
            TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                author = _src,
                action = "gangStoreVehicle",
                data = {
                    {fieldName = "Gang", value = gangName},
                    {fieldName = "Plaque", value = vehiclePlate},
                    {fieldName = "Modèle", value = modelLabel}
                }
            })

            cb(true, _('success_storeVehicle', modelLabel, vehiclePlate), 'success')
        else
            cb(false, _('error_storeVehicle'), 'error')
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:exitVehicle', function(source, cb, vehiclePlate)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name

    if ServerGangsData[gangName].data.garage[vehiclePlate] then
        ServerGangsData[gangName].data.garage[vehiclePlate] = nil  
        GlobalState['mgd_gangbuilder'] = ServerGangsData

        MySQL.update('UPDATE `mgdgangbuilder_gangs` SET `data` = @data WHERE `name` = @name', {
            ['@data'] = json.encode(GlobalState['mgd_gangbuilder'][gangName].data),
            ['@name'] = gangName
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
                cb(true, _('success_exitVehicle'), 'success')
            else
                cb(false, _('error_exitVehicle'), 'error')
            end
        end)
    else
        cb(false, _('error_exitVehicle'), 'error')
    end
end)