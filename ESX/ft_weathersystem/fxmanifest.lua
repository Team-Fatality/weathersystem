fx_version 'cerulean'
game 'gta5'

name "ft_weathersystem"
author "PAPU (!PAPU.・ᶠᵀ#6969)"
version "1.0"

shared_scripts { 
    '@ox_lib/init.lua', 
    'shared/*' 
}

client_scripts {
    'client/*'
}

server_scripts {
    'server/*'
}

ui_page 'dist/index.html'

files { 
    'dist/*', 
    'dist/assets/*', 
    'dist/images/*' 
}

lua54 'yes'
