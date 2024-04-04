local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

PerformHttpRequest('https://raw.githubusercontent.com/ruptz/Rup-DeathLog/main/version.txt', function(error, newestVersion, headers)
    if (currentVersion) == (newestVersion) then
        print('^2Script is Up To Date.^7')
        print('^7If you like my work please consider joining my ^4Discord^7 server.^7')
        print('https://discord.gg/PFwfnfUE6a')
    elseif (currentVersion) < (newestVersion) then
        print('^8Current Version: ' .. currentVersion .. '^7')
        print('^2Newest Version: ' .. newestVersion .. '^7')
        print('^8Outdated Version, Please Update.^7')
        print('https://github.com/ruptz/Rup-DeathLog')
    end
end)