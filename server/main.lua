ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('catalyst:hasTool', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemCount = xPlayer.getInventoryItem(Config.ToolItem).count
    cb(itemCount > 0)
end)

RegisterServerEvent('catalyst:stealResult')
AddEventHandler('catalyst:stealResult', function(success)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if success then
        xPlayer.removeInventoryItem(Config.ToolItem, 1)
        xPlayer.addInventoryItem(Config.RewardItem, 1)
        TriggerClientEvent('esx:showNotification', src, _L('steal_success'))
    else
        TriggerClientEvent('esx:showNotification', src, _L('steal_fail'))
    end

    if math.random(100) <= Config.PoliceAlertChance then
        local players = ESX.GetPlayers()
        for _, playerId in ipairs(players) do
            local p = ESX.GetPlayerFromId(playerId)
            if p.job.name == 'police' then
                TriggerClientEvent('catalyst:policeAlert', p.source, GetEntityCoords(GetPlayerPed(src)))
            end
        end
    end
end)

RegisterServerEvent('catalyst:sell')
AddEventHandler('catalyst:sell', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local itemCount = xPlayer.getInventoryItem(Config.RewardItem).count

    if itemCount > 0 then
        local price = math.random(Config.Fence.price.min, Config.Fence.price.max)
        xPlayer.removeInventoryItem(Config.RewardItem, 1)
        xPlayer.addMoney(price)
        TriggerClientEvent('esx:showNotification', src, _L('sold_catalyst', price))
    else
        TriggerClientEvent('esx:showNotification', src, _L('no_catalyst'))
    end
end)