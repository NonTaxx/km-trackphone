fx_version 'cerulean'
game 'gta5'

author 'Kosmonautas - https://github.com/NonTaxx'
lua54 'yes'

ui_page 'web/index.html'
files { 'web/*' }

client_scripts { 'client/client.lua' }
shared_scripts { 'config.lua', '@ox_lib/init.lua', "locales/locale.lua", "locales/translations/*.lua" }
server_scripts { '@mysql-async/lib/MySQL.lua', 'server/server.lua'}