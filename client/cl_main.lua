-- You can edit the reasons, I kind of made it like GTA:O
local DEATH_MESSAGES = {
    ['Melee'] = 'was killed in close combat',
    ['Pistol'] = 'was shot',
    ['Assault Rifle'] = 'was rifled down',
    ['Shotgun'] = 'was blasted',
    ['LMG'] = 'was mowed down',
    ['SMG'] = 'was sprayed',
    ['Sniper'] = 'was sniped',
    ['Heavy'] = 'was obliterated',
    ['Stunned'] = 'was zapped',
    ['Throwable'] = 'was exploded',
    ['default'] = 'was killed'
}

-- This uses GetWeapontypeGroup() native, https://docs.fivem.net/natives/?_0xC3287EE3050FB74C
-- I like this native a lot more than having 80000000 lines of weapons for no reason!
-- Custom weapons have a meta for them so they will be added in dynamically!
local function getWeaponGroup(causeOfDeath)
    local weaponGroup = GetWeapontypeGroup(causeOfDeath)
    if Config.Debug then
        print("^5DEBUG^7: ^4Weapon Group:^7", weaponGroup)
    end
    return Config.Weapon_Groups[weaponGroup] or 'Unknown'
end

local function handlePlayerDeath()
    local causeOfDeath = GetPedCauseOfDeath(cache.ped)
    local sourceOfDeath = GetPedSourceOfDeath(cache.ped)
    local coords = GetEntityCoords(cache.ped)
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    
    local killerServerId
    local vehicleName
    local isVehicleKill = false
    
    if sourceOfDeath ~= 0 then
        if IsEntityAVehicle(sourceOfDeath) then
            local driver = GetPedInVehicleSeat(sourceOfDeath, -1)
            local driver = GetPedInVehicleSeat(sourceOfDeath, -1)
            if driver ~= 0 then
                if IsPedAPlayer(driver) then
                    local veh = GetVehiclePedIsIn(driver)
                    local modelHash = GetEntityModel(veh)
                    local modelName = GetDisplayNameFromVehicleModel(modelHash)
                    vehicleName = GetLabelText(modelName)
                    
                    if vehicleName == "NULL" then
                        vehicleName = modelName
                    end
                    
                    killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(driver))
                    
                    if Config.Debug then
                        print("^5DEBUG^7: ^4Vehicle Hash:^7", modelHash)
                        print("^5DEBUG^7: ^4Vehicle Internal Name:^7", modelName)
                        print("^5DEBUG^7: ^4Vehicle Display Name:^7", vehicleName)
                    end
                end
                isVehicleKill = true
            end
        elseif IsEntityAPed(sourceOfDeath) and IsPedAPlayer(sourceOfDeath) then
            killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(sourceOfDeath))
        end
    end

    -- Death Reasons
    local weaponGroup = getWeaponGroup(causeOfDeath)
    local deathReason = DEATH_MESSAGES[weaponGroup] or DEATH_MESSAGES.default
    local weaponName = weaponGroup

    -- Vehicle or fall damage or slapped by an animal 0-0
    -- You can add more hashes here for other things, I would appriciate sending me them to add on to the script or make a Pull req :)
    if isVehicleKill then
        deathReason = 'was flattened'
        weaponName = vehicleName
    elseif causeOfDeath == -842959696 then
        deathReason = 'fell to their death'
        weaponName = 'Fall Damage'
    elseif causeOfDeath == -100946242 or 148160082 then
        deathReason = 'was mauled by an animal'
        weaponName = 'Animal'
    end

    -- See if suicide
    if killerServerId and killerServerId == cache.serverId then
        deathReason = 'committed suicide'
        weaponName = weaponGroup == 'Vehicle' and 'Vehicle' or 'Self-inflicted'
    end

    local victimName = GetPlayerName(PlayerId())
    local message
    
    if killerServerId then
        local killerName = GetPlayerName(GetPlayerFromServerId(killerServerId)) or 'Unknown'
        message = string.format('**%s** %s by **%s** with a %s',
            victimName,
            deathReason,
            killerName,
            weaponName
        )
    else
        message = string.format('**%s** %s (%s)',
            victimName,
            deathReason,
            weaponName
        )
    end

    -- Send to webhook
    TriggerServerEvent('rup-deathlog:OnPlayerKilled', {
        message = message,
        weapon = weaponName,
        street = streetName,
        coords = coords,
        killer = killerServerId
    })

    if Config.Debug then
        print('^5Death Details^7:', json.encode({
            cause = causeOfDeath,
            weapon_group = weaponGroup,
            weapon_name = weaponName,
            killer = killerServerId,
            pos = coords,
            is_vehicle = isVehicleKill
        }, { indent = true }))
    end
end

-- Thread, this is 10x better than the thread before xD
CreateThread(function()
    local wasDead = false
    while true do
        Wait(Config.Interval)
        if cache.ped then
            local isDead = IsEntityDead(cache.ped)
            if isDead and not wasDead then
                handlePlayerDeath()
            end
            wasDead = isDead
        end
    end
end)