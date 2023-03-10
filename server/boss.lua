ESX.RegisterServerCallback('mgd_gangbuilder:getFreeGrade', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    local expected = 0
    local onesLabel = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"}
    local tensLabel = {"", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"}
    local returnName = ""
    MySQL.query("SELECT `grade` FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = ? ORDER BY `grade` ASC", {xPlayer.gang.name}, function(result)
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
                    cb(false, _('server_error_createGrade_noFreeID'))
                end
            end
        end

        cb(true, "", expected, returnName)
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:createGrade', function(source, cb, gradeLabel, gradeID, gradeName)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local gangName = xPlayer.gang.name

    MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (?, ?, ?, ?, ?)', {
        gangName,
        gradeID,
        gradeName,
        gradeLabel,
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
            TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                author = _src,
                action = "gangCreateGrade",
                data = {
                    {fieldName = "Gang", value = gangName},
                    {fieldName = "ID", value = gradeID},
                    {fieldName = "Label", value = gradeLabel}
                }
            })
            TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
            cb(true, _('server_success_createGrade', gradeLabel))
        else
            cb(false, _('server_error_createGrade'))
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:deleteGrade', function(source, cb, gangName, gradeName)
    local _src = source
    if ServerGangsData[gangName].grades[gradeName] ~= nil then 
        MySQL.update('DELETE FROM `mgdgangbuilder_gangs_grades` WHERE `gang_name` = ? AND `name` = ?', {
            gangName,
            gradeName
        }, function(rowsChange)
            if rowsChange then
                local gradeLabel = ServerGangsData[gangName].grades[gradeName].label
                local gradeID = ServerGangsData[gangName].grades[gradeName].grade
                ServerGangsData[gangName].grades[gradeName] = nil
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangDeleteGrade",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "ID", value = gradeID},
                        {fieldName = "Label", value = gradeLabel}
                    }
                })
                TriggerClientEvent('mgd_gangbuilder:checkDeleteGrade', -1, gangName, gradeName)
                TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                cb(true, _('server_success_deleteGrade', gradeLabel))
            else
                cb(false, _('server_error_deleteGrade'))
            end
        end)
    else
        cb(false, _('server_error_noGradeFound'))
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:renameGrade', function(source, cb, gangName, gradeName, newLabel)
    local _src = source
    if ServerGangsData[gangName].grades[gradeName] ~= nil then 
        MySQL.update('UPDATE `mgdgangbuilder_gangs_grades` SET `label` = ? WHERE `gang_name` = ? AND `name` = ?', {
            newLabel,
            gangName,
            gradeName
        }, function(rowsChange)
            if rowsChange then
                local oldLabel = ServerGangsData[gangName].grades[gradeName].label
                ServerGangsData[gangName].grades[gradeName].label = newLabel
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangRenameGrade",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "ID", value = ServerGangsData[gangName].grades[gradeName].grade},
                        {fieldName = "Label", value = oldLabel .." → ".. newLabel}
                    }
                })
                TriggerClientEvent('mgd_gangbuilder:checkRenameGrade', -1, gangName, gradeName)
                TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                cb(true, _('server_success_renameGrade', oldLabel, newLabel))
            else
                cb(false, _('server_error_renameGrade'))
            end
        end)
    else
        cb(false, _('server_error_noGradeFound'))
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:editPermissions', function(source, cb, gangName, gradeName, permissions)
    local _src = source
    if ServerGangsData[gangName].grades[gradeName] ~= nil then 
        MySQL.update('UPDATE `mgdgangbuilder_gangs_grades` SET `permissions` = ? WHERE `gang_name` = ? AND `name` = ?', {
            json.encode(permissions),
            gangName,
            gradeName
        }, function(rowsChange)
            if rowsChange then
                ServerGangsData[gangName].grades[gradeName].permissions = permissions
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangEditPerms",
                    data = {
                        {fieldName = "Gang", value = gangName},
                        {fieldName = "ID", value = ServerGangsData[gangName].grades[gradeName].grade},
                        {fieldName = "Label", value = ServerGangsData[gangName].grades[gradeName].label},
                        {fieldName = "Permissions", value = json.encode(permissions)}
                    }
                })
                TriggerClientEvent('mgd_gangbuilder:checkEditPermissions', -1, gangName, gradeName)
                TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', -1, ServerGangsData)
                cb(true, _('server_success_editPermissions', ServerGangsData[gangName].grades[gradeName].label))
            else
                cb(false, _('server_error_editPermissions'))
            end
        end)
    else
        cb(false, _('server_error_noGradeFound'))
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:getMembers', function(source, cb, gangName)
    local _src = source
    MySQL.query('SELECT `identifier`, `firstname`, `lastname`, `mgdgangbuilder_gangs_grades`.`label` FROM `users` LEFT JOIN `mgdgangbuilder_gangs_grades` ON `gang` = `gang_name` AND `gang_grade` = `grade` WHERE `gang` = ?', {
        gangName
    }, function(result)
        if result[1] then
            cb(result)
        end
    end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:invite', function(source, cb, target)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local TxPlayer = ESX.GetPlayerFromId(target)

    if TxPlayer ~= nil then
        MySQL.update('UPDATE `users` SET `gang` = ?, `gang_grade` = ? WHERE `identifier` = ?', {
            xPlayer.gang.name,
            0,
            TxPlayer.identifier
        })
        TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
            author = _src,
            action = "gangInvite",
            data = {
                {fieldName = "Gang", value = xPlayer.gang.name},
                {fieldName = "Joueur", value = TxPlayer.get('firstName') .." ".. TxPlayer.get('lastName') }
            }
        })
        TxPlayer.setGang(xPlayer.gang.name, 0)
        TxPlayer.showNotification(_('server_succes_invite_target', xPlayer.gang.label))
        cb(true, _('server_succes_invite', target))
    else
        cb(false, _('server_error_invite_noPlayer'))
    end
end)

ESX.RegisterServerCallback('mgd_gangbuilder:fire', function(source, cb, target)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local TxPlayer = ESX.GetPlayerFromIdentifier(target)

    MySQL.update('UPDATE `users` SET `gang` = ?, `gang_grade` = ? WHERE `identifier` = ?', {
        "none",
        0,
        target
    })
    
    TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
        author = _src,
        action = "gangFire",
        data = {
            {fieldName = "Gang", value = xPlayer.gang.name},
            {fieldName = "Joueur", value = (TxPlayer.get('firstName') .." ".. TxPlayer.get('lastName') or target) }
        }
    })

    if TxPlayer ~= nil then
        TxPlayer.setGang("none", 0)
        TxPlayer.showNotification(_('server_succes_fire_target', xPlayer.gang.label))
    end

    cb(true, _('server_succes_fire'))
end)

ESX.RegisterServerCallback('mgd_gangbuilder:changeGrade', function(source, cb, target, gradeID, gradeLabel)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local TxPlayer = ESX.GetPlayerFromIdentifier(target)

    MySQL.update('UPDATE `users` SET `gang_grade` = ? WHERE `identifier` = ?', {
        gradeID,
        target
    })
    
    TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
        author = _src,
        action = "gangChangeGrade",
        data = {
            {fieldName = "Gang", value = xPlayer.gang.name},
            {fieldName = "Joueur", value = (TxPlayer.get('firstName') .." ".. TxPlayer.get('lastName') or target) },
            {fieldName = "Grade", value = gradeID}
        }
    })

    if TxPlayer ~= nil then
        TxPlayer.setGang(TxPlayer.gang.name, gradeID)
        TxPlayer.showNotification(_('server_succes_changeGrade_target', gradeLabel))
    end

    cb(true, _('server_succes_changeGrade', gradeLabel))
end)