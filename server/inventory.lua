ESX.RegisterServerCallback('mgd_gangbuilder:getInventory', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
	TriggerEvent('esx_datastore:getSharedDataStore', 'gang_'.. xPlayer.gang.name, function(store)
        local inventory = {
            items = store.get('items'),
            weapons = store.get('weapons'),
            accounts = store.get('accounts')
        }

        cb(inventory)
	end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:putInInventory', function(source, cb, putType, putName, putLabel, putQuantity)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    local removeCheck, successText = false, ""

    TriggerEvent('esx_datastore:getSharedDataStore', 'gang_'.. xPlayer.gang.name, function(store)
		local inv = store.get(putType)

		if inv == nil then
			inv = {}
		end

        if putType == "items" then
            if xPlayer.getInventoryItem(putName).count >= putQuantity then
                xPlayer.removeInventoryItem(putName, putQuantity)
                successText = _('server_success_putItem_items', putQuantity, putLabel)
                removeCheck = true
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangPutInventory",
                    data = {
                        {fieldName = "Gang", value = xPlayer.gang.name},
                        {fieldName = "Type", value = putType},
                        {fieldName = "Name", value = putName},
                        {fieldName = "Label", value = putLabel},
                        {fieldName = "Quantité", value = putQuantity}
                    }
                })
            else
                cb(false, _('server_error_putItem_items', putLabel))
                return
            end
        end

        if putType == "weapons" then
            xPlayer.removeWeapon(putName)
            successText = _('server_success_putItem_weapons', putLabel)
            removeCheck = true
            TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                author = _src,
                action = "gangPutInventory",
                data = {
                    {fieldName = "Gang", value = xPlayer.gang.name},
                    {fieldName = "Type", value = putType},
                    {fieldName = "Name", value = putName},
                    {fieldName = "Label", value = putLabel},
                    {fieldName = "Quantité", value = putQuantity}
                }
            })
        end

        if putType == "accounts" then
            if xPlayer.getAccount(putName).money >= putQuantity then
                xPlayer.removeAccountMoney(putName, putQuantity)
                successText = _('server_success_putItem_accounts', ESX.Math.GroupDigits(putQuantity), putLabel)
                removeCheck = true
                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangPutInventory",
                    data = {
                        {fieldName = "Gang", value = xPlayer.gang.name},
                        {fieldName = "Type", value = putType},
                        {fieldName = "Name", value = putName},
                        {fieldName = "Label", value = putLabel},
                        {fieldName = "Quantité", value = putQuantity}
                    }
                })
            else
                cb(false, _('server_error_putItem_accounts', putLabel))
                return
            end
        end

        if removeCheck then
            if putType ~= "weapons" then
                local foundInInv = false
                for i=1, #inv, 1 do
                    if inv[i].name == putName then
                        inv[i].count = inv[i].count + putQuantity
                        foundInInv = true
                        break
                    end
                end

                if not foundInInv then
                    table.insert(inv, {
                        name  = putName,
                        label = putLabel,
                        count = putQuantity
                    })
                end
            else
                table.insert(inv, {
                    name  = putName,
                    label = putLabel,
                    count = putQuantity
                })
            end

            store.set(putType, inv)
            cb(true, successText)
        end
	end)
end)

ESX.RegisterServerCallback('mgd_gangbuilder:takeFromInventory', function(source, cb, takeType, takeName, takeQuantity)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    local successText = ""

    TriggerEvent('esx_datastore:getSharedDataStore', 'gang_'.. xPlayer.gang.name, function(store)
		local inv = store.get(takeType)
        local foundInInv, foundIndex = false, nil

		if inv == nil then
			inv = {}
		end

        if takeType ~= "weapons" then
            for i=1, #inv, 1 do
                if inv[i].name == takeName then
                    foundInInv = true
                    foundIndex = i
                    break
                end
            end
        else
            for i=1, #inv, 1 do
                if inv[i].name == takeName and inv[i].count == takeQuantity then
                    foundIndex = i
                    foundInInv = true
                    break
                end
            end
        end

        if foundInInv then
            if takeType == "items" then
                if inv[foundIndex].count >= takeQuantity then
                    if xPlayer.canCarryItem(takeName, takeQuantity) then
                        xPlayer.addInventoryItem(takeName, takeQuantity)
                        successText = _('server_success_takeItem_items', takeQuantity, ESX.GetItemLabel(takeName))

                        inv[foundIndex].count = inv[foundIndex].count - takeQuantity
                        TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                            author = _src,
                            action = "gangTakeInventory",
                            data = {
                                {fieldName = "Gang", value = xPlayer.gang.name},
                                {fieldName = "Type", value = takeType},
                                {fieldName = "Name", value = takeName},
                                {fieldName = "Label", value = ESX.GetItemLabel(takeName)},
                                {fieldName = "Quantité", value = takeQuantity},
                                {fieldName = "Restant", value = inv[foundIndex].count}
                            }
                        })
                        if inv[foundIndex].count == 0 then
                            table.remove(inv, foundIndex)
                        end
                    else
                        cb(false, _('server_error_takeItem_items'))
                        return
                    end
                else
                    cb(false, _('server_error_takeItem_quantity', ESX.GetItemLabel(takeName)))
                    return
                end
            end
    
            if takeType == "weapons" then
                xPlayer.addWeapon(takeName, takeQuantity)
                successText = _('server_success_takeItem_weapons', inv[foundIndex].label)

                TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                    author = _src,
                    action = "gangTakeInventory",
                    data = {
                        {fieldName = "Gang", value = xPlayer.gang.name},
                        {fieldName = "Type", value = takeType},
                        {fieldName = "Name", value = takeName},
                        {fieldName = "Label", value = inv[foundIndex].label},
                    }
                })

                table.remove(inv, foundIndex)
            end
    
            if takeType == "accounts" then
                if inv[foundIndex].count >= takeQuantity then
                    xPlayer.addAccountMoney(takeName, takeQuantity)
                    successText = _('server_success_takeItem_accounts', ESX.Math.GroupDigits(takeQuantity), inv[foundIndex].label)
                    inv[foundIndex].count = inv[foundIndex].count - takeQuantity
                    TriggerEvent('mgd_gangbuilder:dLogs', "GANG", {
                        author = _src,
                        action = "gangTakeInventory",
                        data = {
                            {fieldName = "Gang", value = xPlayer.gang.name},
                            {fieldName = "Type", value = takeType},
                            {fieldName = "Name", value = takeName},
                            {fieldName = "Label", value = inv[foundIndex].label},
                            {fieldName = "Quantité", value = takeQuantity},
                            {fieldName = "Restant", value = inv[foundIndex].count}
                        }
                    })
                    if inv[foundIndex].count == 0 then
                        table.remove(inv, foundIndex)
                    end
                else
                    cb(false, _('server_error_takeItem_quantity'))
                    return
                end
            end

            store.set(takeType, inv)
            cb(true, successText)
        else
            cb(false, _('server_error_takeItem'))
        end
	end)
end)