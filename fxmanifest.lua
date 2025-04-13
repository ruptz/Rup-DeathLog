fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Ruptz'
description 'Death Logger For Discord'
version '2.0.5'
repository 'https://github.com/ruptz/Rup-DeathLog'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

dependency 'ox_lib'