local playersData = {}
local playersDataLogged = {}
local playersDataActuall = {}

-- I updated this script to pretty much store player names also, I could reuse parts of this to learn
-- MySQL for other things.

MySQL.ready(function()
    print('MySQL ready')
    MySQL.Async.fetchAll('SELECT * FROM kc_playtime', {}, function(result)
        for i = 1, #result, 1 do
            -- result[i].identifier
            -- result[i].time
            -- result[i].login
            playersData[result[i].identifier] = result[i].time
            playersDataLogged[result[i].identifier] = result[i].login
            -- playersDataLogged[result[i].identifier] = result[i].playername
        end
    end)
end)


-----
-- Not exactly sure what this one is doing
-----
function SecondsToClock(seconds)
    if seconds ~= nil then
        local seconds = tonumber(seconds)

        if seconds <= 0 then
            return "00:00:00";
        else
            hours = string.format("%02.f", math.floor(seconds / 3600));
            mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
            secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
            return hours .. ":" .. mins .. ":" .. secs
        end
    end
end

-----
-- Log the time for when the player logs out
-----
function dropPlayer(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    local actuallTime = os.time()
    local name = GetPlayerName(source)
    if (playersData[identifier] ~= nil and playersDataActuall[identifier] ~= nil) then
        local time = tonumber(actuallTime - playersDataActuall[identifier])
        local timeFormatted = SecondsToClock(time)
        local timeAll = time + playersData[identifier]
        local timeAllFormatted = SecondsToClock(timeAll)

        -- Message to log in the console, TODO Add a toggle for this.
        local message = '`' ..
            name .. '` [' .. identifier ..
            ']\n Session time: `' .. timeFormatted .. '`\n' .. 'Total time: `' .. timeAllFormatted .. '`'

        -- sendToDiscord('Player left', message)

        print(message)

        -- MySQL.Async.execute('UPDATE kc_playtime SET time = @time WHERE identifier = @identifier',
        -- { ['time'] = timeAll, ['identifier'] = identifier },

        -----
        -- Update the player time in the 'kc_playtime' table
        -----
        MySQL.Async.execute(
            'UPDATE kc_playtime SET time = @time, playername = @playername WHERE identifier = @identifier',
            { ['time'] = timeAll, ['playername'] = name, ['identifier'] = identifier },
            function(affectedRows)
                --   print('Updated login')
            end
        )
        playersData[identifier] = timeAll

        -- TODO Setup this
        -- Make this log how many vehicles the player has blown up and how many they have stolen from the stats.
        -- For now this only logs how many vehicles have been blown up.
        -- Why doesn't this work in here?
        -- MySQL.Async.execute('UPDATE kc_stats SET vehicles_exploded = @vehicles_exploded, playername = @playername WHERE identifier = @identifier',
        --     { ['vehicles_exploded'] = carsBlownUp, ['playername'] = _playerName, ['identifier'] = identifier },
        --     function(affectedRows)
        --           print('Updated vehicles exploded stat')
        --     end
        -- )

        -- I'll just trigger the client event which passes the variables to the server.
        -- Well this didn't seem to work either.
        -- TriggerClientEvent('rgz_playtime:trackCarsBlownup', source)
    else
        --print('rgz_playtime didnt recognize player')
    end
end

-----
-- Discord message hook, I could possibly reuse this.
-- I'm probably not going to use this for now so I disabled it.
-----
-- function sendToDiscord(name, message, footer)
--     if Config.WebhookLink ~= '' then
--         local embed = {
--             {
--                 ["color"] = 2067276,
--                 ["title"] = name,
--                 ["description"] = message,
--             }
--         }

--         PerformHttpRequest(Config.WebhookLink, function(err, text, headers) end, 'POST',
--             json.encode({ username = name, embeds = embed }), { ['Content-Type'] = 'application/json' })
--     else
--         print('^1[rgz_playtime] Error:^0 Config.WebhookLink is empty!')
--     end
-- end

-- function updateVehiclesBlownupStat(source, carsBlownUp)
-- TriggerEvent('rgz_playtime:logVehiclesBlownUpStat', source, carsBlownUp)
-- end

-- TODO Make this log the stat when the player leaves
-- I guess I could set it up to run the update in loggedIn every 5 seconds or 15 seconds to update this for now.



-----
-- Player disconnect event
-----
AddEventHandler('playerDropped', function(reason)
    dropPlayer(source, reason)
    -- TODO Test this here
    -- Well this doesn't work either. Not sure how to fire this off when the client leaves.
    -- TriggerClientEvent('rgz_playtime:trackCarsBlownup', source)
end)

-----
-- Event that fires off when the player spawns.
-----
RegisterNetEvent('rgz_playtime:loggedIn')
AddEventHandler('rgz_playtime:loggedIn', function(playerName)
-- AddEventHandler('rgz_playtime:loggedIn', function(playerName, carsBlownUp)
    local _source = source
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]
    local actuallTime = os.time()

    if playersData[identifier] ~= nil then
        playersDataActuall[identifier] = actuallTime
        playersDataLogged[identifier] = playersDataLogged[identifier] + 1
        local totaltimeFormatted = SecondsToClock(playersData[identifier])

        -- Update the kc_playtime table
        -- MySQL.Async.execute('UPDATE kc_playtime SET login = login + 1 WHERE identifier = @identifier',

        -----
        -- Update the login count, add 1 to it each login.
        -----
        MySQL.Async.execute(
            'UPDATE kc_playtime SET login = login + 1, playername = @playername WHERE identifier = @identifier',
            -- { ['identifier'] = identifier },
            { ['playername'] = _playerName, ['identifier'] = identifier },
            function(affectedRows)
                if DebugConfig.DbLogging then
                    print('Updated login count')
                end
            end
        )

        -- TriggerClientEvent('rgz_playtime:updateCarsBlownUpStat', _source, )

        -- TODO Fix this to work, not sure if it is needed here.
        -- TODO Make this grab the old value from the database, not exactly sure how to do that just yet.
        -- MySQL.Async.execute(
        --     'UPDATE kc_stats SET vehicles_exploded = vehicles_exploded, playername = @playername WHERE identifier = @identifier',
        --     -- { ['vehicles_exploded'] = carsBlownUp, ['playername'] = _playerName, ['identifier'] = identifier },
        --     { ['playername'] = _playerName, ['identifier'] = identifier },
        --     function(affectedRows)
        --         if DebugConfig.DbLogging then
        --             print('Updated vehicles exploded stat')
        --         end
        --     end
        -- )

        -- TODO Setup a client event trigger that sets the stats back to what they are from the DB
        -- I think that is what I am missing.
        -- This might work?
        -- Well this didn't work.
        TriggerEvent('rgz_playtime:getVehiclesBlownUpStat')


        -- carsBlownUp

        TriggerClientEvent('rgz_playtime:notif', _source,
            Config.Strings['welcome'] ..
            '\n' ..
            Config.Strings['ptotaltime'] ..
            '~b~' ..
            totaltimeFormatted .. '~s~\n' ..
            string.format(Config.Strings['loggedin'], playersDataLogged[identifier]))
    else
        playersDataActuall[identifier] = actuallTime
        playersData[identifier] = 0

        -----
        -- Setup the player time and login count.
        -----
        -- MySQL.Async.execute('INSERT INTO kc_playtime (identifier, time, login) VALUES (@identifier, @time, @login)',
        MySQL.Async.execute(
            'INSERT INTO kc_playtime (identifier, playername, time, login) VALUES (@identifier, @playername, @time, @login)',
            { ['identifier'] = identifier, ['playername'] = _playerName, ['time'] = 0, ['login'] = 0 },
            function(affectedRows)
                if DebugConfig.DbLogging then
                    --   print(affectedRows)
                end
            end
        )


        -- This seems like it is working now, if the player doesn't have a value in the 'kc_playtime' or 'kc_stats' tables,
        -- this will run.
        MySQL.Async.execute(
            'INSERT INTO kc_stats (identifier, playername, vehicles_exploded) VALUES (@identifier, @playername, @vehicles_exploded)',
            -- { ['vehicles_exploded'] = carsBlownUp, ['playername'] = _playerName, ['identifier'] = identifier },
            { ['identifier'] = identifier, ['playername'] = _playerName, ['vehicles_exploded'] = 0 },
            function(affectedRows)
                if DebugConfig.DbLogging then
                    print('Created vehicles exploded table')
                end
            end
        )


        TriggerClientEvent('rgz_playtime:notif', _source, Config.Strings['welcome1st'])
    end
end)

-----
-- Setup the vehicles blown up table, could be useful for later.
-----
RegisterServerEvent('rgz_playtime:setupVehiclesBlownUpTable')
AddEventHandler('rgz_playtime:setupVehiclesBlownUpTable', function(playerName)
    local _source = source
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]

    -- This works here!
    MySQL.Async.execute(
        'INSERT INTO kc_stats (identifier, playername, vehicles_exploded) VALUES (@identifier, @playername, @vehicles_exploded)',
        -- { ['vehicles_exploded'] = carsBlownUp, ['playername'] = _playerName, ['identifier'] = identifier },
        { ['identifier'] = identifier, ['playername'] = _playerName, ['vehicles_exploded'] = 0 },
        function(affectedRows)
            if DebugConfig.DbLogging then
                print('Created vehicles exploded table')
            end
        end
    )

    -- TriggerClientEvent('rgz_playtime:notif', _source, "Setup vehicles stat in DB.")
end)



-----
-- Log the vehicles blown up to the mysql database
-- This is set to run every 5 seconds in the client.lua, so it's not running too often.
-----
RegisterServerEvent('rgz_playtime:logVehiclesBlownUpStat')
AddEventHandler('rgz_playtime:logVehiclesBlownUpStat', function(playerName, carsBlownUp)
    local _source = source
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]

    -- print(carsBlownUp)

    if playersData[identifier] ~= nil then
        playersDataActuall[identifier] = actuallTime
        playersDataLogged[identifier] = playersDataLogged[identifier] + 1
        -- local totaltimeFormatted = SecondsToClock(playersData[identifier])

        -- This works in here!
        MySQL.Async.execute(
            'UPDATE kc_stats SET vehicles_exploded = @vehicles_exploded, playername = @playername WHERE identifier = @identifier',
            { ['vehicles_exploded'] = carsBlownUp, ['playername'] = _playerName, ['identifier'] = identifier },
            function(affectedRows)
                -- This can be very spammy every 5 seconds or so.
                -- if DebugConfig.DbLogging then
                --     print('Updated vehicles exploded stat')
                -- end
            end
        )


        -- Run this to update the display on screen.
        -- TriggerClientEvent('rgz_playedtime:updateVehicleBlownupDisplay', _source, row.vehicles_exploded)
        TriggerClientEvent('rgz_playedtime:updateVehicleBlownupDisplay', _source, carsBlownUp)


        -- These become very spammy if running this every 5 seconds.
        -- TriggerClientEvent('rgz_playtime:notif', _source,
        -- string.format(Config.Strings['cars_blown_up'], carsBlownUp))

        -- print(("Cars blown up logged: %i"):format(carsBlownUp))
    end
end)

-----
-- Query the stat for the commands and displaying in game.
-----
RegisterServerEvent('rgz_playtime:getVehiclesBlownUpStat')
AddEventHandler('rgz_playtime:getVehiclesBlownUpStat', function(playerName)
    local _source = source
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]

    -- print(carsBlownUp)

    if playersData[identifier] ~= nil then
        playersDataActuall[identifier] = actuallTime
        playersDataLogged[identifier] = playersDataLogged[identifier] + 1
        -- local totaltimeFormatted = SecondsToClock(playersData[identifier])

        -- This works in here!
        -- This works for logging to the console
        -- https://coxdocs.dev/oxmysql/Functions/query
        MySQL.Async.fetchAll('SELECT `vehicles_exploded` from `kc_stats` WHERE `identifier` = ?',
            {
                identifier
            }, function(response)
                if response then
                    for i = 1, #response do
                        local row = response[i]

                        local consoleMessage = ("%s - Vehicles exploded: %i"):format(playerName, row.vehicles_exploded)
                        local playerMessage = ("You have blown up: %i vehicles."):format(row.vehicles_exploded)

                        if DebugConfig.DebugLogging then
                            print(consoleMessage)
                        end


                        -- First, sync the previous stats
                        -- TODO Test this
                        TriggerClientEvent('rgz_playtime:updateCarsBlownUpStat', _source, row.vehicles_exploded)
                        --

                        TriggerClientEvent('rgz_playtime:notif', _source, playerMessage)

                        -- Set the message in the game, TODO Test this.
                        -- This works as an event!
                        TriggerClientEvent('rgz_playedtime:updateVehicleBlownupDisplay', _source, row.vehicles_exploded)
                    end
                end
            end
        )
        -- These become very spammy if running this every 5 seconds.
        -- TriggerClientEvent('rgz_playtime:notif', _source,
        -- string.format(Config.Strings['cars_blown_up'], carsBlownUp))

        -- print(("Cars blown up logged: %i"):format(carsBlownUp))
    end
end)

RegisterCommand('time2', function(source)
    dropPlayer(source)
end, false)
