ESX.RegisterServerCallback('mgd_gangbuilder:createGang', function(source, cb, CreateGangData)
    local _src = source
    if ServerGangsData[CreateGangData.name] ~= nil then
        cb(false, _('server_gangNameAlreadyExist', CreateGangData.name))
    else
        local data = { maxRanks = CreateGangData.maxRanks, coords = CreateGangData.coords, garage = {} }
        MySQL.insert('INSERT INTO `mgdgangbuilder_gangs` (`name`, `label`, `data`) VALUES (?, ?, ?)', {
            CreateGangData.name,
            CreateGangData.label,
            json.encode(data)
        }, function(rowsChange)
            if rowsChange then
                MySQL.insert('INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES (?, ?, ?)', {
                    "gang_" .. CreateGangData.name,
                    CreateGangData.label,
                    1
                })
                MySQL.insert('INSERT INTO `datastore_data` (`name`, `data`) VALUES (?, ?)', {
                    "gang_" .. CreateGangData.name,
                    json.encode({weapons={}, items={}, accounts={}})
                })

                TriggerEvent('mgd_gangbuilderXesx_datastore:createDataStore', "gang_" .. CreateGangData.name, json.encode({weapons={}, items={}, accounts={}}))

                MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (?, ?, ?, ?, ?), (?, ?, ?, ?, ?)', {
                    CreateGangData.name,
                    CreateGangData.maxRanks - 1,
                    "boss",
                    "Chef",
                    json.encode({
                        perm_inventory_view = true,
                        perm_inventory_put = true,
                        perm_inventory_take = true,
                        perm_garage_view = true,
                        perm_garage_exit = true,
                        perm_garage_store = true,
                        perm_boss_menu = true,
                        perm_manage_members = true,
                        perm_manage_permissions = true,
                        perm_manage_ranks  = true
                    }),
                    CreateGangData.name,
                    0,
                    "zero",
                    "Default",
                    json.encode({
                        perm_inventory_view = false,
                        perm_inventory_put = false,
                        perm_inventory_take = false,
                        perm_garage_view = false,
                        perm_garage_exit = false,
                        perm_garage_store = false,
                        perm_boss_menu = false,
                        perm_manage_members = false,
                        perm_manage_permissions = false,
                        perm_manage_ranks  = false
                    })
                }, function(rowsChangeGrades)
                    if rowsChangeGrades then
                        ServerGangsData[CreateGangData.name] = {
                            name = CreateGangData.name,
                            label = CreateGangData.label,
                            data = json.decode(json.encode(data)),
                            grades = {
                                zero = {
                                    grade = 0,
                                    name = "zero",
                                    label = "Default",
                                    permissions = {
                                        perm_inventory_view = false,
                                        perm_inventory_put = false,
                                        perm_inventory_take = false,
                                        perm_garage_view = false,
                                        perm_garage_exit = false,
                                        perm_garage_store = false,
                                        perm_boss_menu = false,
                                        perm_manage_members = false,
                                        perm_manage_permissions = false,
                                        perm_manage_ranks  = false
                                    }
                                },
                                boss = {
                                    grade = CreateGangData.maxRanks - 1,
                                    name = "boss",
                                    label = "Chef",
                                    permissions = {
                                        perm_inventory_view = true,
                                        perm_inventory_put = true,
                                        perm_inventory_take = true,
                                        perm_garage_view = true,
                                        perm_garage_exit = true,
                                        perm_garage_store = true,
                                        perm_boss_menu = true,
                                        perm_manage_members = true,
                                        perm_manage_permissions = true,
                                        perm_manage_ranks  = true
                                    }
                                }
                            }
                        }
                        TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                            author = _src,
                            action = "adminCreate",
                            data = {
                                {fieldName = _('createMenu_name'), value = CreateGangData.name},
                                {fieldName = _('createMenu_label'), value = CreateGangData.label},
                                {fieldName = _('createMenu_maxRanks'), value = CreateGangData.maxRanks}
                            }
                        })
                        TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                        cb(true, _('server_success_createGang', CreateGangData.label, CreateGangData.name, CreateGangData.maxRanks))
                    else
                        cb(true, _('server_error_createGangGrades'))
                    end
                end)
            else
                cb(false, _('server_error_createGang'))
            end
        end)
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:deleteGang', function(source, cb, gangName)
    local _src = source
    MySQL.update('DELETE FROM `mgdgangbuilder_gangs` WHERE `name` = ?', {
        gangName
    }, function(deleteGangs)
        if deleteGangs then
            MySQL.update('DELETE FROM `datastore` WHERE `name` = ?', {
                "gang_"..gangName
            })
            MySQL.update('DELETE FROM `datastore_data` WHERE `name` = ?', {
                "gang_"..gangName
            })
            TriggerEvent('mgd_gangbuilderXesx_datastore:deleteDataStore', "gang_" .. gangName)
            
            MySQL.update('DELETE FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = ?', {
                gangName
            }, function(deleteGangsGrades)
                if deleteGangsGrades then
                    TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                        author = _src,
                        action = "adminDelete",
                        data = {
                            {fieldName = _('createMenu_name'), value = gangName},
                            {fieldName = _('createMenu_label'), value = ServerGangsData[gangName].label}
                        }
                    })
                    cb(true, _('server_success_deleteGang', ServerGangsData[gangName].label, gangName))
                    ServerGangsData[gangName] = nil
                    TriggerClientEvent('mgd_gangbuilder:deleteCheckToNone', -1, gangName)
                    TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                else
                    cb(true, _('server_error_deleteGangGrades'))
                end
            end)
        else
            cb(false, _('server_error_deleteGang'))
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:editGang', function(source, cb, newGangData, oldGangData)
    local _src = source
    local DiscordLogs = {}
    local DataCompared = {
        name = oldGangData.name,
        label = (newGangData.label or oldGangData.label),
        data = {
            maxRanks = (newGangData.maxRanks or oldGangData.data.maxRanks),
            coords = {
                inventory = (newGangData.coords.inventory or oldGangData.data.coords.inventory),
                garageMenu = (newGangData.coords.garageMenu or oldGangData.data.coords.garageMenu),
                garageSpawn = (newGangData.coords.garageSpawn or oldGangData.data.coords.garageSpawn),
                garageStore = (newGangData.coords.garageStore or oldGangData.data.coords.garageStore),
                boss = (newGangData.coords.boss or oldGangData.data.coords.boss)
            }
        },
        grades = oldGangData.grades
    }

    DataCompared.data = json.decode(json.encode(DataCompared.data))

    if Config.discordLogs then
        table.insert(DiscordLogs, {fieldName = _('createMenu_name'), value = oldGangData.name})
        if newGangData.label then table.insert(DiscordLogs, {fieldName = _('createMenu_label'), value = oldGangData.label .." → ".. newGangData.label}) end
        if newGangData.maxRanks then table.insert(DiscordLogs, {fieldName = _('createMenu_maxRanks'), value = oldGangData.data.maxRanks .." → ".. newGangData.maxRanks}) end
        if newGangData.coords.inventory then table.insert(DiscordLogs, {fieldName = _('createMenu_coords_inventory'), value = json.encode(newGangData.coords.inventory)}) end
        if newGangData.coords.garageMenu then table.insert(DiscordLogs, {fieldName = _('createMenu_coords_garage'), value = json.encode(newGangData.coords.garageMenu)}) end
        if newGangData.coords.garageSpawn then table.insert(DiscordLogs, {fieldName = _('createMenu_coords_garageSpawn'), value = json.encode(newGangData.coords.garageSpawn)}) end
        if newGangData.coords.garageStore then table.insert(DiscordLogs, {fieldName = _('createMenu_coords_garageStore'), value = json.encode(newGangData.coords.garageStore)}) end
        if newGangData.coords.boss then table.insert(DiscordLogs, {fieldName = _('createMenu_coords_boss'), value = json.encode(newGangData.coords.boss)}) end
    end

    MySQL.update('UPDATE `mgdgangbuilder_gangs` SET `label` = ?, `data` = ? WHERE `name` = ?', {
        DataCompared.label,
        json.encode(DataCompared.data),
        DataCompared.name
    }, function(rowsChange)
        if rowsChange then
            if newGangData.maxRanks and newGangData.maxRanks ~= oldGangData.data.maxRanks then
                if DataCompared.data.maxRanks > oldGangData.data.maxRanks then
                    MySQL.update('UPDATE `mgdgangbuilder_gangs_grades` SET `grade` = ? WHERE `gang_name` = ? AND `name` = ?', {
                        DataCompared.data.maxRanks - 1,
                        DataCompared.name,
                        "boss"
                    }, function(rowsChangeGrades)
                        if rowsChangeGrades then
                            TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                                author = _src,
                                action = "adminEdit",
                                data = DiscordLogs
                            })
                            DataCompared.grades["boss"].grade = DataCompared.data.maxRanks - 1
                            ServerGangsData[DataCompared.name] = DataCompared
                            TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                            cb(true, _('server_success_editGang', DataCompared.label, DataCompared.name))
                        else
                            cb(true, _('server_error_editGangGrades_boss'))
                        end
                    end)
                else
                    MySQL.update('DELETE FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = ?', {
                        DataCompared.name
                    }, function(rowsChange)
                        if rowsChange then
                            MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (?, ?, ?, ?, ?), (?, ?, ?, ?, ?)', {
                                DataCompared.name,
                                DataCompared.data.maxRanks - 1,
                                "boss",
                                "Chef",
                                json.encode({
                                    perm_inventory_view = true,
                                    perm_inventory_put = true,
                                    perm_inventory_take = true,
                                    perm_garage_view = true,
                                    perm_garage_exit = true,
                                    perm_garage_store = true,
                                    perm_boss_menu = true,
                                    perm_manage_members = true,
                                    perm_manage_permissions = true,
                                    perm_manage_ranks  = true
                                }),
                                DataCompared.name,
                                0,
                                "zero",
                                "RESET MAXRANKS",
                                json.encode({
                                    perm_inventory_view = false,
                                    perm_inventory_put = false,
                                    perm_inventory_take = false,
                                    perm_garage_view = false,
                                    perm_garage_exit = false,
                                    perm_garage_store = false,
                                    perm_boss_menu = false,
                                    perm_manage_members = false,
                                    perm_manage_permissions = false,
                                    perm_manage_ranks  = false
                                })
                            }, function(rowsChangeGrades)
                                if rowsChangeGrades then
                                    DataCompared.grades = {
                                        boss = {
                                            grade = DataCompared.data.maxRanks - 1,
                                            name = "boss",
                                            label = "Chef",
                                            permissions = {
                                                perm_inventory_view = true,
                                                perm_inventory_put = true,
                                                perm_inventory_take = true,
                                                perm_garage_view = true,
                                                perm_garage_exit = true,
                                                perm_garage_store = true,
                                                perm_boss_menu = true,
                                                perm_manage_members = true,
                                                perm_manage_permissions = true,
                                                perm_manage_ranks  = true
                                            }
                                        },
                                        zero = {
                                            grade = 0,
                                            name = "zero",
                                            label = "RESET MAXRANKS",
                                            permissions = {
                                                perm_inventory_view = false,
                                                perm_inventory_put = false,
                                                perm_inventory_take = false,
                                                perm_garage_view = false,
                                                perm_garage_exit = false,
                                                perm_garage_store = false,
                                                perm_boss_menu = false,
                                                perm_manage_members = false,
                                                perm_manage_permissions = false,
                                                perm_manage_ranks  = false
                                            }
                                        }
                                    }
                                    TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                                        author = _src,
                                        action = "adminEdit",
                                        data = DiscordLogs
                                    })
                                    ServerGangsData[DataCompared.name] = DataCompared  
                                    TriggerClientEvent('mgd_gangbuilder:maxRanksResetGrade', -1, DataCompared.name)         
                                    TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                                    cb(true, _('server_success_editGang', DataCompared.label, DataCompared.name))
                                else
                                    cb(true, _('server_error_editGangGrades', "#2"))
                                end
                            end)
                        else
                            cb(true, _('server_error_editGangGrades', "#1"))
                        end
                    end)
                end
            else
                TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                    author = _src,
                    action = "adminEdit",
                    data = DiscordLogs
                })
                ServerGangsData[DataCompared.name] = DataCompared
                TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                cb(true, _('server_success_editGang', DataCompared.label, DataCompared.name))
            end
        else
            cb(false, _('server_error_editGang'))
        end
    end)
end)