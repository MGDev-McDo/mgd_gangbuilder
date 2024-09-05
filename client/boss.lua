local BossMenu = RageUI.CreateMenu(_("bossMenu_title"), "")
local MMembersMenu = RageUI.CreateSubMenu(BossMenu, _('mMembersMenu_title'), "")
local MMembersMenuInvite = RageUI.CreateSubMenu(MMembersMenu, _('mMembersMenuInvite_title'), "")
local MMembersMenuSelected = RageUI.CreateSubMenu(MMembersMenu, _('mMembersMenuSelected_title'), "")
local MMembersMenuSelectedSetGrade = RageUI.CreateSubMenu(MMembersMenuSelected, _('mMembersMenuSelectedSetGrade_title'), _('mMembersMenuSelected_manageGrade'))
local MRanksMenu = RageUI.CreateSubMenu(BossMenu, _('mRanksMenu_title'), "")
local MRanksMenuSelected = RageUI.CreateSubMenu(MRanksMenu, _('mRanksMenuSelected_title'), "")
local DeleteConfirmationMenu = RageUI.CreateSubMenu(MRanksMenuSelected, _("deleteConfirmationMenu_title"), _("deleteConfirmationMenu_subtitle"))
local MPermissionsMenu = RageUI.CreateSubMenu(BossMenu, _('mPermMenu_title'), "")
local MPermissionsMenuSelected = RageUI.CreateSubMenu(MPermissionsMenu, _('mPermMenuSelected_title'), "")

local SelectedGradeName, SelectedGradeNameForPerm, MembersList, refreshAccess, SelectedIdentifier, permissions = "", "", {}, false, "", {}

function RageUI.PoolMenus:MGDGangBuilder_Boss()
	BossMenu:IsVisible(function(Items)
        Items:AddButton(_('bossMenu_manageMembers'), _('bossMenu_manageMembers_description'), { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_manage_members"], RightLabel = "→" }, function(s, a)
            if s then
                SelectedIdentifier = ""
                ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                    MembersList = members
                end)
            end
        end, MMembersMenu)
        Items:AddButton(_('bossMenu_manageRanks'), _('bossMenu_manageRanks_description'), { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_manage_ranks"], RightLabel = "→" }, function(s, a) end, MRanksMenu)
        Items:AddButton(_('bossMenu_managePermissions'), _('bossMenu_managePermissions_description'), { IsDisabled = not ESX.PlayerData.gang.grade_permissions["perm_manage_permissions"], RightLabel = "→" }, function(s, a) end, MPermissionsMenu)
    end, function()
	end)

    MMembersMenu:IsVisible(function(Items)
        Items:AddButton(_('mMembersMenu_refresh'), nil, { IsDisabled = refreshAccess, RightLabel = "→" }, function(s, a)
            if s then
                SelectedIdentifier = ""
                ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                    MembersList = members

                    refreshAccess = true
                    Citizen.SetTimeout(5000, function()
                        refreshAccess = false
                    end)
                end)                
            end
        end)

        for i = 1, #MembersList, 1 do
            Items:AddButton(MembersList[i].firstname .. " " .. MembersList[i].lastname, nil, { RightLabel = MembersList[i].label }, function(s, a)
                if s then
                    MMembersMenuSelected:SetSubtitle(MembersList[i].firstname .. " " .. MembersList[i].lastname)
                    SelectedIdentifier = MembersList[i].identifier
                end
            end, MMembersMenuSelected)
        end
    end, function()
    end)

    MMembersMenuSelected:IsVisible(function(Items)
        Items:AddButton(_('mMembersMenuSelected_manageGrade'), nil, { RightLabel = "→" }, function(s, a) end, MMembersMenuSelectedSetGrade)
        Items:AddButton(_('mMembersMenuSelected_fire'), nil, { RightBadge = RageUI.BadgeStyle.Alert }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:fire', function(success, cbText, msgType)
                    if success then
                        ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                            MembersList = members
                        end)
                        SelectedIdentifier = ""
                        RageUI.GoBack()
                    end
                    
                    lib.notify({
                        title = _('notify_title_'.. msgType),
                        description = cbText,
                        type = msgType,
                        duration = 6000
                    })
                end, SelectedIdentifier, true)
            end
        end)
    end, function()
    end)

    MMembersMenuSelectedSetGrade:IsVisible(function(Items)
        local gradesData = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].grades
        for k,v in pairs(gradesData) do
            Items:AddButton('('.. v.grade .. ') ' ..v.label, nil, { RightLabel = "→" }, function(s, a)
                if s then
                    ESX.TriggerServerCallback('mgd_gangbuilder:changeGrade', function(success, cbText, msgType)
                        if success then
                            ESX.TriggerServerCallback('mgd_gangbuilder:getMembers', function(members)
                                MembersList = members
                            end)
                            RageUI.GoBack()
                        end

                        lib.notify({
                            title = _('notify_title_'.. msgType),
                            description = cbText,
                            type = msgType,
                            duration = 6000
                        })
                    end, SelectedIdentifier, v.grade)
                end
            end)
        end
    end, function()
    end)

    MRanksMenu:IsVisible(function(Items)
        local addLock, addDescription = false, nil
        local maxRanks = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].data.maxRanks
        local gradesData = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].grades

        local numberOfGrades = countRanks(gradesData)
        if numberOfGrades >= maxRanks then
            addLock = true
            addDescription = _('mRanksMenu_addLock', numberOfGrades, maxRanks)
        end

        Items:AddButton(_('mRanksMenu_addGrade'), addDescription, { IsDisabled = addLock, RightLabel = "→" }, function(s, a)
            if s then
                local resultTextInput = TextInput(_('mRanksMenu_addGrade_textInput'), "", 50)

                if resultTextInput ~= nil and #resultTextInput > 0 then
                    ESX.TriggerServerCallback("mgd_gangbuilder:getFreeGrade", function(successF, cbFText, msgTypeF, gradeID, gradeName)
                        if successF then
                            ESX.TriggerServerCallback("mgd_gangbuilder:createGrade", function(success, cbText, msgType)
                                if success then
                                    gradesData = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].grades
                                end

                                lib.notify({
                                    title = _('notify_title_'.. msgType),
                                    description = cbText,
                                    type = msgType,
                                    duration = 6000
                                })
                            end, resultTextInput, gradeID, gradeName)
                        else
                            lib.notify({
                                title = _('notify_title_'.. msgTypeF),
                                description = cbFText,
                                type = msgTypeF,
                                duration = 6000
                            })
                        end
                    end)
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('mRanksMenu_addGrade_textInput_error_noInput'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)

        for k,v in pairs(gradesData) do
            Items:AddButton('('.. v.grade ..') '.. v.label, nil, { RightLabel = "→" }, function(s, a)
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

        Items:AddButton(_('mRanksMenuSelected_rename'), nil, { RightLabel = "→" }, function(s, a)
            if s then
                local gradeLabel = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].grades[SelectedGradeName].label
                local resultTextInput = TextInput(_('mRanksMenuSelected_rename_textInput'), (gradeLabel or ""), 50)
                if resultTextInput ~= nil and #resultTextInput > 0 then
                    ESX.TriggerServerCallback('mgd_gangbuilder:renameGrade', function(success, cbText, msgType)
                        if success then
                            SelectedGradeName = ""
                            RageUI.GoBack()
                        end

                        lib.notify({
                            title = _('notify_title_'.. msgType),
                            description = cbText,
                            type = msgType,
                            duration = 6000
                        })
                    end, SelectedGradeName, resultTextInput)
                else
                    lib.notify({
                        title = _('notify_title_error'),
                        description = _('mRanksMenuSelected_rename_error_noInput'),
                        type = 'error',
                        duration = 6000
                    })
                end
            end
        end)
        Items:AddButton(_('mRanksMenuSelected_delete'), deleteDescription, { IsDisabled = deleteLock, RightBadge = RageUI.BadgeStyle.Alert }, function(s, a) end, DeleteConfirmationMenu)
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
                ESX.TriggerServerCallback('mgd_gangbuilder:deleteGrade', function(success, cbText, msgType)
                    if success then
                        SelectedGradeName = ""
                        RageUI.Visible(MRanksMenu, true)
                    end

                    lib.notify({
                        title = _('notify_title_'.. msgType),
                        description = cbText,
                        type = msgType,
                        duration = 6000
                    })
                end, SelectedGradeName)
            end
        end)
    end, function()
    end)

    MPermissionsMenu:IsVisible(function(Items)
        local gradesData = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].grades

        for k,v in pairs(gradesData) do
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
                    permissions = GlobalState['mgd_gangbuilder'][ESX.PlayerData.gang.name].grades[SelectedGradeNameForPerm].permissions
                end
            end, MPermissionsMenuSelected)
        end
    end, function()
    end)

    MPermissionsMenuSelected:IsVisible(function(Items)
        Items:AddButton(_('mPermMenuSelected_submit'), nil, { RightLabel = "→" }, function(s, a)
            if s then
                ESX.TriggerServerCallback('mgd_gangbuilder:editPermissions', function(success, cbText, msgType)
                    if success then
                        SelectedGradeNameForPerm = ""
                        RageUI.GoBack()
                    end

                    lib.notify({
                        title = _('notify_title_'.. msgType),
                        description = cbText,
                        type = msgType,
                        duration = 6000
                    })
                end, SelectedGradeNameForPerm, permissions)
            end
        end)

        for k,v in pairs(Config.Permissions) do
            Items:CheckBox(v, _(k ..'_description'), permissions[k], { Style = 1 }, function(s, IsChecked)
                if s then
                    permissions[k] = IsChecked
                end
            end)
        end
    end, function()
    end)
end

function countRanks(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function OpenBossMenu()
    SelectedGradeName = ""
    BossMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label)) MMembersMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label)) MRanksMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label)) MPermissionsMenu:SetSubtitle(_("actionMenu_subtitle", ESX.PlayerData.gang.label))
    RageUI.Visible(BossMenu, not RageUI.Visible(BossMenu))
end

Citizen.CreateThread(function()
    exports.ox_target:addGlobalPlayer({
    {
        label = _('ox_target_invitePlayer'),
        icon = 'fa-solid fa-user-plus',
        distance = 2.0,
        canInteract = function()
            return ESX.PlayerData.gang.grade_permissions['perm_manage_members']
        end,
        onSelect = function(data)
            local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            ESX.TriggerServerCallback('mgd_gangbuilder:invite', function(success, cbText, msgType)
                lib.notify({
                    title = _('notify_title_'.. msgType),
                    description = cbText,
                    type = msgType,
                    duration = 6000
                })
            end, targetServerId)
        end
    }, {
        label = _('ox_target_firePlayer'),
        icon = 'fa-solid fa-user-minus',
        distance = 2.0,
        canInteract = function()
            return ESX.PlayerData.gang.grade_permissions['perm_manage_members']
        end,
        onSelect = function(data)
            local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
            ESX.TriggerServerCallback('mgd_gangbuilder:fire', function(success, cbText, msgType)           
                lib.notify({
                    title = _('notify_title_'.. msgType),
                    description = cbText,
                    type = msgType,
                    duration = 6000
                })
            end, targetServerId, false)
        end
    }})
end)