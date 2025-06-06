Config = {}

Config.Webhook = false
Config.WebhookLink = 'https://discord.com/api/webhooks/123456/6p-asd'

Config.Strings= {
	['playerleft'] = 'Player left',
	['sessiontime'] = 'Session time',
	['totaltime'] = 'Total time',
	-- player notifications
	['welcome1st'] = 'Welcome to the KCNet FiveM Server!',
	-- ['welcome1st'] = 'Welcome on our server!',
	['welcome'] = 'Welcome back!',
	['ptotaltime'] = 'Total time spent on server: ',
	['loggedin'] = 'You have logged in ~y~%s~s~ times',

	['cars_blown_up'] = 'You have blown up ~y~%s~s~ cars.',
}

-- Time for the logs to be updated in the database, for now this is just hooked up to my vehicles exploded stat
-- The time is in miliseconds.
Config.LogWaitTime = 5000

DebugConfig = {
	DebugLogging = false,
	DbLogging = false,

	-- Enable debug text on screen for now.
	DebugMode = true,
}