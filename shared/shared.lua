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
	locale = "fr", --| Options : fr / en

    commandAccess = "admin",

	DrawDistance = 5.0,
	Marker = {
		['inventory'] = {
			type = 1,
			color = { r = 32, g = 251, b = 149, a = 150 },
			width = 1.2,
			height = 0.5,
			adaptCoords = vector3(0.0, 0.0, -1.0)
		},
		['garageMenu'] = {
			type = 1,
			color = { r = 32, g = 251, b = 149, a = 150 },
			width = 1.2,
			height = 0.5,
			adaptCoords = vector3(0.0, 0.0, -1.0)
		},
		['garageStore'] = {
			type = 1,
			color = { r = 153, g = 20, b = 20, a = 150 },
			width = 2.0,
			height = 0.15,
			adaptCoords = vector3(0.0, 0.0, -1.0)
		},
		['boss'] = {
			type = 1,
			color = { r = 32, g = 251, b = 149, a = 150 },
			width = 1.2,
			height = 0.5,
			adaptCoords = vector3(0.0, 0.0, -1.0)
		}
	},

	TextUI = {
		borderRadius = 2,
		backgroundColor = '#212529',
		icons = {
			['inventory'] = 'box',
			['garageMenu'] = 'square-parking',
			['garageStore'] = 'warehouse',
			['boss'] = 'crown',
		}
	},

    discordLogs = false,
	discordWebhooks = {
		ADMIN = "https://discord.com/api/webhooks/000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
		GANG = "https://discord.com/api/webhooks/000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	},

	garageUniqueVehicle = false, --| Options : true / false | true for unique vehicles
	garageVehicleList = { --| If you don't use unique vehicles above
		`voodoo`, `sanchez`
	},

	ox_inventory = false, --| Options : true / false
	ox_inventory_Slots = 100,
	ox_inventory_MaxWeight = 500000,
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