ESX = exports['es_extended']:getSharedObject()
local PlayersStealing = {} -- Zabezpieczenie stanu
local Locales = {}

-- Zabezpieczenie przed zapętlaniem sprzedaży
local SellCooldowns = {}

ESX.RegisterServerCallback('catalyst:requestLocales', function(source, cb)
    if not Locales['pl'] then
        Locales['pl'] = require('locales/pl')
    end
    cb(Locales['pl'])
end)

ESX.RegisterServerCallback('catalyst:startSteal', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Zabezpieczenie: czy gracz juz jest w trakcie kradziezy?
    if PlayersStealing[source] then
        cb(false)
        return
    end

    local tool = xPlayer.getInventoryItem(Config.ToolItem)
    if tool.count > 0 then
        PlayersStealing[source] = true -- Zapisz stan: gracz rozpoczął kradzież
        -- Failsafe: jesli gracz wyjdzie w trakcie, stan sie zresetuje
        SetTimeout(Config.Minigame.duration + 5000, function()
            PlayersStealing[source] = nil
        end)
        cb(true)
    else
        TriggerClientEvent('esx:showNotification', source, Locales['pl']['no_tool']:format(ESX.GetItemLabel(Config.ToolItem)))
        cb(false)
    end
end)

RegisterServerEvent('catalyst:stealResult')
AddEventHandler('catalyst:stealResult', function(success)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- ZABEZPIECZENIE: Sprawdzamy, czy gracz faktycznie rozpoczal kradziez
    if not PlayersStealing[src] then
        -- Opcjonalnie: mozesz tu dodac logowanie lub wyrzucenie gracza za probe oszustwa
        return
    end

    PlayersStealing[src] = nil -- Reset stanu

    if success then
        xPlayer.removeInventoryItem(Config.ToolItem, 1)
        xPlayer.addInventoryItem(Config.RewardItem, 1)
        TriggerClientEvent('esx:showNotification', src, Locales['pl']['steal_success'])
    else
        TriggerClientEvent('esx:showNotification', src, Locales['pl']['steal_fail'])
    end

    if math.random(100) <= Config.PoliceAlertChance then
        -- (...) kod powiadomienia policji bez zmian
    end
end)

RegisterServerEvent('catalyst:sell')
AddEventHandler('catalyst:sell', function()
    local src = source
    
    -- ZABEZPIECZENIE: Cooldown na sprzedaż
    if SellCooldowns[src] then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    local itemCount = xPlayer.getInventoryItem(Config.RewardItem).count

    if itemCount > 0 then
        local price = math.random(Config.Fence.price.min, Config.Fence.price.max)
        xPlayer.removeInventoryItem(Config.RewardItem, 1)
        xPlayer.addMoney(price)
        TriggerClientEvent('esx:showNotification', src, Locales['pl']['sold_catalyst']:format(price))

        SellCooldowns[src] = true
        SetTimeout(5000, function() SellCooldowns[src] = nil end) -- 5 sekund cooldownu
    else
        TriggerClientEvent('esx:showNotification', src, Locales['pl']['no_catalyst'])
    end
end)