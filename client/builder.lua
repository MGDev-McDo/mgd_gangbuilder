local CreateGangData, CreateMarkers, TeleportationIndex, ManageSelectIndex, ManageGangData, ManageMarkers, listLabelGangs, listNameGangs, CreateVehicleEntity, ManageVehicleEntity = { coords = {} }, {}, 1, 1, { coords = {} }, {}, {}, {}
local MainMenu = RageUI.CreateMenu(_("mainMenu_title"), _("mainMenu_subtitle"))
local CreateMenu = RageUI.CreateSubMenu(MainMenu, _("createMenu_title"), _("createMenu_subtitle"))
local ManageMenu = RageUI.CreateSubMenu(MainMenu, _("manageMenu_title"), _("manageMenu_subtitle"))
local DeleteConfirmationMenu = RageUI.CreateSubMenu(ManageMenu, _("deleteConfirmationMenu_title"), _("deleteConfirmationMenu_subtitle"))
local ManageSelectMenu = RageUI.CreateSubMenu(ManageMenu, _("manageSelectMenu_title"), _("manageSelectMenu_subtitle"))

AddEventHandler('mgd_gangbuilder:receiveGangsServerInfos', function(data)
    listLabelGangs = {}
    listNameGangs = {}
    table.insert(listLabelGangs, "-")
    table.insert(listNameGangs, "-")
	for k,v in pairs(data) do
        if v.name ~= "none" then
            table.insert(listLabelGangs, v.label)
            table.insert(listNameGangs, v.name)
        end
    end
end)

function RageUI.PoolMenus:MGDGangBuilder_Builder()
    local ped = PlayerPedId()
	MainMenu:IsVisible(function(Items)
        ESX.Game.DeleteVehicle(CreateVehicleEntity)
        Items:AddButton(_("mainMenu_toCreateMenu"), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a) end, CreateMenu)
        Items:AddButton(_("mainMenu_toManageMenu"), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a) end, ManageMenu)
    end, function()
	end)

    CreateMenu:IsVisible(function(Items)
        Items:AddSeparator(_("createMenu_separator_infos"))

        local createMenuNameText if CreateGangData.name and #CreateGangData.name >= 25 then createMenuNameText = _('createMenu_defined') else createMenuNameText = (CreateGangData.name or _('createMenu_undefined')) end
		Items:AddButton(_("createMenu_name"), _("createMenu_name_description"), { IsDisabled = false, RightLabel = createMenuNameText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_name_textInput'), (CreateGangData.name or ""), 50)
                if resultTextInput ~= nil and #resultTextInput > 0 then
                    CreateGangData.name = resultTextInput
                else
                    ESX.ShowNotification(_('createMenu_name_textInput_error_noInput'))
                end
            end
		end)

        local createMenuLabelText if CreateGangData.label and #CreateGangData.label >= 25 then createMenuLabelText = _('createMenu_defined') else createMenuLabelText = (CreateGangData.label or _('createMenu_undefined')) end
        Items:AddButton(_("createMenu_label"), _("createMenu_label_description"), { IsDisabled = false, RightLabel = createMenuLabelText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_label_textInput'), (CreateGangData.label or ""), 50)
                if resultTextInput ~= nil and #resultTextInput > 0 then
                    CreateGangData.label = resultTextInput
                else
                    ESX.ShowNotification(_('createMenu_label_textInput_error_noInput'))
                end
            end
		end)

        local createMenuMaxRanksText = (CreateGangData.maxRanks or _('createMenu_undefined'))
        Items:AddButton(_("createMenu_maxRanks"), _("createMenu_maxRanks_description"), { IsDisabled = false, RightLabel = createMenuMaxRanksText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_maxRanks_textInput'), (CreateGangData.maxRanks or ""), 2)
                resultTextInput = tonumber(resultTextInput)
                if resultTextInput ~= nil then
                    if resultTextInput > 1 then
                        CreateGangData.maxRanks = resultTextInput
                    else
                        ESX.ShowNotification(_('createMenu_maxRanks_textInput_error_minNoRespect'))
                    end
                else
                    ESX.ShowNotification(_('createMenu_maxRanks_textInput_error_notNumber'))
                end
            end
		end)

        Items:AddSeparator(_("createMenu_separator_coords"))

        local createMenuInventoryText if CreateGangData.coords.inventory then createMenuInventoryText = _('createMenu_defined') else createMenuInventoryText = _('createMenu_undefined') end
        Items:AddButton(_("createMenu_coords_inventory"), _("createMenu_coords_inventory_description"), { IsDisabled = false, RightLabel = createMenuInventoryText }, function(s, a)
            if s then
                CreateMarkers.inventory = {pos = GetEntityCoords(ped), name = "Coffre"}
                CreateGangData.coords.inventory = GetEntityCoords(ped)
            end
		end)

        local createMenuGarageText if CreateGangData.coords.garageMenu then createMenuGarageText = _('createMenu_defined') else createMenuGarageText = _('createMenu_undefined') end
        Items:AddButton(_("createMenu_coords_garage"), _("createMenu_coords_garage_description"), { IsDisabled = false, RightLabel = createMenuGarageText }, function(s, a)
            if s then
                CreateMarkers.garageMenu = {pos = GetEntityCoords(ped), name = "Menu garage"}
                CreateGangData.coords.garageMenu = GetEntityCoords(ped)
            end
		end)

        local createMenuGarageSpawnText if CreateGangData.coords.garageSpawn then createMenuGarageSpawnText = _('createMenu_defined') else createMenuGarageSpawnText = _('createMenu_undefined') end
        Items:AddButton(_("createMenu_coords_garageSpawn"), _("createMenu_coords_garageSpawn_description"), { IsDisabled = false, RightLabel = createMenuGarageSpawnText }, function(s, a)
            if s then
                CreateMarkers.garageSpawn = {pos = GetEntityCoords(ped), name = "Sortie garage"}
                ESX.Game.DeleteVehicle(CreateVehicleEntity)
                ESX.Game.SpawnLocalVehicle("voodoo", GetEntityCoords(ped), GetEntityHeading(ped), function(vehicle)
                    CreateVehicleEntity = vehicle
                    SetEntityNoCollisionEntity(vehicle, ped, false)
                    SetEntityAlpha(vehicle, 102, false)
                    FreezeEntityPosition(vehicle, true)
                    SetVehicleDoorsLocked(vehicle, 2)
                    SetVehicleColours(vehicle, 0, 0)
                    SetVehicleNumberPlateText(vehicle, "MGDEV")
                end)
                CreateGangData.coords.garageSpawn = vec4(GetEntityCoords(ped), GetEntityHeading(ped))
            end
		end)

        local createMenuGarageStoreText if CreateGangData.coords.garageStore then createMenuGarageStoreText = _('createMenu_defined') else createMenuGarageStoreText = _('createMenu_undefined') end
        Items:AddButton(_("createMenu_coords_garageStore"), _("createMenu_coords_garageStore_description"), { IsDisabled = false, RightLabel = createMenuGarageStoreText }, function(s, a)
            if s then
                CreateMarkers.garageStore = {pos = GetEntityCoords(ped), name = "Rangement garage"}
                CreateGangData.coords.garageStore = GetEntityCoords(ped)
            end
		end)

        local createMenuBossText if CreateGangData.coords.boss then createMenuBossText = _('createMenu_defined') else createMenuBossText = _('createMenu_undefined') end
        Items:AddButton(_("createMenu_coords_boss"), _("createMenu_coords_boss_description"), { IsDisabled = false, RightLabel = createMenuBossText }, function(s, a)
            if s then
                CreateMarkers.boss = {pos = GetEntityCoords(ped), name = "Menu chef"}
                CreateGangData.coords.boss = GetEntityCoords(ped)
            end
		end)

        Items:AddSeparator(_("createMenu_separator_submit"))

        local createAccess = CheckAllDataDefined(CreateGangData)
        Items:AddButton(_("createMenu_create"), _("createMenu_create_description"), { IsDisabled = createAccess, RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:createGang', function(success, cbText)
                    if success then
                        ESX.Game.DeleteVehicle(CreateVehicleEntity)
                        CreateGangData, CreateMarkers = { coords = { garage = {} } }, {}
                        ESX.ShowNotification(cbText)
                        RageUI.GoBack()
                    else
                        ESX.ShowNotification(cbText)
                    end
                end, CreateGangData)
            end
		end)

        for k,data in pairs(CreateMarkers) do
            if k ~= "garageSpawn" then
                DrawMarker(1, data.pos.xy, data.pos.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, 32, 251, 149, 50, false, false, 2, false, nil, nil, false)
                ESX.Game.Utils.DrawText3D({x = data.pos.x, y = data.pos.y, z = data.pos.z}, data.name)
            else
                ESX.Game.Utils.DrawText3D({x = data.pos.x, y = data.pos.y, z = data.pos.z + 1.0}, data.name)
            end
        end
	end, function()
	end)

    ManageMenu:IsVisible(function(Items)
        ESX.Game.DeleteVehicle(ManageVehicleEntity)
        ManageGangData, ManageMarkers = { coords = { garage = {} } }, {}
        Items:AddList(_("manageMenu_select"), listLabelGangs, ManageSelectIndex, nil, { IsDisabled = false }, function(index, s, onListChange)
			if onListChange then
				ManageSelectIndex = index
			end
		end)
        if ManageSelectIndex > 1 then
            Items:AddList(_("manageMenu_teleportation"), {"Inventaire", "Garage", "Menu chef"}, TeleportationIndex, nil, { IsDisabled = false }, function(index, s, onListChange)
                if onListChange then
                    TeleportationIndex = index
                end
                if s then
                    local coords = GangsInfos[listNameGangs[ManageSelectIndex]].data.coords
                    if TeleportationIndex == 1 then SetEntityCoords(ped, coords.inventory.x, coords.inventory.y, coords.inventory.z) end
                    if TeleportationIndex == 2 then SetEntityCoords(ped, coords.garageMenu.x, coords.garageMenu.y, coords.garageMenu.z) end
                    if TeleportationIndex == 3 then SetEntityCoords(ped, coords.boss.x, coords.boss.y, coords.boss.z) end
                end
            end)
            Items:AddButton(_("manageMenu_edit"), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a) end, ManageSelectMenu)
            Items:AddButton(_("manageMenu_delete"), nil, { IsDisabled = false, RightBadge = RageUI.BadgeStyle.Alert }, function(s, a) end, DeleteConfirmationMenu)
        end
    end, function()
	end)

    ManageSelectMenu:IsVisible(function(Items)
        local selectGangData = GangsInfos[listNameGangs[ManageSelectIndex]]
        Items:AddSeparator(_("createMenu_separator_infos"))

		Items:AddButton(_("createMenu_name"), nil, { IsDisabled = false, LeftBadge = RageUI.BadgeStyle.Lock, RightLabel = selectGangData.name }, function(s, a) end)

        local manageSelectMenuLabelText = (ManageGangData.label or selectGangData.label)
        Items:AddButton(_("createMenu_label"), _("createMenu_label_description"), { IsDisabled = false, RightLabel = manageSelectMenuLabelText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_label_textInput'), (ManageGangData.label or selectGangData.label), 50)
                if resultTextInput ~= nil and #resultTextInput > 0 then
                    ManageGangData.label = resultTextInput
                else
                    ESX.ShowNotification(_('createMenu_label_textInput_error_noInput'))
                end
            end
		end)

        local manageSelectMenuMaxRanksText = (ManageGangData.maxRanks or selectGangData.data.maxRanks)
        Items:AddButton(_("createMenu_maxRanks"), _("manageSelectMenu_maxRanks_description"), { IsDisabled = false, RightLabel = manageSelectMenuMaxRanksText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_maxRanks_textInput'), (ManageGangData.maxRanks or selectGangData.maxRanks), 2)
                resultTextInput = tonumber(resultTextInput)
                if resultTextInput ~= nil then
                    if resultTextInput > 1 then
                        ManageGangData.maxRanks = resultTextInput
                    else
                        ESX.ShowNotification(_('createMenu_maxRanks_textInput_error_minNoRespect'))
                    end
                else
                    ESX.ShowNotification(_('createMenu_maxRanks_textInput_error_notNumber'))
                end
            end
		end)

        Items:AddSeparator(_("createMenu_separator_coords"))

        local manageSelectMenuInventoryText if ManageGangData.coords.inventory then manageSelectMenuInventoryText = _('createMenu_defined') end
        Items:AddButton(_("createMenu_coords_inventory"), _("createMenu_coords_inventory_description"), { IsDisabled = false, RightLabel = manageSelectMenuInventoryText }, function(s, a)
            if s then
                ManageMarkers.inventory = {pos = GetEntityCoords(ped), name = "Coffre"}
                ManageGangData.coords.inventory = GetEntityCoords(ped)
            end
		end)

        local manageSelectMenuGarageText if ManageGangData.coords.garageMenu then manageSelectMenuGarageText = _('createMenu_defined') end
        Items:AddButton(_("createMenu_coords_garage"), _("createMenu_coords_garage_description"), { IsDisabled = false, RightLabel = manageSelectMenuGarageText }, function(s, a)
            if s then
                ManageMarkers.garageMenu = {pos = GetEntityCoords(ped), name = "Menu garage"}
                ManageGangData.coords.garageMenu = GetEntityCoords(ped)
            end
		end)

        local manageSelectMenuGarageSpawnText if ManageGangData.coords.garageSpawn then manageSelectMenuGarageSpawnText = _('createMenu_defined') end
        Items:AddButton(_("createMenu_coords_garageSpawn"), _("createMenu_coords_garageSpawn_description"), { IsDisabled = false, RightLabel = manageSelectMenuGarageSpawnText }, function(s, a)
            if s then
                ManageMarkers.garageSpawn = {pos = GetEntityCoords(ped), name = "Sortie garage"}
                ESX.Game.DeleteVehicle(ManageVehicleEntity)
                ESX.Game.SpawnLocalVehicle("voodoo", GetEntityCoords(ped), GetEntityHeading(ped), function(vehicle)
                    ManageVehicleEntity = vehicle
                    SetEntityNoCollisionEntity(vehicle, ped, false)
                    SetEntityAlpha(vehicle, 102, false)
                    FreezeEntityPosition(vehicle, true)
                    SetVehicleDoorsLocked(vehicle, 2)
                    SetVehicleColours(vehicle, 0, 0)
                    SetVehicleNumberPlateText(vehicle, "MGDEV")
                end)
                ManageGangData.coords.garageSpawn = vec4(GetEntityCoords(ped), GetEntityHeading(ped))
            end
		end)

        local manageSelectMenuGarageStoreText if ManageGangData.coords.garageStore then manageSelectMenuGarageStoreText = _('createMenu_defined') end
        Items:AddButton(_("createMenu_coords_garageStore"), _("createMenu_coords_garageStore_description"), { IsDisabled = false, RightLabel = manageSelectMenuGarageStoreText }, function(s, a)
            if s then
                ManageMarkers.garageStore = {pos = GetEntityCoords(ped), name = "Rangement garage"}
                ManageGangData.coords.garageStore = GetEntityCoords(ped)
            end
		end)

        local manageSelectMenuBossText if ManageGangData.coords.boss then manageSelectMenuBossText = _('createMenu_defined') end
        Items:AddButton(_("createMenu_coords_boss"), _("createMenu_coords_boss_description"), { IsDisabled = false, RightLabel = manageSelectMenuBossText }, function(s, a)
            if s then
                ManageMarkers.boss = {pos = GetEntityCoords(ped), name = "Menu chef"}
                ManageGangData.coords.boss = GetEntityCoords(ped)
            end
		end)

        Items:AddSeparator(_("createMenu_separator_submit"))

        Items:AddButton(_("manageSelect_submit"), _("manageSelect_submit_description"), { IsDisabled = false, RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:editGang', function(success, cbText)
                    if success then
                        ESX.Game.DeleteVehicle(ManageVehicleEntity)
                        ManageGangData, ManageMarkers = { coords = {} }, {}
                        ESX.ShowNotification(cbText)
                        RageUI.GoBack()
                    else
                        ESX.ShowNotification(cbText)
                    end
                end, ManageGangData, selectGangData)
            end
		end)

        for k,data in pairs(ManageMarkers) do
            if k ~= "garageSpawn" then
                DrawMarker(1, data.pos.xy, data.pos.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, Config.Markers.r, Config.Markers.g, Config.Markers.b, Config.Markers.a, false, false, 2, false, nil, nil, false)
                ESX.Game.Utils.DrawText3D({x = data.pos.x, y = data.pos.y, z = data.pos.z}, data.name)
            else
                ESX.Game.Utils.DrawText3D({x = data.pos.x, y = data.pos.y, z = data.pos.z + 1.0}, data.name)
            end
        end
    end, function()
    end)

    DeleteConfirmationMenu:IsVisible(function(Items)
        Items:AddButton(_("deleteConfirmationMenu_cancel"), nil, { IsDisabled = false }, function(s, a) end)
        Items:AddButton(_("deleteConfirmationMenu_delete"), nil, { IsDisabled = false, RightBadge = RageUI.BadgeStyle.Alert }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:deleteGang', function(success, cbText)
                    if success then
                        ManageSelectIndex = 1
                        RageUI.GoBack()
                        ESX.ShowNotification(cbText)
                    else
                        ESX.ShowNotification(cbText)
                    end
                end, listNameGangs[ManageSelectIndex])
            end
        end)
    end, function()
    end)
end

function CheckAllDataDefined(tab)
    if tab.name and tab.label and tab.maxRanks and tab.coords.inventory and tab.coords.garageMenu and tab.coords.garageSpawn and tab.coords.garageStore and tab.coords.boss then
        return false
    else
        return true
    end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        ESX.Game.DeleteVehicle(CreateVehicleEntity)
        ESX.Game.DeleteVehicle(ManageVehicleEntity)
	end
end)

RegisterNetEvent('mgd_gangbuilder:openCreateMenu')
AddEventHandler('mgd_gangbuilder:openCreateMenu', function()
    RageUI.Visible(MainMenu, not RageUI.Visible(MainMenu))
end)