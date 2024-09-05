ServerGangsData = {}
GlobalState['mgd_gangbuilder'] = {}

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
    local gangsCount, gradesCount = 0, 0

    MySQL.query("SELECT `mgdgangbuilder_gangs`.`name` AS 'gangName', `mgdgangbuilder_gangs`.`label` AS 'gangLabel', `mgdgangbuilder_gangs`.`data` AS 'gangData', `mgdgangbuilder_gangs_grades`.`grade`, `mgdgangbuilder_gangs_grades`.`name` AS 'gradeName', `mgdgangbuilder_gangs_grades`.`label` AS 'gradeLabel', `mgdgangbuilder_gangs_grades`.`permissions` AS 'gradePermissions' FROM `mgdgangbuilder_gangs` INNER JOIN `mgdgangbuilder_gangs_grades` ON `mgdgangbuilder_gangs`.`name` = `mgdgangbuilder_gangs_grades`.`gang_name`",
    {}, function(result)
        if result[1] then
            for _, dataResult in pairs(result) do
                if ServerGangsData[dataResult.gangName] == nil then
                    ServerGangsData[dataResult.gangName] = {
                        name = dataResult.gangName,
                        label = dataResult.gangLabel,
                        data = json.decode(dataResult.gangData),
                        grades = {
                            [dataResult.gradeName] = {
                                grade = dataResult.grade,
                                name = dataResult.gradeName,
                                label = dataResult.gradeLabel,
                                permissions = json.decode(dataResult.gradePermissions)
                            }
                        }
                    }

                    if ServerGangsData[dataResult.gangName].data.garage == nil then ServerGangsData[dataResult.gangName].data.garage = {} end

                    if Config.ox_inventory and dataResult.gangName ~= "none" then
                        local thisGang = ServerGangsData[dataResult.gangName]
                        local stash = {
                            id = 'gang_'.. thisGang.name,
                            label = thisGang.label,
                            slots = Config.ox_inventory_Slots,
                            weight = Config.ox_inventory_MaxWeight,
                            owner = nil,
                            groups = false,
                            coords = thisGang.data.coords.inventory
                        }
                
                        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.groups, stash.coords)
                    end

                    gangsCount = gangsCount + 1
                    gradesCount = gradesCount + 1
                else
                    ServerGangsData[dataResult.gangName].grades[dataResult.gradeName] = {
                        grade = dataResult.grade,
                        name = dataResult.gradeName,
                        label = dataResult.gradeLabel,
                        permissions = json.decode(dataResult.gradePermissions)
                    }

                    gradesCount = gradesCount + 1
                end
            end
        else
            print('(^3mgd_gangbuilder - WARNING^7) No gangs found in database !')
            CreateDefaultGang()
        end

        if ServerGangsData['none'] == nil then
            print('(^3mgd_gangbuilder - WARNING^7) Default gang not found in database !')
            gangsCount = gangsCount + 1
            gangsGradesCount = gangsGradesCount + 1
            CreateDefaultGang()
        end

        print(('(^4mgd_gangbuilder - INFO^7) %s gang(s) loaded with a total of %s grade(s)'):format(gangsCount, gradesCount))

        GlobalState['mgd_gangbuilder'] = ServerGangsData
    end)
end)

AddEventHandler("esx:playerLoaded", function(_, xPlayer)
    MySQL.query('SELECT `gang`, `gang_grade` FROM `users` WHERE `identifier` = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        xPlayer.setGang(result[1].gang, result[1].gang_grade)
    end)
end)

AddEventHandler("esx:playerLogout", function(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        xPlayer.saveGangData()
    end
end)

function CreateDefaultGang()
    MySQL.insert('INSERT INTO `mgdgangbuilder_gangs` (`name`, `label`, `data`) VALUES (@name, @label, @data)', {
        ['@name'] = 'none',
        ['@label'] = 'Aucun',
        ['@data'] = '{}'
    })
    MySQL.insert('INSERT INTO `mgdgangbuilder_gangs_grades` (`gang_name`, `grade`, `name`, `label`, `permissions`) VALUES (@gang_name, @grade, @name, @label, @permissions)', {
        ['@gang_name'] = 'none',
        ['@grade'] = 0,
        ['@name'] = 'none',
        ['@label'] = 'Aucun',
        ['@permissions'] = '{}'
    })

    ServerGangsData['none'] = {
        name = 'none',
        label = 'Aucun',
        data = {},
        grades = {
            ['none'] = {
                grade = 0,
                name = 'none',
                label = 'Aucun',
                permissions = {}
            }
        }
    }

    print('(^2mgd_gangbuilder - SUCCESS^7) Re-creation of the default gang !')
end

RegisterServerEvent('mgd_gangbuilder:setNewGangData')
AddEventHandler('mgd_gangbuilder:setNewGangData', function(gang, grade)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    xPlayer.setGang(gang, grade)
    xPlayer.saveGangData()
end)