fx_version 'bodacious'
game 'gta5'

-- This requires oxmysql.
dependencies {'oxmysql'}

-- Ox My Sql support
server_script '@oxmysql/lib/MySQL.lua'

-- shared_script 'shared/shared.lua'

-- client_script 'client.lua'
client_scripts {
  'config/config.lua',
  'client/functions.lua',
  'client/client.lua'
}

server_scripts {
	-- '@mysql-async/lib/MySQL.lua',
	'config/config.lua',
	'server/server.lua',
}