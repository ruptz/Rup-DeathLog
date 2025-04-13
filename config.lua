Config = {
    --[[ Debug ]]
    Debug =  true,

    --[[ Thread options ]]
    Interval = 1000 -- msec, so 1000 is 1 second!

    --[[ Weapon Groups ]]
    Weapon_Groups = {
        [2685387236] = 'Melee',  -- GROUP_UNARMED
        [-1609580060] = 'Melee', -- GROUP_UNARMED
        [4257178988] = 'Melee', -- GROUP_FIREEXTINGUISHER
        [-37788308] = 'Melee', -- GROUP_FIREEXTINGUISHER
        [3566412244] = 'Melee', -- GROUP_MELEE
        [-728555052] = 'Melee', -- GROUP_MELEE
        --[[ Guns ]]
        [416676503] = 'Pistol', -- GROUP_PISTOL
        [970310034] = 'Assault Rifle', -- GROUP_RIFLE
        [860033945] = 'Shotgun', -- GROUP_SHOTGUN
        [1159398588] = 'LMG', -- GROUP_MG
        [3337201093] = 'SMG', -- GROUP_SMG
        [-957766203] = 'SMG', -- GROUP_SMG
        [3082541095] = 'Sniper', -- GROUP_SNIPER
        [-1212426201] = 'Sniper', -- GROUP_SNIPER
        --[[ Misc ]]
        [2725924767] = 'Heavy', -- GROUP_HEAVY
        [-1569042529] = 'Heavy', -- GROUP_HEAVY
        [690389602] = 'Stunned', -- GROUP_STUNGUN
        [1548507267] = 'Throwed', -- GROUP_THROWN
    },

    --[[ Discord ]]
    Discord = {
        Settings = {
            Webhook = 'https://discord.com/api/webhooks/1360996794544296087/AnbFGodfZJwCSajk7vAzwrD-8oMn91UR_sHdWaop8jmSz6ZYotDAoTJ32cLaYYLq9ef1',
            Name = 'Death Logs',
            Images = 'https://i.imgur.com/OZyXBv0.png'
        },
    },
}