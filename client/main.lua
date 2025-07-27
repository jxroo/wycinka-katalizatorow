ESX = exports['es_extended']:getSharedObject()
local onCooldown = false
local Locales = {}

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('catalyst:requestLocales', function(locale)
        Locales = locale
    end)
    
    -- Inicjalizacja ox_target
    exports.ox_target:addModel(Config.TargetedVehicles, {
        {
            name = 'catalyst_theft',
            label = 'Ukradnij katalizator',
            icon = 'fa-solid fa-wrench',
            canInteract = function(entity, distance)
                return not IsPedInAnyVehicle(PlayerPedId(), false) and not onCooldown and GetVehicleEngineHealth(entity) > 0
            end,
            onSelect = function(data)
                ESX.TriggerServerCallback('catalyst:startSteal', function(canSteal)
                    if canSteal then
                        StartSteal(data.entity)
                    end
                end)
            end
        }
    })
end)

function _L(key, ...)
    return string.format(Locales[key] or key, ...)
end

function StartSteal(vehicle)
    onCooldown = true
    SetTimeout(Config.Cooldown * 1000, function() onCooldown = false end)
    
    local playerPed = PlayerPedId()
    TaskGoToEntity(playerPed, vehicle, -1, 1.0, 1.0, 1073741824, 0)
    Wait(1500)
    ClearPedTasks(playerPed)

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
end)

-- Paser i Blip - bez zmian
Citizen.CreateThread(function()
    local fence = Config.Fence
    exports.ox_target:addBoxZone({
        coords = fence.coords,
        size = vec3(1, 1, 2),
        options = {
            {
                name = 'catalyst_sell',
                label = 'Sprzedaj czesci',
                icon = 'fa-solid fa-hand-holding-dollar',
                onSelect = function()
                    TriggerServerEvent('catalyst:sell')
                end
            }
        }
    })

    RequestModel(GetHashKey(fence.ped))
    while not HasModelLoaded(GetHashKey(fence.ped)) do Wait(100) end
    local ped = CreatePed(4, GetHashKey(fence.ped), fence.coords.x, fence.coords.y, fence.coords.z - 1.0, 33.7, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
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