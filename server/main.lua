ServerGangsData = {}
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
        local gangsCount, gangsGradesCount = 0, 0
        MySQL.query('SELECT * FROM `mgdgangbuilder_gangs`', {
        }, function(result)
            if result[1] then
                for _, dataResult in pairs(result) do
                    gangsCount = gangsCount + 1
                    ServerGangsData[dataResult.name] = {
                        name = dataResult.name,
                        label = dataResult.label,
                        data = json.decode(dataResult.data),
                        grades = {}
                    }
                end
                print("^4[INFO] ".. gangsCount .." gangs found^7")

                MySQL.query('SELECT * FROM `mgdgangbuilder_gangs_grades` ORDER BY `grade` ASC', {
                }, function(resultGrades)
                    if resultGrades[1] then
                        for _, dataResult in pairs(resultGrades) do
                            gangsGradesCount = gangsGradesCount + 1
                            ServerGangsData[dataResult.gang_name].grades[dataResult.name] = {
                                grade = dataResult.grade,
                                name = dataResult.name,
                                label = dataResult.label,
                                permissions = json.decode(dataResult.permissions)
                            }
                        end

                        print("^4[INFO] ".. gangsGradesCount .." gangs grades found^7")
                    else
                        print("^4[INFO] No gangs grades found^7")
                    end
                end)
            else
                print("^4[INFO] No gangs found^7")
            end
        end)
    end
end)

RegisterServerEvent('mgd_gangbuilder:getGangsServerInfos')
AddEventHandler('mgd_gangbuilder:getGangsServerInfos', function()
    local _src = source
	TriggerClientEvent('mgd_gangbuilder:receiveGangsServerInfos', _src, ServerGangsData)
end)

RegisterServerEvent('mgd_gangbuilder:setGangToZero')
AddEventHandler('mgd_gangbuilder:setGangToZero', function(gang)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    xPlayer.setGang(gang, 0)
end)

RegisterServerEvent('mgd_gangbuilder:setNewGangData')
AddEventHandler('mgd_gangbuilder:setNewGangData', function(gang, grade)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    xPlayer.setGang(gang, grade)
end)