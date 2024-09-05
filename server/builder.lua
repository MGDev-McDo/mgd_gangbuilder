ESX.RegisterServerCallback('mgd_gangbuilder:createGang', function(source, cb, CreateGangData)
    local _src = source
    local gangData = json.encode({ maxRanks = CreateGangData.maxRanks, coords = CreateGangData.coords, garage = {} })
    MySQL.insert('INSERT INTO `mgdgangbuilder_gangs` (`name`, `label`, `data`) VALUES (@name, @label, @data)', {
        ['@name'] = CreateGangData.name,
        ['@label'] = CreateGangData.label,
        ['@data'] = gangData
    }, function(rowsChange)
        if rowsChange then
            local formatedName = "gang_" .. CreateGangData.name
            local defaultData = json.encode({weapons={}, items={}, accounts={}})
            MySQL.insert('INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES (@name, @label, 1)', {
                ['@name'] = formatedName,
                ['@label'] = CreateGangData.label
            })
            MySQL.insert('INSERT INTO `datastore_data` (`name`, `data`) VALUES (@name, @data)', {
                ['@name'] = formatedName,
                ['@data'] = defaultData
            })

            TriggerEvent('mgd_gangbuilderXesx_datastore:createDataStore', formatedName, defaultData)

            MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (@gang_name, @boss_grade, @boss_name, @boss_label, @boss_permissions), (@gang_name, @zero_grade, @zero_name, @zero_label, @zero_permissions)', {
                ['@gang_name'] = CreateGangData.name,
                ['@boss_grade'] = CreateGangData.maxRanks - 1,
                ['@boss_name'] = 'boss',
                ['@boss_label'] = 'Chef',
                ['@boss_permissions'] = json.encode({
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
                ['@zero_grade'] = 0,
                ['@zero_name'] = 'zero',
                ['@zero_label'] = 'Default',
                ['@zero_permissions'] = json.encode({
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
                        data = json.decode(gangData),
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

                    GlobalState['mgd_gangbuilder'] = ServerGangsData

                    TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                        author = _src,
                        action = "adminCreate",
                        data = {
                            {fieldName = _('createMenu_name'), value = CreateGangData.name},
                            {fieldName = _('createMenu_label'), value = CreateGangData.label},
                            {fieldName = _('createMenu_maxRanks'), value = CreateGangData.maxRanks}
                        }
                    })
                    cb(true, _('server_success_createGang', CreateGangData.label, CreateGangData.name, CreateGangData.maxRanks), 'success')
                else
                    cb(true, _('server_error_createGangGrades'), 'warning')
                end
            end)
        else
            cb(false, _('server_error_createGang'), 'error')
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:deleteGang', function(source, cb, gangName)
    local _src = source
    local formatedName = "gang_" .. gangName
    MySQL.update('DELETE FROM `mgdgangbuilder_gangs` WHERE `name` = @name', {
        ['@name'] = gangName
    }, function(deleteGangs)
        if deleteGangs then
            MySQL.update('DELETE FROM `datastore` WHERE `name` = @name', {
                ['@name'] = formatedName
            })
            MySQL.update('DELETE FROM `datastore_data` WHERE `name` = @name', {
                ['@name'] = formatedName
            })

            TriggerEvent('mgd_gangbuilderXesx_datastore:deleteDataStore', formatedName)
            
            MySQL.update('DELETE FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = @name', {
                ['@name'] = gangName
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

                    cb(true, _('server_success_deleteGang', ServerGangsData[gangName].label, gangName), 'success')

                    ServerGangsData[gangName] = nil
                    GlobalState['mgd_gangbuilder'] = ServerGangsData

                    TriggerClientEvent('mgd_gangbuilder:updateClientAfterAction', -1, _('server_deletegang_setnone'), gangName, "none", 0)
                else
                    cb(true, _('server_error_deleteGangGrades'), 'warning')
                end
            end)
        else
            cb(false, _('server_error_deleteGang'), 'error')
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
            },
            garage = oldGangData.data.garage
        },
        grades = oldGangData.grades
    }

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

    MySQL.update('UPDATE `mgdgangbuilder_gangs` SET `label` = @label, `data` = @data WHERE `name` = @name', {
        ['@label'] = DataCompared.label,
        ['@data'] = json.encode(DataCompared.data),
        ['@name'] = DataCompared.name
    }, function(rowsChange)
        if rowsChange then
            if newGangData.maxRanks and newGangData.maxRanks ~= oldGangData.data.maxRanks then
                if DataCompared.data.maxRanks > oldGangData.data.maxRanks then
                    MySQL.update('UPDATE `mgdgangbuilder_gangs_grades` SET `grade` = @grade WHERE `gang_name` = @gang_name AND `name` = @name', {
                        ['@grade'] = DataCompared.data.maxRanks - 1,
                        ['@gang_name'] = DataCompared.name,
                        ['@name'] = "boss"
                    }, function(rowsChangeGrades)
                        if rowsChangeGrades then
                            TriggerEvent('mgd_gangbuilder:dLogs', "ADMIN", {
                                author = _src,
                                action = "adminEdit",
                                data = DiscordLogs
                            })
                            DataCompared.grades["boss"].grade = DataCompared.data.maxRanks - 1
                            ServerGangsData[DataCompared.name] = DataCompared
                            
                            GlobalState['mgd_gangbuilder'] = ServerGangsData

                            TriggerClientEvent('mgd_gangbuilder:updateClientAfterActionEdit', -1, _('server_editGang'), DataCompared.name)         
                            cb(true, _('server_success_editGang', DataCompared.label, DataCompared.name), 'success')
                        else
                            cb(false, _('server_error_editGangGrades_boss'), 'error')
                        end
                    end)
                else
                    MySQL.update('DELETE FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = @gang_name', {
                        ['@gang_name'] = DataCompared.name
                    }, function(rowsChange)
                        if rowsChange then
                            MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (@gang_name, @boss_grade, @boss_name, @boss_label, @boss_permissions), (@gang_name, @zero_grade, @zero_name, @zero_label, @zero_permissions)', {
                                ['@gang_name'] = DataCompared.name,
                                ['@boss_grade'] = DataCompared.data.maxRanks - 1,
                                ['@boss_name'] = 'boss',
                                ['@boss_label'] = 'Chef',
                                ['@boss_permissions'] = json.encode({
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
                                ['@zero_grade'] = 0,
                                ['@zero_name'] = 'zero',
                                ['@zero_label'] = 'Reset MaxRanks',
                                ['@zero_permissions'] = json.encode({
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
                                            label = "Reset MaxRanks",
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
                                    GlobalState['mgd_gangbuilder'] = ServerGangsData

                                    TriggerClientEvent('mgd_gangbuilder:updateClientAfterAction', -1, _('server_editGang_resetRank'), DataCompared.name, DataCompared.name, 0)         
                                    
                                    cb(true, _('server_success_editGang', DataCompared.label, DataCompared.name), 'success')
                                else
                                    cb(false, _('server_error_editGangGrades', "#2"), 'error')
                                end
                            end)
                        else
                            cb(false, _('server_error_editGangGrades', "#1"), 'error')
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
                GlobalState['mgd_gangbuilder'] = ServerGangsData

                TriggerClientEvent('mgd_gangbuilder:updateClientAfterActionEdit', -1, _('server_editGang'), DataCompared.name)         

                cb(true, _('server_success_editGang', DataCompared.label, DataCompared.name), 'success')
            end
        else
            cb(false, _('server_error_editGang'), 'error')
        end
    end)
end)