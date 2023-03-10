local MainMenu = RageUI.CreateMenu(_("inventoryMenu_title"), "")
local InventoryMenu = RageUI.CreateSubMenu(MainMenu, _("inventoryMenu_title"), "")
local PlayerInventoryMenu = RageUI.CreateSubMenu(MainMenu, _("inventoryMenu_pInventory_title"), "")
local InventorySelectIndex, PlayerInventorySelectIndex, refreshAccess = 1, 1, false
local Inventory = {}
local WeaponsList

function RageUI.PoolMenus:MGDGangBuilder_Inventory()
    local ped = PlayerPedId()

    MainMenu:IsVisible(function(Items)
        Items:AddButton(_('inventoryMenu_put'), nil, { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_inventory_put"], RightLabel = "→" }, function(s, a) end, PlayerInventoryMenu)
        Items:AddButton(_('inventoryMenu_take'), nil, { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_inventory_take"], RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback("mgd_gangbuilder:getInventory", function(result)
                    Inventory = result
                end)
            end
        end, InventoryMenu)
    end, function()
    end)

	InventoryMenu:IsVisible(function(Items)
        Items:AddButton(_('inventoryMenu_refresh'), nil, { IsDisabled = refreshAccess, RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback("mgd_gangbuilder:getInventory", function(result)
                    Inventory = result
                end)
                refreshAccess = true
                Citizen.SetTimeout(5000, function()
                    refreshAccess = false
                end)                  
            end
        end)
        Items:AddList(_("inventoryMenu_select"), {"-", "Items", "Armes", "Argent"}, InventorySelectIndex, nil, { IsDisabled = false }, function(index, s, onListChange)
			if onListChange then
				InventorySelectIndex = index
			end
		end)
        if InventorySelectIndex > 1 then
            for k,v in pairs(Inventory) do
                if (k == "items" and InventorySelectIndex == 2 and #v > 0) or (k == "weapons" and InventorySelectIndex == 3 and #v > 0) or (k == "accounts" and InventorySelectIndex == 4 and #v > 0) then
                    for i=1, #v, 1 do
                        local rLabel = GetRightLabelInventoryFormat(k, v[i].count)
                        Items:AddButton(v[i].label, nil, { IsDisabled = false, RightLabel = rLabel }, function(s, a)
                            if s then
                                local quantity = 0
                                if k == "items" or k == "accounts" then
                                    quantity = TextInput(_('inventoryMenu_textInput_quantity_take', v[i].count), "", 10)
                                    quantity = tonumber(quantity)
                                    if quantity ~= nil then
                                        if quantity > 0 then
                                            ESX.TriggerServerCallback("mgd_gangbuilder:takeFromInventory", function(success, cbText)
                                                if success then
                                                    ESX.TriggerServerCallback("mgd_gangbuilder:getInventory", function(result)
                                                        Inventory = result
                                                        RageUI.CloseAll()
                                                        RageUI.Visible(InventoryMenu, not RageUI.Visible(InventoryMenu))
                                                    end)
                                                end
                                                ESX.ShowNotification(cbText)
                                            end, k, v[i].name, quantity)
                                        else
                                            ESX.ShowNotification(_('inventoryMenu_textInput_error_minNoRespect'))
                                        end
                                    else
                                        ESX.ShowNotification(_('inventoryMenu_textInput_error_notNumber'))
                                    end
                                end
                                if k == "weapons" then
                                    ESX.TriggerServerCallback("mgd_gangbuilder:takeFromInventory", function(success, cbText)
                                        if success then
                                            ESX.TriggerServerCallback("mgd_gangbuilder:getInventory", function(result)
                                                Inventory = result
                                                RageUI.CloseAll()
                                                RageUI.Visible(InventoryMenu, not RageUI.Visible(InventoryMenu))
                                            end)
                                        end
                                        ESX.ShowNotification(cbText)
                                    end, k, v[i].name, v[i].count)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end, function()
	end)

    PlayerInventoryMenu:IsVisible(function(Items)
        Items:AddList(_("inventoryMenu_select"), {"-", "Items", "Armes", "Argent"}, PlayerInventorySelectIndex, nil, { IsDisabled = false }, function(index, s, onListChange)
			if onListChange then
				PlayerInventorySelectIndex = index
			end
		end)
        if PlayerInventorySelectIndex > 1 then
            if PlayerInventorySelectIndex == 2 then
                for k,v in pairs(ESX.GetPlayerData().inventory) do
                    if v.count > 0 then
                        Items:AddButton(v.label, nil, { IsDisabled = false, RightLabel = v.count }, function(s, a)
                            if s then
                                local quantity = TextInput(_('inventoryMenu_textInput_quantity_put', v.count), "", 10)
                                quantity = tonumber(quantity)
                                if quantity ~= nil then
                                    if quantity > 0 then
                                        ESX.TriggerServerCallback("mgd_gangbuilder:putInInventory", function(success, cbText)
                                            ESX.ShowNotification(cbText)
                                        end, "items", v.name, v.label, quantity)
                                    else
                                        ESX.ShowNotification(_('inventoryMenu_textInput_error_minNoRespect'))
                                    end
                                else
                                    ESX.ShowNotification(_('inventoryMenu_textInput_error_notNumber'))
                                end
                            end
                        end)
                    end
                end
            end
            if PlayerInventorySelectIndex == 3 then
                for k, v in ipairs(WeaponsList) do
                    local weaponHash = GetHashKey(v.name)
                    local rLabel = ""
                    local putLabel = v.label
                    if HasPedGotWeapon(ped, weaponHash, false) then
                        local ammo, label = GetAmmoInPedWeapon(ped, weaponHash)
            
                        if v.ammo then
                            rLabel = ammo .." ".. v.ammo.label
                            putLabel = putLabel .. " " .. ammo .." ".. v.ammo.label
                        else
                            ammo = 1
                        end

                        Items:AddButton(v.label, nil, { IsDisabled = false, RightLabel = rLabel }, function(s, a)
                            if s then
                                ESX.TriggerServerCallback("mgd_gangbuilder:putInInventory", function(success, cbText)
                                    ESX.ShowNotification(cbText)
                                end, "weapons", v.name, putLabel, ammo)
                            end
                        end)
                    end
                end
            end
            if PlayerInventorySelectIndex == 4 then
                for i = 1, #(ESX.GetPlayerData().accounts), 1 do
                    if ESX.PlayerData.accounts[i].name ~= 'bank' then            
                        Items:AddButton(ESX.PlayerData.accounts[i].label, nil, { IsDisabled = false, RightLabel = "~g~" .. ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).. "$"}, function(s, a)
                            if s then
                                local quantity = TextInput(_('inventoryMenu_textInput_quantity_put', ESX.PlayerData.accounts[i].money), "", 10)
                                quantity = tonumber(quantity)
                                if quantity ~= nil then
                                    if quantity > 0 then
                                        ESX.TriggerServerCallback("mgd_gangbuilder:putInInventory", function(success, cbText)
                                            ESX.ShowNotification(cbText)
                                        end, "accounts", ESX.PlayerData.accounts[i].name, ESX.PlayerData.accounts[i].label, quantity)
                                    else
                                        ESX.ShowNotification(_('inventoryMenu_textInput_error_minNoRespect'))
                                    end
                                else
                                    ESX.ShowNotification(_('inventoryMenu_textInput_error_notNumber'))
                                end
                            end
                        end)
                    end
                end
            end
        end
    end, function()
	end)
end

function GetRightLabelInventoryFormat(categorie, quantity)
    if categorie == "items" then
        return "x".. quantity
    end
    if categorie == "weapons" then
        return ""
    end
    if categorie == "accounts" then
        return "~g~".. ESX.Math.GroupDigits(quantity) .."$"
    end
end

RegisterNetEvent('mgd_gangbuilder:openInventoryMenu')
AddEventHandler('mgd_gangbuilder:openInventoryMenu', function()
    MainMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    InventoryMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    PlayerInventoryMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    WeaponsList = ESX.GetWeaponList()
    RageUI.Visible(MainMenu, not RageUI.Visible(MainMenu))
end)