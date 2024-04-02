RegisterServerEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied', function(killedBy)
    TriggerClientEvent('rup-deathlog:client:onPlayerDied', source, killedBy, pos)
end)

RegisterServerEvent('rup-deathlog:server:onPlayerDied', function(killerCause, streetStr, pos)
    local playerName = GetPlayerName(source)
    local ids = GetPlayerIdentifiers(source)
    local webhookUrl = Config.Webhook
    
    local discordId = nil
    local steamId = nil

    for _, id in ipairs(ids) do
        if string.match(id, "^discord:") then
            discordId = string.gsub(id, "discord:", "")
        elseif string.match(id, "^steam:") then
            steamId = string.gsub(id, "steam:", "")
        end
    end

    if Config.Debug then
        print("^5DEBUG^7: ^2Player Name:^7", playerName)
        print("^5DEBUG^7: ^4Discord ID:^7", discordId)
        print("^5DEBUG^7: ^3Steam ID:^7", steamId)
    end
        
    local formattedPos = string.format("vector3(%.2f, %.2f, %.2f)", pos.x, pos.y, pos.z)

    local embed = {
        {
            ["title"] = "Player Death",

            ["author"] = { --[[ You Can comment this block out ]]
                ["name"] = 'RUP-SCRIPTS',
                ["icon_url"] = 'https://i.imgur.com/OZyXBv0.png',
                ["url"] ='https://discord.gg/PFwfnfUE6a',
            },            --[[ You Can comment this block out ]]

            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Player Name", ["value"] = playerName, ["inline"] = true},
                {["name"] = "Killer", ["value"] = killerCause, ["inline"] = true},
                {["name"] = "", ["value"] = "", ["inline"] = false},
                {["name"] = "Street", ["value"] = streetStr, ["inline"] = true},
                {["name"] = "Death Coordinates", ["value"] = formattedPos, ["inline"] = true},
            },
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ["footer"] = {
                ["text"] = "Player Death Log",
                ["icon_url"] = "https://i.imgur.com/OZyXBv0.png",
            },
        }
    }

    if discordId then
        table.insert(embed[1]["fields"], {["name"] = "Discord", ["value"] = '<@' .. discordId .. '>', ["inline"] = false})
    end

    if steamId then
        local steamProfileUrl = 'https://steamcommunity.com/profiles/' .. steamId
        table.insert(embed[1]["fields"], {["name"] = "Steam", ["value"] = steamProfileUrl, ["inline"] = false})
    end
    
    local jsonData = json.encode({embeds = embed})
    
    PerformHttpRequest(webhookUrl, function(err, text, headers) 
        if err ~= 200 and err ~= 204 then
            print("Error sending death log to Discord:", err)
        end
    end, 'POST', jsonData, {['Content-Type'] = 'application/json'})
end)