local GarageMenu = RageUI.CreateMenu(_("garageMenu_title"), "")

function RageUI.PoolMenus:MGDGangBuilder_Garage()
	GarageMenu:IsVisible(function(Items)
        if Config.garageUniqueVehicle then
            local garageData = (GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].data.garage or {})

            for k,v in pairs(garageData) do
                Items:AddButton(GetLabelText(GetDisplayNameFromVehicleModel(v.model)), nil, { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_garage_exit"], RightLabel = k }, function(s, a)
                    if s then
                        ESX.TriggerServerCallback("mgd_gangbuilder:exitVehicle", function(success, cbText, msgType)
                            if success then
                                local spawnData = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].data.coords.garageSpawn
                                local pos = vector3(spawnData.x, spawnData.y, spawnData.z)

                                ESX.Game.SpawnVehicle(v.model, pos, spawnData.w, function(vehicle)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                    ESX.Game.SetVehicleProperties(vehicle, v)

                                    RageUI.CloseAll()
                                end)
                            end

                            lib.notify({
                                title = _('notify_title_'.. msgType),
                                description = cbText,
                                type = msgType,
                                duration = 6000
                            })
                        end, k)
                    end
                end)
            end
        else
            for i = 1, #Config.garageVehicleList do
                local thisVehicle = Config.garageVehicleList[i]
                Items:AddButton(GetLabelText(GetDisplayNameFromVehicleModel(thisVehicle)), nil, { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_garage_exit"] }, function(s, a)
                    if s then
                        local spawnData = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].data.coords.garageSpawn
                        local pos = vector3(spawnData.x, spawnData.y, spawnData.z)

                        ESX.Game.SpawnVehicle(thisVehicle, pos, spawnData.w, function(vehicle)
                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

                            RageUI.CloseAll()
                        end)

                        lib.notify({
                            title = _('notify_title_success'),
                            description = _('garageStore_notUniqueSpawn'),
                            type = 'success',
                            duration = 6000
                        })
                    end
                end)
            end
        end
    end, function()
	end)
end

function OpenGarageMenu()
    GarageMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    RageUI.Visible(GarageMenu, not RageUI.Visible(GarageMenu))
end

function StoreVehicleInGarage()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if Config.garageUniqueVehicle then
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        local modelLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model))

        ESX.TriggerServerCallback("mgd_gangbuilder:storeVehicle", function(success, cbText, msgType)
            if success then
                ESX.Game.DeleteVehicle(vehicle)
            
                while DoesEntityExist(vehicle) do
                    Citizen.Wait(500)
                    ESX.Game.DeleteVehicle(vehicle)
                end
            end
            
            lib.notify({
                title = _('notify_title_'.. msgType),
                description = cbText,
                type = msgType,
                duration = 6000
            })
        end, vehicleProps, vehiclePlate, modelLabel)
    else
        ESX.Game.DeleteVehicle(vehicle)

        while DoesEntityExist(vehicle) do
            Citizen.Wait(500)
            ESX.Game.DeleteVehicle(vehicle)
        end

        lib.notify({
            title = _('notify_title_success'),
            description = _('garageStore_notUniqueStore'),
            type = 'success',
            duration = 6000
        })
    end
end