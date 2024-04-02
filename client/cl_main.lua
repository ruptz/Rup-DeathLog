RegisterNetEvent('rup-deathlog:client:onPlayerDied')
AddEventHandler('rup-deathlog:client:onPlayerDied', function()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        local x, y, z = table.unpack(GetEntityCoords(ped))
        local streetName = GetStreetNameAtCoord(x, y, z)
        local streetStr = GetStreetNameFromHashKey(streetName)
        local pos = GetEntityCoords(PlayerPedId())
        local killerCause = GetPedCauseOfDeath(ped)
        
        if Config.Debug then
            print("^5DEBUG^7: ^1Killer Cause:^7", killerCause)
            print("^5DEBUG^7: ^2Death coordinates:^7", pos)
            print("^5DEBUG^7: ^3Death Street:^7", streetStr)
        end
        
        TriggerServerEvent('rup-deathlog:server:onPlayerDied', killerCause, streetStr, pos)
    end
end)
