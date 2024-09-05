ESX.RegisterServerCallback('mgd_gangbuilder:getFreeGrade', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    local expected = 0
    local onesLabel = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"}
    local tensLabel = {"", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"}
    local returnName = ""
    MySQL.query("SELECT `grade` FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = @gang_name ORDER BY `grade` ASC", {
        ['@gang_name'] = xPlayer.gang.name
    }, function(result)
        for i = 1, #result, 1 do
            if result[i].grade == expected then
                expected = expected + 1
            else
                if result[i].name ~= "boss" then
                    if expected > 19 then
                        local ones = expected % 10
                        local tens = expected // 10
                        if ones > 0 then
                            returnName = tensLabel[tens + 1] .. onesLabel[ones + 1]
                        else
                            returnName = tensLabel[tens + 1]
                        end
                    else
                        returnName = onesLabel[expected + 1]
                    end
                else
                    cb(false, _('server_error_createGrade_noFreeID'), 'error')
                end
            end
        end

        cb(true, "", "", expected, returnName)
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:createGrade', function(source, cb, gradeLabel, gradeID, gradeName)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name

    MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (@gang_name, @grade, @name, @label, @permissions)', {
        ['@gang_name'] = gangName,
        ['@grade'] = gradeID,
        ['@name'] = gradeName,
        ['@label'] = gradeLabel,
        ['@permissions'] = json.encode({
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
    }, function(rowsChange)
        if rowsChange then
            ServerGangsData[gangName].grades[gradeName] = {
                grade = gradeID,
                name = gradeName,
                label = gradeLabel,
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

            GlobalState['mgd_gangbuilder'] = ServerGangsData

            TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                author = _src,
                action = "gangCreateGrade",
                data = {
                    {fieldName = "Gang", value = gangName},
                    {fieldName = "ID", value = gradeID},
                    {fieldName = "Label", value = gradeLabel}
                }
            })

            cb(true, _('server_success_createGrade', gradeLabel), 'success')
        else
            cb(false, _('server_error_createGrade'), 'error')
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:deleteGrade', function(source, cb, gradeName)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name
    local gradeData = GlobalState['mgd_gangbuilder'][gangName].grades[gradeName]
    if gradeData ~= nil then 
        MySQL.update('DELETE FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = @gang_name AND `name` = @name', {
            ['@gang_name'] = gangName,
            ['@name'] = gradeName
        }, function(rowsChange)
            if rowsChange then
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangDeleteGrade",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "ID", value = gradeData.grade},
                        {fieldName = "Label", value = gradeData.label}
                    }
                })

                ServerGangsData[gangName].grades[gradeName] = nil
                GlobalState['mgd_gangbuilder'] = ServerGangsData

                TriggerClientEvent('mgd_gangbuilder:updateClientAfterActionWithGrade', -1, _('server_success_deleteGradeCl', gradeData.label), gangName, gradeName, gangName, 0)
                cb(true, _('server_success_deleteGrade', gradeData.label), 'success')
            else
                cb(false, _('server_error_deleteGrade'), 'error')
            end
        end)
    else
        cb(false, _('server_error_noGradeFound'), 'error')
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:renameGrade', function(source, cb, gradeName, newLabel)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name
    local gradeData = GlobalState['mgd_gangbuilder'][gangName].grades[gradeName]
    if gradeData ~= nil then 
        MySQL.update('UPDATE `mgdgangbuilder_gangs_grades` SET `label` = @label WHERE `gang_name` = @gang_name AND `name` = @name', {
            ['@label'] = newLabel,
            ['@gang_name'] = gangName,
            ['@name'] = gradeName
        }, function(rowsChange)
            if rowsChange then
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangRenameGrade",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "ID", value = gradeData.grade},
                        {fieldName = "Label", value = gradeData.label .." → ".. newLabel}
                    }
                })

                ServerGangsData[gangName].grades[gradeName].label = newLabel
                GlobalState['mgd_gangbuilder'] = ServerGangsData

                TriggerClientEvent('mgd_gangbuilder:updateClientAfterAction', -1, _('server_success_renameGradeCl', gradeData.label), gangName, gangName, gradeData.grade)

                cb(true, _('server_success_renameGrade', gradeData.label, newLabel), 'success')
            else
                cb(false, _('server_error_renameGrade'), 'error')
            end
        end)
    else
        cb(false, _('server_error_noGradeFound'), 'error')
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:editPermissions', function(source, cb, gradeName, permissions)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name
    local gradeData = GlobalState['mgd_gangbuilder'][gangName].grades[gradeName]

    if gradeData ~= nil then 
        MySQL.update('UPDATE `mgdgangbuilder_gangs_grades` SET `permissions` = @permissions WHERE `gang_name` = @gang_name AND `name` = @name', {
            ['@permissions'] = json.encode(permissions),
            ['@gang_name'] = gangName,
            ['@name'] = gradeName
        }, function(rowsChange)
            if rowsChange then
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangEditPerms",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "ID", value = gradeData.grade},
                        {fieldName = "Label", value = gradeData.label},
                        {fieldName = "Permissions", value = json.encode(permissions)}
                    }
                })

                ServerGangsData[gangName].grades[gradeName].permissions = permissions
                GlobalState['mgd_gangbuilder'] = ServerGangsData

                TriggerClientEvent('mgd_gangbuilder:updateClientAfterActionWithGrade', -1, _('server_success_editPermissionsCl'), gangName, gradeData.grade, gangName, gradeData.grade)

                cb(true, _('server_success_editPermissions', gradeData.label), 'success')
            else
                cb(false, _('server_error_editPermissions'), 'error')
            end
        end)
    else
        cb(false, _('server_error_noGradeFound'), 'error')
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:getMembers', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.query('SELECT `identifier`, `firstname`, `lastname`, `mgdgangbuilder_gangs_grades`.`label` FROM `users` LEFT JOIN `mgdgangbuilder_gangs_grades` ON `gang` = `gang_name` AND `gang_grade` = `grade` WHERE `gang` = @gang', {
        ['@gang'] = xPlayer.gang.name
    }, function(result)
        cb(result)
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:invite', function(source, cb, target)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local TxPlayer = ESX.GetPlayerFromId(target)

    if TxPlayer ~= nil then
        TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
            author = _src,
            action = "gangInvite",
            data = {
                {fieldName = "Gang", value = xPlayer.gang.name},
                {fieldName = "Joueur", value = TxPlayer.get('firstName') .." ".. TxPlayer.get('lastName') }
            }
        })

        TxPlayer.triggerEvent('mgd_gangbuilder:updateClientAfterAction', _('server_succes_invite_target', xPlayer.gang.label), TxPlayer.gang.name, xPlayer.gang.name, 0)

        cb(true, _('server_succes_invite'), 'success')
    else
        cb(false, _('server_error_invite_noPlayer'), 'error')
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:fire', function(source, cb, target, identifier)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local TxPlayer

    if identifier then
        TxPlayer = ESX.GetPlayerFromIdentifier(target)
    else
        TxPlayer = ESX.GetPlayerFromId(target)
    end

    TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
        author = _src,
        action = "gangFire",
        data = {
            {fieldName = "Gang", value = xPlayer.gang.name},
            {fieldName = "Joueur", value = (TxPlayer.get('firstName') .." ".. TxPlayer.get('lastName') or target) }
        }
    })

    if TxPlayer then
        if TxPlayer.gang.name == xPlayer.gang.name then
            TxPlayer.triggerEvent('mgd_gangbuilder:updateClientAfterAction', _('server_succes_fire_target', xPlayer.gang.label), xPlayer.gang.name, 'none', 0)
            cb(true, _('server_succes_fire'), 'success')
        else
            cb(false, _('server_error_fire_notInGang'), 'error')
        end
    else
        MySQL.update('UPDATE `users` SET `gang` = "none", `gang_grade` = 0 WHERE `identifier` = @identifier', {
            ['@identifier'] = target
        })

        cb(true, _('server_succes_fire'), 'success')
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:changeGrade', function(source, cb, target, gradeID)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local TxPlayer = ESX.GetPlayerFromIdentifier(target)
    local gradeLabel = GlobalState['mgd_gangbuilder'][xPlayer.gang.name].grades[gradeID].label
    
    TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
        author = _src,
        action = "gangChangeGrade",
        data = {
            {fieldName = "Gang", value = xPlayer.gang.name},
            {fieldName = "Joueur", value = (TxPlayer.get('firstName') .." ".. TxPlayer.get('lastName') or target) },
            {fieldName = "Grade", value = gradeID}
        }
    })

    if TxPlayer then
        TxPlayer.triggerEvent('mgd_gangbuilder:updateClientAfterAction', _('server_succes_changeGrade_target', gradeLabel), TxPlayer.gang.name, TxPlayer.gang.name, gradeID)
    else
        MySQL.update('UPDATE `users` SET `gang_grade` = @gang_grade WHERE `identifier` = @identifier', {
            ['@gang_grade'] = gradeID,
            ['@identifier'] = target
        })
    end

    cb(true, _('server_succes_changeGrade', gradeLabel), 'success')
end)