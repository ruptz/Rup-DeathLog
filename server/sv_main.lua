function GetDiscordId(identifiers)
    for _, id in ipairs(identifiers) do
        if string.match(id, "^discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

RegisterServerEvent('rup-deathlog:OnPlayerKilled', function(data)
    local webhookUrl = Config.Discord.Settings.Webhook
    local sourcePlayer = source
    local playerName = GetPlayerName(sourcePlayer)
    
    -- Gimmie data!
    local message = data.message
    local weapon = data.weapon
    local street = data.street
    local coords = data.coords
    local killerServerId = data.killer

    -- Get victim identifiers
    local victimIds = GetPlayerIdentifiers(sourcePlayer)
    local victimDiscordId = GetDiscordId(victimIds)

    -- Get killer identifiers
    local killerDiscordId
    if killerServerId and killerServerId > 0 then
        local killerIds = GetPlayerIdentifiers(killerServerId)
        killerDiscordId = GetDiscordId(killerIds)
    end

    if Config.Debug then
        print("^5DEBUG^7: ^4Player Name:^7", playerName)
        print("^5DEBUG^7: ^4Victim Discord ID:^7", victimDiscordId)
        print("^5DEBUG^7: ^4Killer Discord ID:^7", killerDiscordId)
        print("^5DEBUG^7: ^8Message:^7", message)
        print("^5DEBUG^7: ^2Weapon:^7", weapon)
        print("^5DEBUG^7: ^3Street:^7", street)
        print("^5DEBUG^7: ^3Position:^7", coords)
    end

    local formattedPos = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)
    local killerName = killerServerId and GetPlayerName(killerServerId) or "Unknown"

    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = "Player Death",
            ["author"] = {
                ["name"] = 'RUP-SCRIPTS',
                ["icon_url"] = Config.Discord.Settings.Images,
                ["url"] = 'https://discord.gg/PFwfnfUE6a',
            },
            ["fields"] = {
                {["name"] = "Victim", ["value"] = playerName, ["inline"] = true},
                {["name"] = "Killer", ["value"] = killerName, ["inline"] = true},
                {["name"] = "Description", ["value"] = message, ["inline"] = false},
                {["name"] = "Weapon", ["value"] = weapon or "Unknown", ["inline"] = true},
                {["name"] = "Street", ["value"] = street, ["inline"] = true},
                {["name"] = "Coordinates", ["value"] = formattedPos, ["inline"] = true},
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ["footer"] = {
                ["text"] = "Player Death Log",
                ["icon_url"] = Config.Discord.Settings.Images,
            },
        }
    }

    -- Add Discord mentions
    if victimDiscordId then
        table.insert(embed[1].fields, {["name"] = "Victim's Discord", ["value"] = '<@'..victimDiscordId..'>', ["inline"] = true})
    end

    if killerDiscordId then
        table.insert(embed[1].fields, {["name"] = "Killer's Discord", ["value"] = '<@'..killerDiscordId..'>', ["inline"] = true})
    end

    PerformHttpRequest(webhookUrl, function(err, text, headers)
        if err == 0 then
            print("^5DEBUG^7: ^7Add your ^8webhook^7 in ^8Config.lua^7!!! Error:", err)
        elseif err ~= 200 and err ~= 204 then
            print("^5DEBUG^7: ^4Error sending death log to Discord:^7 Error:", err)
        end
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end)