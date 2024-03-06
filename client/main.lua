local QBCore = exports['qb-core']:GetCoreObject()
local stress = 0
local config = Config
local speedMultiplier = config.UseMPH and 2.23694 or 3.6
local seatbeltIsOn = false
local hasPlayerLoaded = false
local hunger
local thirst
AddEventHandler('QBCore:Client:OnPlayerLoaded', function(player)
    hasPlayerLoaded = true
end)
RegisterNetEvent('hud:client:UpdateNeeds')
AddEventHandler('hud:client:UpdateNeeds', function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)
RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)
function PauseMenuState()
    if hasPlayerLoaded then
        return IsPauseMenuActive()
    end
    return true
end
Citizen.CreateThread(function()
    while true do
        local ped                 = GetPlayerPed(-1)
        local userid              = GetPlayerServerId(PlayerId())
        local isinthewater        = IsEntityInWater(ped)
        local isinthewaterswiming = IsPedSwimming(ped)
        local pause_menu          = PauseMenuState()
        local vehicle             = GetVehiclePedIsIn(ped, false)
        local IsPedInAnyVehicle   = IsPedInAnyVehicle(ped, false)
        local player_armour       = GetPedArmour(PlayerPedId())
        local player_health       = GetEntityHealth(PlayerPedId()) - 100
        local in_vehicle          = IsPedSittingInAnyVehicle(ped)
        local underwater_time     = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
        local locked              = GetVehicleDoorLockStatus(vehicle)
        local oxygen              = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
        local fuelLevel           = 0
        local gearLevel           = 0
        local healthCar           = 0
        local speedLevel          = 0
        local damage              = GetVehicleEngineHealth(vehicle)
        if in_vehicle and not IsPlayerDead(ped) then
            DisplayRadar(true)
        elseif not in_vehicle then
            DisplayRadar(false)
        end
        if (IsPedInAnyVehicle) then
            fuelLevel = GetVehicleFuelLevel(vehicle)
            gearLevel = GetVehicleCurrentGear(vehicle)
            healthCar = math.ceil(GetVehicleBodyHealth(vehicle) / 10)
            speedLevel = math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
        else
            fuelLevel  = 0
            gearLevel  = 0
            healthCar  = 0
            speedLevel = 0
        end
        local retval , lightsOn , highbeamsOn = GetVehicleLightsState(vehicle)
        SendNUIMessage({
            pauseMenu = pause_menu,
            armour = player_armour,
            health = player_health,
            food = hunger,
            thirst = thirst,
            stress = stress,
            in_vehicle = in_vehicle,
            userid = userid,
            isinthewater = isinthewater,
            isinthewaterswiming = isinthewaterswiming,
            underwater_time = underwater_time,
            oxygen = oxygen,
            type = 'carhud:update',
            isInVehicle = IsPedInAnyVehicle,
            speed = speedLevel,
            fuel = fuelLevel,
            gear = gearLevel,
            vehicle_health = healthCar,
            luces = lightsOn,
            high_beam = highbeamsOn,
            locked = locked,
            damage = damage,
            clock_type = config.UseMPH and "mph" or "kmh",
            logo = config.Logo
        })
        RegisterCommand('hidehud',function()
            SendNUIMessage({ hide_hud = true })
        end)
        RegisterCommand('showhud', function()
            SendNUIMessage({ show_hud = true })
        end)
        RegisterCommand('startcinematic', function()
            DisplayHud(false)
            SendNUIMessage({ start_cinematic = true })
        end)
        RegisterCommand('stopcinematic', function()
            SendNUIMessage({ stop_cinematic = true })
        end)
        Citizen.Wait(500)
	end
end)
RegisterCommand('engine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return end
    if GetIsVehicleEngineRunning(vehicle) then
        QBCore.Functions.Notify("Engine Has Been Switched Off")
    else
        QBCore.Functions.Notify("Engine Has Been Switched On")
    end
    SetVehicleEngineOn(vehicle, not GetIsVehicleEngineRunning(vehicle), false, true)
end)
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local speed = GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * speedMultiplier
                local stressSpeed = seatbeltIsOn and config.MinimumSpeed or config.MinimumSpeedUnbuckled
                if speed >= stressSpeed then
                    TriggerServerEvent('hud:server:UpdateStress', math.random(1, 3), false)
                end
            end
        end
        Wait(10000)
    end
end)
local function IsWhitelistedWeaponStress(weapon)
    if weapon then
        for _, v in pairs(config.WhitelistedWeaponStress) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)
            if weapon ~= `WEAPON_UNARMED` then
                if IsPedShooting(ped) and not IsWhitelistedWeaponStress(weapon) then
                    if math.random() < config.StressChance then
                        TriggerServerEvent('hud:server:UpdateStress', math.random(1, 3), false)
                    end
                end
            else
                Wait(1000)
            end
        end
        Wait(8)
    end
end)
local function GetBlurIntensity(stresslevel)
    for _, v in pairs(config.Intensity['blur']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end
local function GetEffectInterval(stresslevel)
    for _, v in pairs(config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local effectInterval = GetEffectInterval(stress)
        if stress >= 100 then
            local BlurIntensity = GetBlurIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = FallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                local ForwardVector = GetEntityForwardVector(ped)
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, ForwardVector.x, ForwardVector.y, ForwardVector.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end
            Wait(1000)
            for _ = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= config.MinimumStress then
            local BlurIntensity = GetBlurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)
function SetSeatBeltActive(e)
    if (e) then
        SendNUIMessage({
            type = 'seatbelt:toggle',
            toggle = e.active,
            checkIsVeh = e.checkIsVeh,
        })
    end
end
AddEventHandler("seatbelt:client:ToggleSeatbelt", function()
    seatbeltIsOn = not seatbeltIsOn
    SetSeatBeltActive({
        active = seatbeltIsOn,
        checkIsVeh = true,
    })
end)