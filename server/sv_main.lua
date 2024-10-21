RegisterServerEvent('rup-deathlog:OnPlayerKilled', function(Message, Weapon, Street, Position, Killer)
    local webhookUrl = Config.Discord.Settings.Webhook
    local playerName = GetPlayerName(source)
    local ids = GetPlayerIdentifiers(source)
    local idsK = GetPlayerIdentifiers(Killer)
    
    local victimId = nil
    local killerId = nil

    for _, id in ipairs(ids) do
        if string.match(id, "^discord:") then
            victimId = string.gsub(id, "discord:", "")
        end
    end

    if Killer then
        for _, id in ipairs(idsK) do
            if string.match(id, "^discord:") then
                killerId = string.gsub(id, "discord:", "")
            end
        end
    end

    if Config.Debug then
        print("^5DEBUG^7: ^4Player Name:^7", playerName)
        print("^5DEBUG^7: ^4Victim Discord ID:^7", victimId)
        print("^5DEBUG^7: ^4Killer Discord ID:^7", killerId)
        print("^5DEBUG^7: ^8Message:^7", Message)
        print("^5DEBUG^7: ^2Weapon:^7", Weapon)
        print("^5DEBUG^7: ^3Street:^7", Street)
        print("^5DEBUG^7: ^3Position:^7", Position)
    end

    local formattedPos = string.format("vector3(%.2f, %.2f, %.2f)", Position.x, Position.y, Position.z)

    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = "Player Death",

            ["author"] = { --[[ You Can comment this block out ]]
                ["name"] = 'RUP-SCRIPTS',
                ["icon_url"] = Config.Discord.Settings.Images,
                ["url"] = 'https://discord.gg/PFwfnfUE6a',
            },            --[[ You Can comment this block out ]]

            ["fields"] = {
                {["name"] = "Victim", ["value"] = playerName, ["inline"] = true},
                {["name"] = "Killer", ["value"] = (Killer and GetPlayerName(Killer) or "Unknown"), ["inline"] = true},
                {["name"] = "", ["value"] = "", ["inline"] = false},
                {["name"] = "Description", ["value"] = Message, ["inline"] = true},
                {["name"] = "", ["value"] = "", ["inline"] = false},
                {["name"] = "Weapon", ["value"] = (Weapon or "Unknown"), ["inline"] = true},
                {["name"] = "Street", ["value"] = Street, ["inline"] = true},
                {["name"] = "Death Coordinates", ["value"] = formattedPos, ["inline"] = true},
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ["footer"] = {
                ["text"] = "Player Death Log",
                ["icon_url"] = Config.Discord.Settings.Images,
            },
        }
    }

    if victimId then
        table.insert(embed[1]["fields"], {["name"] = "Victims Discord", ["value"] = '<@' .. victimId .. '>', ["inline"] = true})
    end

    if killerId then
        table.insert(embed[1]["fields"], {["name"] = "Killers Discord", ["value"] = '<@' .. killerId .. '>', ["inline"] = true})
    end

    local jsonData = json.encode({embeds = embed})

    PerformHttpRequest(webhookUrl, function(err, text, headers)
        if err == 0 then
            print("^5DEBUG^7: ^7Add your ^8webhook^7 in ^8Config.lua^7!!! Error:", err)
        elseif err ~= 200 and err ~= 204 then
            print("^5DEBUG^7: ^4Error sending death log to Discord:^7 Error:", err)
        end
    end, 'POST', jsonData, {['Content-Type'] = 'application/json'})
end)
