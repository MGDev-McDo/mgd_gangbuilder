GangsInfos = {}
local HasAlreadyEnteredMarker, CurrentAction, CurrentActionMsg, LastZone = false

Citizen.CreateThread(function()
    TriggerServerEvent("mgd_gangbuilder:getGangsServerInfos")

    ESX.PlayerData = ESX.GetPlayerData()
    while ESX.PlayerData.gang == nil do
        Citizen.Wait(10)
        ESX.PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang)
    ESX.PlayerData.gang = gang
end)

RegisterNetEvent('mgd_gangbuilder:receiveGangsServerInfos')
AddEventHandler('mgd_gangbuilder:receiveGangsServerInfos', function(data)
	GangsInfos = data

    Citizen.Wait(50)
    if ESX.PlayerData.gang and ESX.PlayerData.gang ~= "none" then
        local thisGang = GangsInfos[ESX.PlayerData.gang.name]
        local thisGrade = (GangsInfos[ESX.PlayerData.gang.name].grades[ESX.PlayerData.gang.grade_name] or {grade = 0, name = "none", label = "Aucun", permissions = {}})
        ESX.PlayerData.gang.name = thisGang.name
        ESX.PlayerData.gang.label = thisGang.label

        ESX.PlayerData.gang.grade = thisGrade.grade
        ESX.PlayerData.gang.grade_name = thisGrade.name
        ESX.PlayerData.gang.grade_label = thisGrade.label
        ESX.PlayerData.gang.grade_permissions = thisGrade.permissions
    end
end)

RegisterNetEvent('mgd_gangbuilder:maxRanksResetGrade')
AddEventHandler('mgd_gangbuilder:maxRanksResetGrade', function(gang)
    if ESX.PlayerData.gang.name == gang then
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', gang, 0)
    end
end)

RegisterNetEvent('mgd_gangbuilder:deleteCheckToNone')
AddEventHandler('mgd_gangbuilder:deleteCheckToNone', function(gang)
    if ESX.PlayerData.gang.name == gang then
        ESX.PlayerData.gang.name = "none"
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', "none", 0)
        ESX.ShowNotification(_('server_deletegang_setnone'))
    end
end)

RegisterNetEvent('mgd_gangbuilder:checkDeleteGrade')
AddEventHandler('mgd_gangbuilder:checkDeleteGrade', function(gang, gradeName)
    if ESX.PlayerData.gang.name == gang and ESX.PlayerData.gang.grade_name == gradeName then
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', gang, 0)
    end
end)

RegisterNetEvent('mgd_gangbuilder:checkRenameGrade')
AddEventHandler('mgd_gangbuilder:checkRenameGrade', function(gang, gradeName)
    if ESX.PlayerData.gang.name == gang and ESX.PlayerData.gang.grade_name == gradeName then
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', gang, ESX.PlayerData.gang.grade)
    end
end)

RegisterNetEvent('mgd_gangbuilder:checkEditPermissions')
AddEventHandler('mgd_gangbuilder:checkEditPermissions', function(gang, gradeName)
    if ESX.PlayerData.gang.name == gang and ESX.PlayerData.gang.grade_name == gradeName then
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', gang, ESX.PlayerData.gang.grade)
    end
end)

function TextInput(title, inputText, maxLength)
    local entry = "TextInputMGDGangBuilder"
	AddTextEntry(entry, title)
	DisplayOnscreenKeyboard(1, entry, '', inputText, '', '', '', maxLength)

	while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
		Citizen.Wait(0)
	end

	if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end
end

-- MARKERS
Citizen.CreateThread(function()
    Citizen.Wait(500)
	while true do
		Citizen.Wait(0)
        local ped = PlayerPedId()
		local playerCoords = GetEntityCoords(ped)
		local isInMarker, letSleep, currentZone = false, true
        
        if ESX.PlayerData.gang and ESX.PlayerData.gang.name ~= "none" then
            for k,v in pairs(GangsInfos[ESX.PlayerData.gang.name].data.coords) do
                v.Pos = vec3(v.x, v.y, v.z - 1.0)
                local distance = #(playerCoords - v.Pos)

                if distance < Config.DrawDistance then
                    letSleep = false

                    if (k == "inventory" and ESX.PlayerData.gang.grade_permissions["perm_inventory_view"]) then
                        DrawMarker(1, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, 32, 251, 149, 150, false, false, 2, false, nil, nil, false)
                        if distance < 1.3 then
                            isInMarker, currentZone = true, k
                        end
                    end
                    if (k == "garageMenu" and ESX.PlayerData.gang.grade_permissions["perm_garage_view"]) then
                        DrawMarker(1, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, 32, 251, 149, 150, false, false, 2, false, nil, nil, false)
                        if distance < 1.3 then
                            isInMarker, currentZone = true, k
                        end
                    end
                    if (k == "boss" and ESX.PlayerData.gang.grade_permissions["perm_boss_menu"]) then
                        DrawMarker(1, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, 32, 251, 149, 150, false, false, 2, false, nil, nil, false)
                        if distance < 1.3 then
                            isInMarker, currentZone = true, k
                        end
                    end
                    if (k == "garageStore" and ESX.PlayerData.gang.grade_permissions["perm_garage_store"]) and IsPedInAnyVehicle(ped, false) then
                        DrawMarker(1, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 0.1, 153, 20, 20, 100, false, false, 2, false, nil, nil, false)
                        if distance < 2.1 then
                            isInMarker, currentZone = true, k
                        end
                    end
                end
            end

            if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
                HasAlreadyEnteredMarker, LastZone = true, currentZone
                LastZone = currentZone
                hasEnteredMarker(currentZone)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false
                hasExitedMarker(LastZone)
            end

            if CurrentAction then
                ESX.ShowHelpNotification(CurrentActionMsg, true, true, -1)

                if IsControlJustReleased(0, 38) then
                    if CurrentAction == "inventory" then
                        TriggerEvent("mgd_gangbuilder:openInventoryMenu")
                    end
                    if CurrentAction == "garageMenu" then
                        TriggerEvent("mgd_gangbuilder:openGarageMenu")
                    end
                    if CurrentAction == "boss" then
                        TriggerEvent("mgd_gangbuilder:openBossMenu")
                    end
                    if CurrentAction == "garageStore" then
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

                        ESX.TriggerServerCallback("mgd_gangbuilder:storeVehicle", function(success, cbText)
                            if success then
                                ESX.Game.DeleteVehicle(vehicle)
                            
                                while DoesEntityExist(vehicle) do
                                    Citizen.Wait(100)
                                    ESX.Game.DeleteVehicle(vehicle)
                                end
                                ESX.ShowNotification(cbText)
                            else
                                ESX.ShowNotification(cbText)
                            end
                        end, ESX.PlayerData.gang.name, vehicleProps, vehiclePlate)
                    end
                end
            end
        end

        if letSleep then
			Citizen.Wait(500)
            ESX.PlayerData = ESX.GetPlayerData()
		end
	end
end)

function hasEnteredMarker(zone)
    CurrentAction = zone
    CurrentActionMsg = _('actionMsg_'.. zone ..'')
end

function hasExitedMarker(zone)
	CurrentAction = nil
    RageUI.CloseAll()
end