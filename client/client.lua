function notification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

-- Well for some reason this just wipes the vehicles blown up stat if I exit FiveM and relaunch it.

local firstSpawn = false

TriggerEvent('chat:addSuggestion', '/stat_cars_exploded',
	'Update your vehicles exploded in the database')

TriggerEvent('chat:addSuggestion', '/setup_vehicle_stats',
	'Setup the stats table in the database with the vehicles exploded.')

TriggerEvent('chat:addSuggestion', '/get_blown_up',
	'List how many vehicles you have blown up from the database.')

TriggerEvent('chat:addSuggestion', '/time1',
	'Update the logged in stat for playtime and play count.')

function getCarsBlownUp()
	local player = GetPlayerPed(-1)
	local carsBlownUpStat = GetHashKey("MP0_CARS_EXPLODED")
	local _, carsBlownUp = StatGetInt(carsBlownUpStat, -1)
	return carsBlownUp
end

-- I got this working! Now it restores the previous stats.
RegisterNetEvent('rgz_playtime:updateCarsBlownUpStat')
AddEventHandler('rgz_playtime:updateCarsBlownUpStat', function (carsBlownUp)
	local carsBlownUpStat = GetHashKey("MP0_CARS_EXPLODED")
	StatSetInt(carsBlownUpStat, carsBlownUp, true)
end)

-----
-- Events
-----

AddEventHandler('playerSpawned', function()
	local carsBlownUp = getCarsBlownUp()
	if firstSpawn == false then
		TriggerServerEvent('rgz_playtime:loggedIn', GetPlayerName(PlayerId()))
		-- TriggerServerEvent('rgz_playtime:loggedIn', GetPlayerName(PlayerId()), carsBlownUp)
		firstSpawn = true
	end
end)



RegisterNetEvent('rgz_playtime:notif')
AddEventHandler('rgz_playtime:notif', function(msg)
	notification(msg)
end)


-- Well this works if i manually run the 'trigger_stat_update' command but doesn't run on disconnect like the
-- playtime tracker does, I would like to fix that.

-- TODO Fix this to where it grabs the old value if there is one instead of restting it when relaunching the game.
RegisterNetEvent('rgz_playtime:trackCarsBlownup')
AddEventHandler('rgz_playtime:trackCarsBlownup', function()
	-- end)
	-- https://forum.cfx.re/t/question-difference-between-getplayerped-1-and-playerpedid/539437
	local player = PlayerPedId()
	-- TODO Move into server side for MySQL, putting in here for testing.
	-- function carsBlownUpCheck()
	local carsBlownUp = getCarsBlownUp()

	-- TriggerServerEvent('rgz_playtime:addCarsBlownUpToDb')

	-- TODO Test this.
	-- print(("Cars blown up: %d"):format(carsBlownUp))
	-- This fixed it!! Now the previous stats show up from the DB.
	if carsBlownUp ~= 0 then
		TriggerServerEvent('rgz_playtime:logVehiclesBlownUpStat', GetPlayerName(PlayerId()), carsBlownUp)
	else
		-- Sync up the previous stats
		TriggerServerEvent('rgz_playtime:getVehiclesBlownUpStat', GetPlayerName(PlayerId()))
	end
end)

-----
-- Commands
-----
---

RegisterCommand('time1', function(source)
	local carsBlownUp = getCarsBlownUp()

	TriggerServerEvent('rgz_playtime:loggedIn', GetPlayerName(PlayerId()), carsBlownUp)
end, false)

-- This works for adding vehicles blown up to the database.
RegisterCommand("stat_cars_exploded", function()
	-- print(("Cars exploded: %d"):format(carsBlownUpCheck()))
	-- local carsBlownUp = TriggerEvent('rgz_playtime:trackCarsBlownup')
	TriggerEvent('rgz_playtime:trackCarsBlownup')
	-- print(carsBlownUp)
end, false)


-- Init the stats, this is setup in the other event so it is just here for testing now or if needed.
RegisterCommand("setup_vehicle_stats", function()
	TriggerServerEvent('rgz_playtime:setupVehiclesBlownUpTable', GetPlayerName(PlayerId()))
end, false)

-- List the vehicles blown up from the database.
RegisterCommand("get_blown_up", function()
	TriggerServerEvent('rgz_playtime:getVehiclesBlownUpStat', GetPlayerName(PlayerId()))
end, false)

-- This runs however long the timer is set for in the config.
Citizen.CreateThread(function()
	while true do
		Wait(Config.LogWaitTime)
		local carsBlownUp = getCarsBlownUp()

		-- Log the vehicles blown up.
		-- This fixed it!! Now the previous stats show up from the DB.
		if carsBlownUp ~= 0 then
			TriggerServerEvent('rgz_playtime:logVehiclesBlownUpStat', GetPlayerName(PlayerId()), carsBlownUp)
		else
			-- Sync up the previous stats
			TriggerServerEvent('rgz_playtime:getVehiclesBlownUpStat', GetPlayerName(PlayerId()))
		end
	end
end)
