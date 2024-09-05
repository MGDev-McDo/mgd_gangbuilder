local GangPoints, GangMarkers = {}, {}
local function InitializePoints()
    while GlobalState['mgd_gangbuilder'] == nil do Citizen.Wait(500) end

    local isOpen, currentText = lib.isTextUIOpen()
    if isOpen then
        lib.hideTextUI()
    end

    for k,v in pairs(GangPoints) do
        if GangPoints[k] then
            GangPoints[k].remove(GangPoints[k])
        end
    end

    if ESX.PlayerData.gang and ESX.PlayerData.gang.name == 'none' then return end

    local coords = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].data.coords

    for k,v in pairs(coords) do
        if k ~= 'garageSpawn' then
            GangPoints[k] = lib.points.new({
                coords = vector3(v.x, v.y, v.z),
                distance = Config.DrawDistance
            })

            GangMarkers[k] = lib.marker.new({
                type = Config.Marker[k].type,
                width = Config.Marker[k].width,
                height = Config.Marker[k].height,
                color = Config.Marker[k].color,
                coords = { x = v.x + Config.Marker[k].adaptCoords.x, y = v.y + Config.Marker[k].adaptCoords.y, z = v.z + Config.Marker[k].adaptCoords.z }
            })
        end
    end

    if ESX.PlayerData.gang.grade_permissions["perm_inventory_view"] then
        function GangPoints.inventory:nearby()
            GangMarkers['inventory']:draw()

            if self.currentDistance < (Config.Marker['inventory'].width) then
                if not lib.isTextUIOpen() then
                    lib.showTextUI(_('textUI_openInventory'), {
                        icon = Config.TextUI.icons['inventory'],
                        style = {
                            borderRadius = Config.TextUI.borderRadius,
                            backgroundColor = Config.TextUI.backgroundColor,
                        }
                    })
                end
    
                if IsControlJustPressed(0, 51) then
                    OpenInventoryMenu()
                end
            else
                local isOpen, currentText = lib.isTextUIOpen()
                if isOpen and currentText == _('textUI_openInventory') then
                    lib.hideTextUI()
                end
            end
        end
    end
    
    if ESX.PlayerData.gang.grade_permissions["perm_garage_view"] then
        function GangPoints.garageMenu:nearby()
            GangMarkers['garageMenu']:draw()

            if self.currentDistance < (Config.Marker['garageMenu'].width) then
                if not lib.isTextUIOpen() then
                    lib.showTextUI(_('textUI_openGarageMenu'), {
                        icon = Config.TextUI.icons['garageMenu'],
                        style = {
                            borderRadius = Config.TextUI.borderRadius,
                            backgroundColor = Config.TextUI.backgroundColor,
                        }
                    })
                end
    
                if IsControlJustPressed(0, 51) then
                    OpenGarageMenu()
                end
            else
                local isOpen, currentText = lib.isTextUIOpen()
                if isOpen and currentText == _('textUI_openGarageMenu') then
                    lib.hideTextUI()
                end
            end
        end
    end
    
    if ESX.PlayerData.gang.grade_permissions["perm_garage_store"] then
        function GangPoints.garageStore:nearby()
            GangMarkers['garageStore']:draw()

            if (self.currentDistance < Config.Marker['garageStore'].width) and IsPedInAnyVehicle(PlayerPedId(), false) then
                if not lib.isTextUIOpen() then
                    lib.showTextUI(_('textUI_openGarageStore'), {
                        icon = Config.TextUI.icons['garageStore'],
                        style = {
                            borderRadius = Config.TextUI.borderRadius,
                            backgroundColor = Config.TextUI.backgroundColor,
                        }
                    })
                end
    
                if IsControlJustPressed(0, 51) then
                    StoreVehicleInGarage()
                end
            else
                local isOpen, currentText = lib.isTextUIOpen()
                if isOpen and currentText == _('textUI_openGarageStore') then
                    lib.hideTextUI()
                end
            end
        end
    end
    
    if ESX.PlayerData.gang.grade_permissions["perm_boss_menu"] then
        function GangPoints.boss:nearby()
            GangMarkers['boss']:draw()

            if self.currentDistance < (Config.Marker['boss'].width) then
                if not lib.isTextUIOpen() then
                    lib.showTextUI(_('textUI_openBoss'), {
                        icon = Config.TextUI.icons['boss'],
                        style = {
                            borderRadius = Config.TextUI.borderRadius,
                            backgroundColor = Config.TextUI.backgroundColor,
                        }
                    })
                end
    
                if IsControlJustPressed(0, 51) then
                    OpenBossMenu()
                end
            else
                local isOpen, currentText = lib.isTextUIOpen()
                if isOpen and currentText == _('textUI_openBoss') then
                    lib.hideTextUI()
                end
            end
        end
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('mgd_gangbuilder:setGang')
AddEventHandler('mgd_gangbuilder:setGang', function(gang)
	ESX.SetPlayerData('gang', gang)
    InitializePoints()
end)

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
    InitializePoints()
end)

RegisterNetEvent('mgd_gangbuilder:updateClientAfterAction')
AddEventHandler('mgd_gangbuilder:updateClientAfterAction', function(message, gangAffected, newGang, newGrade)
    if ESX.PlayerData.gang.name == gangAffected then
        RageUI.CloseAll()
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', newGang, newGrade)

        lib.notify({
            title = _('notify_title_inform'),
            description = message,
            type = 'inform',
            duration = 6000
        })
    end
end)

RegisterNetEvent('mgd_gangbuilder:updateClientAfterActionEdit')
AddEventHandler('mgd_gangbuilder:updateClientAfterActionEdit', function(message, gangAffected)
    if ESX.PlayerData.gang.name == gangAffected then
        RageUI.CloseAll()
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', ESX.PlayerData.gang.name, ESX.PlayerData.gang.grade)

        lib.notify({
            title = _('notify_title_inform'),
            description = message,
            type = 'inform',
            duration = 6000
        })
    end
end)

RegisterNetEvent('mgd_gangbuilder:updateClientAfterActionWithGrade')
AddEventHandler('mgd_gangbuilder:updateClientAfterActionWithGrade', function(message, gangAffected, gradeAffected, newGang, newGrade)
    if ESX.PlayerData.gang.name == gangAffected and ESX.PlayerData.gang.grade_name == gradeAffected then
        RageUI.CloseAll()
        TriggerServerEvent('mgd_gangbuilder:setNewGangData', newGang, newGrade)

        lib.notify({
            title = _('notify_title_inform'),
            description = message,
            type = 'inform',
            duration = 6000
        })
    end
end)

RegisterNetEvent('mgd_gangbuilder:notify')
AddEventHandler('mgd_gangbuilder:notify', function(msg, msgType)
	lib.notify({
        title = _('notify_title_'.. msgType),
        description = msg,
        type = msgType,
        duration = 6000
    })
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