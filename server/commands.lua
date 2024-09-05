ESX.RegisterCommand('mgd:setgang', Config.commandAccess, function(xPlayer, args, showError)
	local target, gangName, gangGrade = args.playerId, args.gangName, args.gangGrade
    local gangData = GlobalState['mgd_gangbuilder'][gangName]
	if gangData then
        local found = nil

        for k,v in pairs(gangData.grades) do
            if v.grade == gangGrade then
                found = v.label
                break
            end
        end

        if found ~= nil then
            target.triggerEvent('mgd_gangbuilder:updateClientAfterAction', _('command_success_setgang_target', gangData.label, found), target.gang.name, gangName, gangGrade)
            xPlayer.triggerEvent('mgd_gangbuilder:notify', _('command_success_setgang_author', target.source, gangData.label, found), 'success')
        else
            xPlayer.triggerEvent('mgd_gangbuilder:notify', _('command_error_gangGrade', gangGrade, gangName), 'error')
        end
    else
        xPlayer.triggerEvent('mgd_gangbuilder:notify', _('command_error_gangName', gangName), 'error')
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