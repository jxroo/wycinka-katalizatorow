ESX = exports['es_extended']:getSharedObject()
local onCooldown = false
local Locales = {}

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('catalyst:requestLocales', function(locale)
        Locales = locale
    end)
end)

function _L(key, ...)
    return string.format(Locales[key] or key, ...)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        if not IsPedInAnyVehicle(playerPed, false) then
            local vehicle = ESX.Game.GetClosestVehicle(coords)
            if DoesEntityExist(vehicle) and #(coords - GetEntityCoords(vehicle)) < 2.0 then
                sleep = 5
                ESX.ShowHelpNotification('Naciśnij ~INPUT_CONTEXT~, aby spróbować ukraść katalizator')
                
                if IsControlJustReleased(0, 38) and not onCooldown then
                    ESX.TriggerServerCallback('catalyst:hasTool', function(hasTool)
                        if hasTool then
                            StartSteal(vehicle)
                        else
                            ESX.ShowNotification(_L('no_tool', ESX.GetItemLabel(Config.ToolItem)))
                        end
                    end)
                elseif IsControlJustReleased(0, 38) and onCooldown then
                     ESX.ShowNotification(_L('cooldown_active'))
                end
            end
        end
        Wait(sleep)
    end
end)

function StartSteal(vehicle)
    onCooldown = true
    local playerPed = PlayerPedId()

    TaskGoToEntity(playerPed, vehicle, -1, 1.0, 1.0, 1073741824, 0)
    Wait(1500)
    ClearPedTasks(playerPed)

    local vehicleCoords = GetEntityCoords(vehicle)
    local playerCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -1.5, 0.0)
    SetEntityCoords(playerPed, playerCoords.x, playerCoords.y, playerCoords.z)
    TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'cutting', 0.2)
    ESX.ShowNotification(_L('stealing_in_progress'))

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'showMinigame',
        config = Config.Minigame
    })
end

RegisterNUICallback('minigameResult', function(data, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('catalyst:stealResult', data.success)
    cb('ok')
    
    SetTimeout(Config.Cooldown * 1000, function()
        onCooldown = false
    end)
end)

-- Reszta kodu (Paser i Blip) pozostaje taka sama.
Citizen.CreateThread(function()
    local fence = Config.Fence
    RequestModel(GetHashKey(fence.ped))
    while not HasModelLoaded(GetHashKey(fence.ped)) do Wait(100) end
    local ped = CreatePed(4, GetHashKey(fence.ped), fence.coords.x, fence.coords.y, fence.coords.z - 1.0, 33.7, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    while true do
        local sleep = 1000
        if #(GetEntityCoords(PlayerPedId()) - fence.coords) < 1.5 then
            sleep = 5
            ESX.ShowHelpNotification(_L('fence_prompt'))
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('catalyst:sell')
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('catalyst:policeAlert')
AddEventHandler('catalyst:policeAlert', function(targetCoords)
    local blip = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.5)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_L('police_alert'))
    EndTextCommandSetBlipName(blip)
    Wait(30000)
    RemoveBlip(blip)
end)