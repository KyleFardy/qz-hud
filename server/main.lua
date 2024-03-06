local QBCore = exports['qb-core']:GetCoreObject()
local ResetStress = false
RegisterNetEvent('hud:server:UpdateStress', function(amount, isRelief)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or (Config.DisablePoliceStress and Player.PlayerData.job.name == 'police') then return end
    local currentStress = Player.PlayerData.metadata['stress'] or 0
    local newStress = ResetStress and 0 or currentStress + (isRelief and -amount or amount)
    newStress = math.max(0, math.min(100, newStress))
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('QBCore:Notify', src, isRelief and "You Are Feeling More Relaxed!" or "You Are Feeling More Stressed!", isRelief and 'success' or 'error', 1500)
end)