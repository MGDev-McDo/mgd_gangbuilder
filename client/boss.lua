local BossMenu = RageUI.CreateMenu(_("bossMenu_title"), "")
local MMembersMenu = RageUI.CreateSubMenu(BossMenu, _('mMembersMenu_title'), "")
local MMembersMenuInvite = RageUI.CreateSubMenu(MMembersMenu, _('mMembersMenuInvite_title'), "")
local MMembersMenuSelected = RageUI.CreateSubMenu(MMembersMenu, _('mMembersMenuSelected_title'), "")
local MMembersMenuSelectedSetGrade = RageUI.CreateSubMenu(MMembersMenuSelected, _('mMembersMenuSelectedSetGrade_title'), _('mMembersMenuSelected_manageGrade'))
local MRanksMenu = RageUI.CreateSubMenu(BossMenu, _('mRanksMenu_title'), "")
local MRanksMenuSelected = RageUI.CreateSubMenu(MRanksMenu, _('mRanksMenuSelected_title'), "")
local DeleteConfirmationMenu = RageUI.CreateSubMenu(MRanksMenuSelected, _("deleteConfirmationMenu_title"), _("deleteConfirmationMenu_subtitle"))
local SelectedGradeName, SelectedGradeNameForPerm, MembersList, refreshAccess, SelectedIdentifier = "", "", {}, false, ""
local MPermissionsMenu = RageUI.CreateSubMenu(BossMenu, _('mPermMenu_title'), "")
local MPermissionsMenuSelected = RageUI.CreateSubMenu(MPermissionsMenu, _('mPermMenuSelected_title'), "")

function RageUI.PoolMenus:MGDGangBuilder_Boss()
    local ped = PlayerPedId()
	BossMenu:IsVisible(function(Items)
        Items:AddButton(_('bossMenu_manageMembers'), _('bossMenu_manageMembers_description'), { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_manage_members"], RightLabel = "→" }, function(s, a)
            if s then
                SelectedIdentifier = ""
                ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                    MembersList = members
                end, ESX.PlayerData.gang.name)
            end
        end, MMembersMenu)
        Items:AddButton(_('bossMenu_manageRanks'), _('bossMenu_manageRanks_description'), { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_manage_ranks"], RightLabel = "→" }, function(s, a) end, MRanksMenu)
        Items:AddButton(_('bossMenu_managePermissions'), _('bossMenu_managePermissions_description'), { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_manage_permissions"], RightLabel = "→" }, function(s, a) end, MPermissionsMenu)
    end, function()
	end)

    MMembersMenu:IsVisible(function(Items)
        Items:AddButton(_('mMembersMenu_invite'), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('mMembersMenu_invite_textInput'), "", 5)
                resultTextInput = tonumber(resultTextInput)
                if resultTextInput ~= nil then
                    ESX.TriggerServerCallback('mgd_gangbuilder:invite', function(success, cbText)
                        if success then
                            ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                                MembersList = members
                            end, ESX.PlayerData.gang.name)
                            ESX.ShowNotification(cbText)
                        else
                            ESX.ShowNotification(cbText)
                        end
                    end, resultTextInput)
                else
                    ESX.ShowNotification(_('mMembersMenu_invite_textInput_error_notNumber'))
                end
            end
        end)
        Items:AddButton(_('mMembersMenu_refresh'), nil, { IsDisabled = refreshAccess, RightLabel = "→" }, function(s, a)
            if s then
                SelectedIdentifier = ""
                ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                    MembersList = members
                end, ESX.PlayerData.gang.name)
                refreshAccess = true
                Citizen.SetTimeout(5000, function()
                    refreshAccess = false
                end)                  
            end
        end)
        for i = 1, #MembersList, 1 do
            Items:AddButton(MembersList[i].firstname .. " " .. MembersList[i].lastname, nil, { IsDisabled = false, RightLabel = MembersList[i].label }, function(s, a)
                if s then
                    MMembersMenuSelected:SetSubtitle(MembersList[i].firstname .. " " .. MembersList[i].lastname)
                    SelectedIdentifier = MembersList[i].identifier          
                end
            end, MMembersMenuSelected)
        end
    end, function()
    end)

    MMembersMenuSelected:IsVisible(function(Items)
        Items:AddButton(_('mMembersMenuSelected_manageGrade'), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a) end, MMembersMenuSelectedSetGrade)
        Items:AddButton(_('mMembersMenuSelected_fire'), nil, { IsDisabled = false, RightBadge = RageUI.BadgeStyle.Alert }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:fire', function(success, cbText)
                    if success then
                        ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                            MembersList = members
                        end, ESX.PlayerData.gang.name)
                        SelectedIdentifier = ""
                        RageUI.GoBack()
                    end
                    ESX.ShowNotification(cbText)
                end, SelectedIdentifier)          
            end
        end)
    end, function()
    end)

    MMembersMenuSelectedSetGrade:IsVisible(function(Items)
        for k,v in pairs(GangsInfos[ESX.PlayerData.gang.name].grades) do
            Items:AddButton('('.. v.grade .. ') ' ..v.label, nil, { IsDisabled = false, RightLabel = "→" }, function(s, a)
                if s then
                    ESX.TriggerServerCallback('mgd_gangbuilder:changeGrade', function(success, cbText)
                        if success then
                            ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                                MembersList = members
                            end, ESX.PlayerData.gang.name)
                            RageUI.GoBack()
                        end
                        ESX.ShowNotification(cbText)
                    end, SelectedIdentifier, v.grade, v.label)
                end
            end)
        end
    end, function()
    end)

    MRanksMenu:IsVisible(function(Items)
        local addLock = false
        local addDescription = nil
        local numberOfGrades = tablelength(GangsInfos[ESX.PlayerData.gang.name].grades)
        if numberOfGrades >= GangsInfos[ESX.PlayerData.gang.name].data.maxRanks then
            addLock = true
            addDescription = _('mRanksMenu_addLock', numberOfGrades, GangsInfos[ESX.PlayerData.gang.name].data.maxRanks)
        end

        Items:AddButton(_('mRanksMenu_addGrade'), addDescription, { IsDisabled = addLock, RightLabel = "→" }, function(s, a)
            if s then
                local labelInput = TextInput(_('mRanksMenu_addGrade_textInput'), "", 50)
                if labelInput ~= nil and #labelInput > 0 then
                    ESX.TriggerServerCallback("mgd_gangbuilder:getFreeGrade", function(successF, cbFText, gradeID, gradeName)
                        if successF then
                            ESX.TriggerServerCallback("mgd_gangbuilder:createGrade", function(success, cbText)
                                ESX.ShowNotification(cbText)
                            end, labelInput, gradeID, gradeName)
                        else
                            ESX.ShowNotification(cbFText)
                        end
                    end)
                else
                    ESX.ShowNotification(_('mRanksMenu_addGrade_textInput_error_noInput'))
                end
            end
        end)

        for k,v in pairs(GangsInfos[ESX.PlayerData.gang.name].grades) do
            Items:AddButton('('.. v.grade ..') '.. v.label, nil, { IsDisabled = false, RightLabel = "→" }, function(s, a)
                if s then
                    MRanksMenuSelected:SetSubtitle('('.. v.grade ..') '.. v.label)
                    SelectedGradeName = v.name
                end
            end, MRanksMenuSelected)
        end
    end, function()
    end)

    MRanksMenuSelected:IsVisible(function(Items)
        local deleteLock, deleteDescription = false, nil
        if SelectedGradeName == "zero" or SelectedGradeName == "boss" then
            deleteLock = true
            deleteDescription = _('mRanksMenuSelected_cantDelete')
        end
        Items:AddButton(_('mRanksMenuSelected_rename'), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('mRanksMenuSelected_rename_textInput'), (GangsInfos[ESX.PlayerData.gang.name].grades[SelectedGradeName].label or ""), 50)
                if resultTextInput ~= nil and #resultTextInput > 0 then
                    ESX.TriggerServerCallback('mgd_gangbuilder:renameGrade', function(success, cbText)
                        MRanksMenuSelected:SetSubtitle('('.. GangsInfos[ESX.PlayerData.gang.name].grades[SelectedGradeName].grade ..') '.. GangsInfos[ESX.PlayerData.gang.name].grades[SelectedGradeName].label)
                        ESX.ShowNotification(cbText)
                    end, ESX.PlayerData.gang.name, SelectedGradeName, resultTextInput)
                else
                    ESX.ShowNotification(_('mRanksMenuSelected_rename_error_noInput'))
                end
            end
        end)
        Items:AddButton(_('mRanksMenuSelected_delete'), deleteDescription, { IsDisabled = deleteLock, RightBadge = RageUI.BadgeStyle.Alert }, function(s, a) end, DeleteConfirmationMenu)
    end, function()
    end)

    DeleteConfirmationMenu:IsVisible(function(Items)
        Items:AddButton(_("deleteConfirmationMenu_cancel"), nil, { IsDisabled = false }, function(s, a) end)
        Items:AddButton(_("deleteConfirmationMenu_delete"), nil, { IsDisabled = false, RightBadge = RageUI.BadgeStyle.Alert }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:deleteGrade', function(success, cbText)
                    if success then
                        RageUI.GoBack()
                        SelectedGradeName = ""
                        ESX.ShowNotification(cbText)
                    else
                        ESX.ShowNotification(cbText)
                    end
                end, ESX.PlayerData.gang.name, SelectedGradeName)
            end
        end)
    end, function()
    end)

    MPermissionsMenu:IsVisible(function(Items)
        for k,v in pairs(GangsInfos[ESX.PlayerData.gang.name].grades) do
            local lock, description = false, nil
            if v.grade >= ESX.PlayerData.gang.grade then
                lock = true
                description = _('mPermMenu_thisGradeLock')
            end
            if k == "boss" then
                lock = true
                description = _('mPermMenu_bossLock')
            end

            Items:AddButton('('.. v.grade ..') '.. v.label, description, { IsDisabled = lock, RightLabel = "→" }, function(s, a)
                if s then
                    MPermissionsMenuSelected:SetSubtitle('('.. v.grade ..') '.. v.label)
                    SelectedGradeNameForPerm = v.name
                end
            end, MPermissionsMenuSelected)
        end
    end, function()
    end)

    MPermissionsMenuSelected:IsVisible(function(Items)
        local perms = GangsInfos[ESX.PlayerData.gang.name].grades[SelectedGradeNameForPerm].permissions
        Items:AddButton(_('mPermMenuSelected_submit'), nil, { IsDisabled = false, RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:editPermissions', function(success, cbText)
                    if success then
                        RageUI.CloseAll()
                        perms = {}
                        SelectedGradeNameForPerm = ""
                        RageUI.Visible(MPermissionsMenu, not RageUI.Visible(MPermissionsMenu))
                        ESX.ShowNotification(cbText)
                    else
                        ESX.ShowNotification(cbText)
                    end
                end, ESX.PlayerData.gang.name, SelectedGradeNameForPerm, perms)
            end
        end)

        for k,v in pairs(Config.Permissions) do 
            local edit = {}
            Items:CheckBox(v, _(k ..'_description'), perms[k], { Style = 1 }, function(s, IsChecked)
                if s then
                    perms[k] = IsChecked
                end
            end)
        end
    end, function()
    end)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

RegisterNetEvent('mgd_gangbuilder:openBossMenu')
AddEventHandler('mgd_gangbuilder:openBossMenu', function()
    SelectedGradeName = ""
    BossMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label)) MMembersMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label)) MRanksMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label)) MPermissionsMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    RageUI.Visible(BossMenu, not RageUI.Visible(BossMenu))
end)