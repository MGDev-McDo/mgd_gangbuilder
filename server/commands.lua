ESX.RegisterCommand('mgd:setgang', Config.commandAccess, function(xPlayer, args, showError)
	local target, gangName, gangGrade = args.playerId, args.gangName, args.gangGrade
	if ServerGangsData[gangName] then
        local found = nil
        for k,v in pairs(ServerGangsData[gangName].grades) do
            if v.grade == gangGrade then
                found = v.label
                break
            end
        end

        if found ~= nil then
            target.setGang(gangName, gangGrade)
            target.showNotification(_('command_success_setgang_target', ServerGangsData[gangName].label, found))
            xPlayer.showNotification(_('command_success_setgang_author', target.source, ServerGangsData[gangName].label, found))
        else
            xPlayer.showNotification(_('command_error_gangGrade'))
        end
    else
        xPlayer.showNotification(_('command_error_gangName'))
    end
end, true, {help = _('command_setGang'), validate = true, arguments = {
	{name = 'playerId', help = _('command_args_playerId'), type = 'player'},
	{name = 'gangName', help = _('command_args_gangName'), type = 'string'},
    {name = 'gangGrade', help = _('command_args_gangGrade'), type = 'number'}
}})

ESX.RegisterCommand('mgd:gangmenu', Config.commandAccess, function(xPlayer, args, showError)
	TriggerClientEvent("mgd_gangbuilder:openCreateMenu", xPlayer.source)
end, true, {help = _('command_gangMenu'), validate = true, arguments = {
}})

ESX.RegisterCommand('myid', 'user', function(xPlayer, args, showError)
	xPlayer.showNotification(_('myid', xPlayer.source))
end, false, {help = _('command_myid')})