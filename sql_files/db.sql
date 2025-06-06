
-- CREATE TABLE `playtime` (
-- Modifed to use kc_playtime table, and added playername to this.
CREATE TABLE `kc_playtime` (
  `identifier` varchar(100)  NOT NULL,
  `playername` varchar(30)  NOT NULL,
  `time` int(11) NOT NULL DEFAULT 0,
  `login` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
