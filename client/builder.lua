local GangsList = { name = { '' }, label = { '' } }

local MainMenu = RageUI.CreateMenu(_("mainMenu_title"), _("mainMenu_subtitle"))

local CreateMenu = RageUI.CreateSubMenu(MainMenu, _("createMenu_title"), _("createMenu_subtitle"))
local CreateGangData, CreateVehiclePreviewData = { coords = {} }, nil
local createMenuNameText, createMenuLabelText, createMenuInventoryText, createMenuGarageText, createMenuGarageSpawnText, createMenuGarageStoreText, createMenuBossText = _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined')

local ManageMenu = RageUI.CreateSubMenu(MainMenu, _("manageMenu_title"), _("manageMenu_subtitle"))
local ManageSelectMenu = RageUI.CreateSubMenu(ManageMenu, _("manageSelectMenu_title"), _("manageSelectMenu_subtitle"))
local DeleteConfirmationMenu = RageUI.CreateSubMenu(ManageMenu, _("deleteConfirmationMenu_title"), _("deleteConfirmationMenu_subtitle"))
local TeleportationIndex, ManageSelectIndex, ManageVehiclePreviewData, ManageGangData = 1, 1, nil, { coords = {} }

local function RefreshGangsList()
    GangsList = { name = { '' }, label = { '' } }

    for k,v in pairs(GlobalState['mgd_gangbuilder']) do
        if v.name ~= 'none' then
            table.insert(GangsList.name, v.name)
            table.insert(GangsList.label, v.label)
        end
    end
end

local function SpawnLocalVehiclePreview(coords, heading, createMenu)
    ESX.Game.SpawnLocalVehicle("voodoo", coords, heading, function(vehicle)
        SetEntityNoCollisionEntity(vehicle, ped, false)
        SetEntityAlpha(vehicle, 102, false)
        FreezeEntityPosition(vehicle, true)
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleColours(vehicle, 0, 0)
        SetVehicleNumberPlateText(vehicle, "MGDEV")

        if createMenu then
            CreateVehiclePreviewData = vehicle
        else
            ManageVehiclePreviewData = vehicle
        end
    end)
end

local function CheckAllDataDefined(tab)
    if tab.name and tab.label and tab.maxRanks and tab.coords.inventory and tab.coords.garageMenu and tab.coords.garageSpawn and tab.coords.garageStore and tab.coords.boss then
        return false
    else
        return true
    end
end

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
    while GlobalState['mgd_gangbuilder'] == nil do Citizen.Wait(500) end

    RefreshGangsList()
end)

function RageUI.PoolMenus:MGDGangBuilder_Builder()
    MainMenu:IsVisible(function(Items)
        if CreateVehiclePreviewData then ESX.Game.DeleteVehicle(CreateVehiclePreviewData) end

        Items:AddButton(_("mainMenu_toCreateMenu"), nil, {  RightLabel = "→" }, function(s, a)
            if s then
                if CreateGangData.coords.garageSpawn then
                    SpawnLocalVehiclePreview(CreateGangData.coords.garageSpawn.xyz, CreateGangData.coords.garageSpawn.w, true)
                end
            end
        end, CreateMenu)
        Items:AddButton(_("mainMenu_toManageMenu"), nil, {  RightLabel = "→" }, function(s, a)
            if s then
                RefreshGangsList()
            end
        end, ManageMenu)
    end, function()
    end)

    CreateMenu:IsVisible(function(Items)
        Items:AddSeparator(_("createMenu_separator_infos"))

        Items:AddButton(_("createMenu_name"), _("createMenu_name_description"), { RightLabel = createMenuNameText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_name_textInput'), (CreateGangData.name or ""), 50)
                resultTextInput = string.lower(resultTextInput)

                if resultTextInput ~= nil and #resultTextInput > 0 then
                    if GlobalState['mgd_gangbuilder'][resultTextInput] then
                        lib.notify({
                            title = _('notify_title_error'),
                            description = _('createMenu_name_textInput_error_gangNameAlreadyExist', resultTextInput),
                            type = 'error',
                            duration = 6000
                        })
                    else
                        if #resultTextInput > 25 then createMenuNameText = _('createMenu_defined') else createMenuNameText = resultTextInput end
                        CreateGangData.name = resultTextInput
                    end
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('createMenu_name_textInput_error_noInput'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)

        Items:AddButton(_("createMenu_label"), _("createMenu_label_description"), { RightLabel = createMenuLabelText }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_label_textInput'), (CreateGangData.label or ""), 50)

                if resultTextInput ~= nil and #resultTextInput > 0 then
                    if #resultTextInput > 25 then createMenuLabelText = _('createMenu_defined') else createMenuLabelText = resultTextInput end
                    CreateGangData.label = resultTextInput
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('createMenu_label_textInput_error_noInput'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)

        Items:AddButton(_("createMenu_maxRanks"), _("createMenu_maxRanks_description"), { RightLabel = (CreateGangData.maxRanks or _('createMenu_undefined')) }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_maxRanks_textInput'), (CreateGangData.maxRanks or ""), 2)
                resultTextInput = tonumber(resultTextInput)

                if resultTextInput ~= nil then
                    if resultTextInput < 2 then
                        resultTextInput = 2
                    end

                    CreateGangData.maxRanks = resultTextInput
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('createMenu_maxRanks_textInput_error_notNumber'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)

        Items:AddSeparator(_("createMenu_separator_coords"))

        Items:AddButton(_("createMenu_coords_inventory"), _("createMenu_coords_inventory_description"), { RightLabel = createMenuInventoryText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                createMenuInventoryText = _('createMenu_defined')

                CreateGangData.coords.inventory = coords
            end
        end)

        Items:AddButton(_("createMenu_coords_garage"), _("createMenu_coords_garage_description"), { RightLabel = createMenuGarageText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                createMenuGarageText = _('createMenu_defined')

                CreateGangData.coords.garageMenu = coords
            end
        end)

        Items:AddButton(_("createMenu_coords_garageSpawn"), _("createMenu_coords_garageSpawn_description"), { RightLabel = createMenuGarageSpawnText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                createMenuGarageSpawnText = _('createMenu_defined')

                if CreateVehiclePreviewData then ESX.Game.DeleteVehicle(CreateVehiclePreviewData) end
                SpawnLocalVehiclePreview(coords, heading, true)

                CreateGangData.coords.garageSpawn = vec4(coords, heading)
            end
        end)

        Items:AddButton(_("createMenu_coords_garageStore"), _("createMenu_coords_garageStore_description"), { RightLabel = createMenuGarageStoreText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                createMenuGarageStoreText = _('createMenu_defined')

                CreateGangData.coords.garageStore = coords
            end
        end)

        Items:AddButton(_("createMenu_coords_boss"), _("createMenu_coords_boss_description"), { RightLabel = createMenuBossText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                createMenuBossText = _('createMenu_defined')

                CreateGangData.coords.boss = coords
            end
        end)

        Items:AddSeparator(_("createMenu_separator_submit"))

        Items:AddButton(_("createMenu_create"), _("createMenu_create_description"), { IsDisabled = CheckAllDataDefined(CreateGangData), RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:createGang', function(success, cbText, msgType)
                    if success then
                        if CreateVehiclePreviewData then ESX.Game.DeleteVehicle(CreateVehiclePreviewData) end
                        CreateGangData = { coords = {} }
                        createMenuNameText, createMenuLabelText, createMenuInventoryText, createMenuGarageText, createMenuGarageSpawnText, createMenuGarageStoreText, createMenuBossText = _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined'), _('createMenu_undefined')
                        RageUI.GoBack()
                    end

                    lib.notify({
                        title = _('notify_title_'.. msgType),
                        description = cbText,
                        type = msgType,
                        duration = 6000
                    })
                end, CreateGangData)
            end
        end)
        
        for k,data in pairs(CreateGangData.coords) do
            if k ~= "garageSpawn" then
                DrawMarker(1, data.xy, data.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, 32, 251, 149, 50, false, false, 2, false, nil, nil, false)
                ESX.Game.Utils.DrawText3D({x = data.x, y = data.y, z = data.z}, _(k))
            else
                ESX.Game.Utils.DrawText3D({x = data.x, y = data.y, z = data.z + 1.0}, _(k))
            end
        end

    end, function()
    end)

    ManageMenu:IsVisible(function(Items)
        if ManageVehiclePreviewData then ESX.Game.DeleteVehicle(ManageVehiclePreviewData) end
        ManageGangData, ManageMarkers = { coords = {} }, {}
        Items:AddList(_("manageMenu_select"), GangsList.label, ManageSelectIndex, nil, {}, function(index, s, onListChange)
            if onListChange then
                ManageSelectIndex = index
            end
        end)
        if ManageSelectIndex > 1 then
            Items:AddList(_("manageMenu_teleportation"), {_('inventory'), _('garageMenu'), _('boss')}, TeleportationIndex, nil, {}, function(index, s, onListChange)
                if onListChange then
                    TeleportationIndex = index
                end
                if s then
                    local coords = GlobalState['mgd_gangbuilder'][GangsList.name[ManageSelectIndex]].data.coords
                    local ped = PlayerPedId()
                    if TeleportationIndex == 1 then
                        SetEntityCoords(ped, coords.inventory.x, coords.inventory.y, coords.inventory.z)
                    end
                    if TeleportationIndex == 2 then
                        SetEntityCoords(ped, coords.garageMenu.x, coords.garageMenu.y, coords.garageMenu.z)
                    end
                    if TeleportationIndex == 3 then
                        SetEntityCoords(ped, coords.boss.x, coords.boss.y, coords.boss.z)
                    end
                end
            end)
            Items:AddButton(_("manageMenu_edit"), nil, { RightLabel = "→" }, function(s, a) end, ManageSelectMenu)
            Items:AddButton(_("manageMenu_delete"), nil, { RightBadge = RageUI.BadgeStyle.Alert }, function(s, a) end, DeleteConfirmationMenu)
        end
    end, function()
    end)

    ManageSelectMenu:IsVisible(function(Items)
        local selectGangData = GlobalState['mgd_gangbuilder'][GangsList.name[ManageSelectIndex]]
        Items:AddSeparator(_("createMenu_separator_infos"))

        Items:AddButton(_("createMenu_name"), nil, { LeftBadge = RageUI.BadgeStyle.Lock, RightLabel = selectGangData.name }, function(s, a) end)

        Items:AddButton(_("createMenu_label"), _("createMenu_label_description"), { RightLabel = (ManageGangData.label or selectGangData.label) }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_label_textInput'), (ManageGangData.label or selectGangData.label), 50)

                if resultTextInput ~= nil and #resultTextInput > 0 then
                    ManageGangData.label = resultTextInput
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('createMenu_label_textInput_error_noInput'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)

        Items:AddButton(_("createMenu_maxRanks"), _("manageSelectMenu_maxRanks_description"), { RightLabel = (ManageGangData.maxRanks or selectGangData.data.maxRanks) }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('createMenu_maxRanks_textInput'), (ManageGangData.maxRanks or selectGangData.maxRanks), 2)
                resultTextInput = tonumber(resultTextInput)

                if resultTextInput ~= nil then
                    if resultTextInput < 2 then
                        resultTextInput = 2
                    end

                    ManageGangData.maxRanks = resultTextInput
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('createMenu_maxRanks_textInput_error_notNumber'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)

        Items:AddSeparator(_("createMenu_separator_coords"))

        local manageSelectMenuInventoryText if ManageGangData.coords.inventory then manageSelectMenuInventoryText = _('manageSelect_reDefined') end
        Items:AddButton(_("createMenu_coords_inventory"), _("createMenu_coords_inventory_description"), { RightLabel = manageSelectMenuInventoryText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)

                ManageGangData.coords.inventory = coords
            end
        end)

        local manageSelectMenuGarageText if ManageGangData.coords.garageMenu then manageSelectMenuGarageText = _('manageSelect_reDefined') end
        Items:AddButton(_("createMenu_coords_garage"), _("createMenu_coords_garage_description"), { RightLabel = manageSelectMenuGarageText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)

                ManageGangData.coords.garageMenu = coords
            end
        end)

        local manageSelectMenuGarageSpawnText if ManageGangData.coords.garageSpawn then manageSelectMenuGarageSpawnText = _('manageSelect_reDefined') end
        Items:AddButton(_("createMenu_coords_garageSpawn"), _("createMenu_coords_garageSpawn_description"), { RightLabel = manageSelectMenuGarageSpawnText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)

                if ManageVehiclePreviewData then ESX.Game.DeleteVehicle(ManageVehiclePreviewData) end
                SpawnLocalVehiclePreview(coords, heading, false)

                ManageGangData.coords.garageSpawn = vec4(coords, heading)
            end
        end)

        local manageSelectMenuGarageStoreText if ManageGangData.coords.garageStore then manageSelectMenuGarageStoreText = _('manageSelect_reDefined') end
        Items:AddButton(_("createMenu_coords_garageStore"), _("createMenu_coords_garageStore_description"), { RightLabel = manageSelectMenuGarageStoreText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)

                ManageGangData.coords.garageStore = coords
            end
        end)

        local manageSelectMenuBossText if ManageGangData.coords.boss then manageSelectMenuBossText = _('manageSelect_reDefined') end
        Items:AddButton(_("createMenu_coords_boss"), _("createMenu_coords_boss_description"), { RightLabel = manageSelectMenuBossText }, function(s, a)
            if s then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)

                ManageGangData.coords.boss = coords
            end
        end)

        Items:AddSeparator(_("createMenu_separator_submit"))

        Items:AddButton(_("manageSelect_submit"), _("manageSelect_submit_description"), { RightLabel = "→" }, function(s, a)
            if s then
                selectGangData = GlobalState['mgd_gangbuilder'][GangsList.name[ManageSelectIndex]]
                ESX.TriggerServerCallback('mgd_gangbuilder:editGang', function(success, cbText, msgType)
                    if success then
                        if ManageVehiclePreviewData then ESX.Game.DeleteVehicle(ManageVehiclePreviewData) end
                        ManageGangData = { coords = {} }
                        RageUI.GoBack()
                    end

                    lib.notify({
                        title = _('notify_title_'.. msgType),
                        description = cbText,
                        type = msgType,
                        duration = 6000
                    })
                end, ManageGangData, selectGangData)
            end
        end)

        for k,data in pairs(ManageGangData.coords) do
            if k ~= "garageSpawn" then
                DrawMarker(1, data.xy, data.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.7, 32, 251, 149, 50, false, false, 2, false, nil, nil, false)
                ESX.Game.Utils.DrawText3D({x = data.x, y = data.y, z = data.z}, _(k))
            else
                ESX.Game.Utils.DrawText3D({x = data.x, y = data.y, z = data.z + 1.0}, _(k))
            end
        end
    end, function()
    end)

    DeleteConfirmationMenu:IsVisible(function(Items)
        Items:AddButton(_("deleteConfirmationMenu_cancel"), nil, {}, function(s, a)
            if s then
                RageUI.GoBack()
            end
        end)
        Items:AddButton(_("deleteConfirmationMenu_delete"), nil, { RightBadge = RageUI.BadgeStyle.Alert }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:deleteGang', function(success, cbText, msgType)
                    if success then
                        ManageSelectIndex = 1
                        Citizen.Wait(100)
                        RefreshGangsList()
                        RageUI.GoBack()
                    end

                    lib.notify({
                        title = _('notify_title_'.. msgType),
                        description = cbText,
                        type = msgType,
                        duration = 6000
                    })
                end, GangsList.name[ManageSelectIndex])
            end
        end)
    end, function()
    end)
end 

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return end

    if CreateVehiclePreviewData then ESX.Game.DeleteVehicle(CreateVehiclePreviewData) end
    if ManageVehiclePreviewData then ESX.Game.DeleteVehicle(ManageVehiclePreviewData) end
end)

RegisterNetEvent('mgd_gangbuilder:openCreateMenu')
AddEventHandler('mgd_gangbuilder:openCreateMenu', function()
    RageUI.Visible(MainMenu, not RageUI.Visible(MainMenu))
end)