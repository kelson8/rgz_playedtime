Screen = {}

Vehicles = {}

-- TODO Figure out why this overwrites my KCNet text display.

local color = {
    -- Set to light green
    r = 10,
    g = 255,
    b = 150,
    a = 255,
}

-- This gets set if the 
Vehicles.BlownUp = 0

function Screen.SetTextEntry()
    SetTextFont(0) -- 0 -> 4
    SetTextScale(0.3, 0.3)
    SetTextColour(color.r, color.g, color.b, color.a)
    -- SetTextEntry("STRING")
    -- Test
    BeginTextCommandDisplayText("STRING")
end

-- Set the text position with a custom x, and y value
function Screen.TextPosition(x, y)
    EndTextCommandDisplayText(x, y)
end

-- Set the text position with a fixed x value of 0.0001
function Screen.TextPositionFixed(y)
    EndTextCommandDisplayText(0.0001, y)
end

-- Set text under KCNet test text, I normally leave the Z value alone
function Screen.TextPositionOne()
    -- Screen.TextPosition(0.0200)
    -- Screen.TextPositionFixed(0.0500)
    Screen.TextPosition(0.0001, 0.0200)
    -- EndTextCommandDisplayText(0.0001, 0.0200, 0)
end

function Screen.DrawText(text)
    AddTextComponentSubstringPlayerName(text)
end

RegisterNetEvent('rgz_playedtime:updateVehicleBlownupDisplay')
AddEventHandler('rgz_playedtime:updateVehicleBlownupDisplay', function (vehiclesBlownUp)
    Vehicles.BlownUp = vehiclesBlownUp
end)

CreateThread(function()
    local player = GetPlayerPed(-1)

    while DebugConfig.DebugMode do
        -- while true do
        Wait(1)
        Screen.SetTextEntry()

        if Vehicles.BlownUp ~= 0 or Vehicles.BlownUp ~= nil then
            -- AddTextComponentSubstringPlayerName(("Vehicles blown up: %s"):format(Vehicles.BlownUp))
            Screen.DrawText(("Vehicles blown up: %s"):format(Vehicles.BlownUp))
            -- Oops, I forgot to set these here.
            Screen.TextPositionOne()
        else
            -- AddTextComponentSubstringPlayerName("No vehicles blown up")
            Screen.DrawText("No vehicles blown up")
            Screen.TextPositionOne()
        end

    end
end)