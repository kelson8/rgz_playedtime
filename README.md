# rgz_playedtime
Fivem total time played

I am working on adding a vehicles blown up stat and I will most likely add more to this later.

So far it can log the vehicles blown up for however long is specified in the config into the database.

No ESX or framework needed, only dependency is OxMySql and MariaDb/MySql.

I have a few commands in this (Will add permission support for them later):
* /time1 - Log player play time stats, test for also updating the cars blown up stat.
* /time2 - Log player play time stats and show an updated login count, updates the MySql db also 
* /stat_cars_exploded - Manually update the cars exploded stat, this runs every 5 seconds and is here for testing.
* /setup_vehicle_stats - Setup the vehicle stats table in the database, this should automatically run if the user hasn't logged in before.

## Config
So far there is only message options in the config for the logs and events, I may work on getting the discord webhook working later on.

## Requirements
OxMySql (New CommunityOx fork): 
* https://github.com/communityox/oxmysql/releases

MariaDB/MySql (For database support):
* MariaDB: https://mariadb.org/download/
* MySql: https://dev.mysql.com/downloads/installer/

## Credits
Adam-rGz on GitHub for this resource: 
* https://github.com/Adam-rGz/rgz_playedtime
