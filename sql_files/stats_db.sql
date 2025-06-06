
-- CREATE TABLE IF NOT EXISTS `kc_stats` (
-- Create the vehicles exploded stat so far, I will probably add more to this later.
-- Still need to query the data from MySql for use in game.
CREATE TABLE `kc_stats` (
  `identifier` varchar(100)  NOT NULL,
  `playername` varchar(30)  NOT NULL,
  `vehicles_exploded` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
