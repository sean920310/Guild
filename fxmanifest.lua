fx_version 'cerulean'

game "gta5"

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server.lua",
}

client_scripts {
    "config.lua",
    "client.lua",
}

ui_page "html/index.html"

files {
    'html/index.html',
    'html/index.js',
    'html/index.css',
    'html/asset/img/*.png'
}
