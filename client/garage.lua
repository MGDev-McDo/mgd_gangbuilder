local GarageMenu = RageUI.CreateMenu(_("garageMenu_title"), "")

function RageUI.PoolMenus:MGDGangBuilder_Garage()
    local ped = PlayerPedId()
	GarageMenu:IsVisible(function(Items)
        for k,v in pairs(GangsInfos[ESX.PlayerData.gang.name].data.garage) do
            Items:AddButton(GetLabelText(GetDisplayNameFromVehicleModel(v.model)), nil, { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_garage_exit"], RightLabel = k }, function(s, a)
                if s then
                    ESX.TriggerServerCallback("mgd_gangbuilder:exitVehicle", function(success, cbText)
                        if success then
                            local pos = vec3(GangsInfos[ESX.PlayerData.gang.name].data.coords.garageSpawn.x, GangsInfos[ESX.PlayerData.gang.name].data.coords.garageSpawn.y, GangsInfos[ESX.PlayerData.gang.name].data.coords.garageSpawn.z)
                            ESX.Game.SpawnVehicle(v.model, pos, GangsInfos[ESX.PlayerData.gang.name].data.coords.garageSpawn.w, function(vehicle)
                                TaskWarpPedIntoVehicle(ped, vehicle, -1)
                                ESX.Game.SetVehicleProperties(vehicle, v)

                                ESX.ShowNotification(cbText)
                                RageUI.CloseAll()
                            end)
                        else
                            ESX.ShowNotification(cbText)
                        end
                    end, ESX.PlayerData.gang.name, k)
                end
            end)
        end
    end, function()
	end)
end

RegisterNetEvent('mgd_gangbuilder:openGarageMenu')
AddEventHandler('mgd_gangbuilder:openGarageMenu', function()
    GarageMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    RageUI.Visible(GarageMenu, not RageUI.Visible(GarageMenu))
end)