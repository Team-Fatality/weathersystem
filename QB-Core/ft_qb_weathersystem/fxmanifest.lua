fx_version 'cerulean'
game 'gta5'

name "ft_starterpack"
author "PAPU (!PAPU.・ᶠᵀ#6969)"
version "1.0"

shared_scripts { 
    '@ox_lib/init.lua', 
    'shared/*' 
}

client_scripts {
    'locales/*',
    'client/*'
}

server_scripts {
    'locales/*',
    'server/*'
}

ui_page 'dist/index.html'

files { 
    'dist/*', 
    'dist/assets/*', 
    'dist/images/*' 
}

escrow_ignore {
    'locales/*',
    'shared/*',
    'client/edit.lua',
    'server/edit.lua',
    'INSTALL-FIRST/*'
}

lua54 'yes'

dependencies {
    'ox_lib',
}