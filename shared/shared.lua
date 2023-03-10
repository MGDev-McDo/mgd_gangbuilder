function _(str, ...)
	if Config.locale then
		if Locale[Config.locale][str] then
			return string.format(Locale[Config.locale][str], ...)
		else
			return 'No Locale Message'
		end
	end
end

Config = {
	locale = "fr", --| Options : fr

    commandAccess = "superadmin",

	DrawDistance = 10.0,
	Markers = {
		r = 32,
		g = 251,
		b = 149,
		a = 150
	},

    discordLogs = true,
	discordWebhooks = {
		ADMIN = "https://discord.com/api/webhooks/000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
		GANG = "https://discord.com/api/webhooks/000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	},
}

-- Don't touch except if you know want you do
Config.Permissions = {
	perm_inventory_view = _('perm_inventory_view'),
	perm_inventory_put = _('perm_inventory_put'),
	perm_inventory_take = _('perm_inventory_take'),
	perm_garage_view = _('perm_garage_view'),
	perm_garage_exit = _('perm_garage_exit'),
	perm_garage_store = _('perm_garage_store'),
	perm_boss_menu = _('perm_boss_menu'),
	perm_manage_members = _('perm_manage_members'),
	perm_manage_permissions = _('perm_manage_permissions'),
	perm_manage_ranks = _('perm_manage_ranks')
}