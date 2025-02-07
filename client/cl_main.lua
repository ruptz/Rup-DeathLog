function SendPlayerDeath(message, weapon, streetStr, pos, killer)
    if not killer then
        TriggerServerEvent('rup-deathlog:OnPlayerKilled', message, weapon, streetStr, pos)
    else
        local kServId = GetPlayerServerId(killer)
        TriggerServerEvent('rup-deathlog:OnPlayerKilled', message, weapon, streetStr, pos, kServId)
    end
end

Citizen.CreateThread(function()
    if Config.Debug then
        print("^5DEBUG^7: ^2Thread started^7")
        print("^5DEBUG^7: ^2Ped:^7", PlayerPedId())
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if IsEntityDead(playerPed) then
            local sourceOfDeath = GetPedSourceOfDeath(playerPed)
            local causeOfDeath = GetPedCauseOfDeath(playerPed)
            local x, y, z = table.unpack(GetEntityCoords(playerPed))
            local streetName = GetStreetNameAtCoord(x, y, z)
            local streetStr = GetStreetNameFromHashKey(streetName)
            local pos = GetEntityCoords(PlayerPedId())

            local weapon = WeaponNames[tostring(causeOfDeath)]
            local killer, reasonOfDeath

            if IsEntityAPed(sourceOfDeath) and IsPedAPlayer(sourceOfDeath) then
                killer = NetworkGetPlayerIndexFromPed(sourceOfDeath)
            elseif IsEntityAVehicle(sourceOfDeath) and IsEntityAPed(GetPedInVehicleSeat(sourceOfDeath, -1)) and IsPedAPlayer(GetPedInVehicleSeat(sourceOfDeath, -1)) then
                killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(sourceOfDeath, -1))
            end

            if killer == PlayerId() then
                reasonOfDeath = 'took the cowards way out'
            elseif killer == nil then
                reasonOfDeath = 'died of unknown causes or killed by NPC'
            else
                local deathActions = {
                    [IsMeleeWeapon] = 'murdered',
                    [IsFireWeapon] = 'torched',
                    [IsKnifeWeapon] = 'knifed',
                    [IsPistolWeapon] = 'pistoled',
                    [IsSmgWeapon] = 'riddled',
                    [IsRifleWeapon] = 'rifled',
                    [IsMachineGunWeapon] = 'machine gunned',
                    [IsShotgunWeapon] = 'pulverized',
                    [IsSniperWeapon] = 'sniped',
                    [IsBoomBoom] = 'blowed up',
                    [IsVehicle] = 'flattened',
                    [IsAnimal] = 'devoured',
                }

                for func, reason in pairs(deathActions) do
                    if func(causeOfDeath) then
                        reasonOfDeath = reason
                        break
                    end
                end
            end

            if reasonOfDeath == 'took the cowards way out' or reasonOfDeath == 'died of unknown causes or killed by NPC' then
                local message = '**' .. string.upper(GetPlayerName(PlayerId())) .. '** ' .. reasonOfDeath .. '.'
                SendPlayerDeath(message, weapon, streetStr, pos)
            else
                local message = '**' .. string.upper(GetPlayerName(killer)) .. '** ' .. reasonOfDeath .. ' **' .. string.upper(GetPlayerName(PlayerId())) .. '**.'
                SendPlayerDeath(message, weapon, streetStr, pos, killer)
            end

            if Config.Debug then
                print("^5DEBUG^7: ^2Hash:^7", causeOfDeath)
                print("^5DEBUG^7: ^2Killer:^7", sourceOfDeath)
                print("^5DEBUG^7: ^2Death coordinates:^7", pos)
                print("^5DEBUG^7: ^2Death Street:^7", streetStr)
                if reasonOfDeath == 'took the cowards way out and committed suicide' or reasonOfDeath == 'died of unknown causes or killed by NPC' then
                    print("^5DEBUG^7: ^2Suicide:^7", GetPlayerName(PlayerId()) .. ' ' .. reasonOfDeath .. '.', weapon)
                else
                    print("^5DEBUG^7: ^2Killed:^7", GetPlayerName(killer) .. ' ' .. reasonOfDeath .. ' ' .. GetPlayerName(PlayerId()) .. '.', weapon)
                end
            end

            while IsEntityDead(playerPed) do
                Citizen.Wait(0)
            end
        end
    end
end)

function IsWeaponOfType(weapon, types)
    for _, weaponType in ipairs(types) do
        if GetHashKey(weaponType) == weapon then
            return true
        end
    end
    return false
end

function IsMeleeWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_UNARMED', 'WEAPON_KNIFE', 'WEAPON_NIGHTSTICK', 'WEAPON_HAMMER', 'WEAPON_BAT', 'WEAPON_GOLFCLUB', 'WEAPON_CROWBAR', 'WEAPON_DAGGER', 'WEAPON_BOTTLE', 'WEAPON_HATCHET', 'WEAPON_KNUCKLE', 'WEAPON_BATTLEAXE', 'WEAPON_SWITCHBLADE', 'WEAPON_MACHETE', 'WEAPON_FLASHLIGHT', 'WEAPON_POOLCUE', 'WEAPON_WRENCH'})
end

function IsFireWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_MOLOTOV', 'WEAPON_FIRE'})
end

function IsKnifeWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_DAGGER', 'WEAPON_KNIFE', 'WEAPON_SWITCHBLADE', 'WEAPON_HATCHET', 'WEAPON_BOTTLE'})
end

function IsPistolWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_SNSPISTOL', 'WEAPON_HEAVYPISTOL', 'WEAPON_VINTAGEPISTOL', 'WEAPON_PISTOL', 'WEAPON_APPISTOL', 'WEAPON_COMBATPISTOL', 'WEAPON_MACHINEPISTOL', 'WEAPON_PISTOL50'})
end

function IsSmgWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_MICROSMG', 'WEAPON_SMG', 'WEAPON_ASSAULTSMG', 'WEAPON_MINISMG'})
end

function IsRifleWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_ASSAULTRIFLE', 'WEAPON_CARBINERIFLE', 'WEAPON_ADVANCEDRIFLE', 'WEAPON_SPECIALCARBINE', 'WEAPON_MARKSMANRIFLE', 'WEAPON_COMBATPDW', 'WEAPON_BULLPUPRIFLE', 'WEAPON_COMPACTRIFLE'})
end

function IsMachineGunWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_MG', 'WEAPON_COMBATMG'})
end

function IsShotgunWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_PUMPSHOTGUN', 'WEAPON_SAWNOFFSHOTGUN', 'WEAPON_ASSAULTSHOTGUN', 'WEAPON_BULLPUPSHOTGUN', 'WEAPON_HEAVYSHOTGUN', 'WEAPON_DBSHOTGUN', 'WEAPON_AUTOSHOTGUN'})
end

function IsSniperWeapon(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_SNIPERRIFLE', 'WEAPON_HEAVYSNIPER', 'WEAPON_ASSAULTSNIPER'})
end

function IsBoomBoom(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_GRENADELAUNCHER', 'WEAPON_RPG', 'WEAPON_GRENADE', 'WEAPON_STICKYBOMB', 'WEAPON_EXPLOSION', 'WEAPON_PIPEBOMB'})
end

function IsVehicle(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_RAMMED_BY_CAR', 'WEAPON_RUN_OVER_BY_CAR'})
end

function IsAnimal(weapon)
    return IsWeaponOfType(weapon, {'WEAPON_ANIMAL', 'WEAPON_COUGAR'})
end
