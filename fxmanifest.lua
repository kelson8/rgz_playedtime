fx_version 'bodacious'
game 'gta5'

-- This requires oxmysql.
dependencies {'oxmysql'}

-- Ox My Sql support
server_script '@oxmysql/lib/MySQL.lua'

-- client_script 'client.lua'
client_scripts{
  'config.lua',
  'client.lua'
}

server_scripts {
	-- '@mysql-async/lib/MySQL.lua',
	'server.lua',
	'config.lua',
}