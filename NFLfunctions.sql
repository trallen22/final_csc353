-- Tristan Allen, Will Cox, and Daniel Carter 
Use NFLdata; 

-- 
DROP PROCEDURE IF EXISTS showTeamStats;
DELIMITER // 
CREATE PROCEDURE showTeamStats(teamName VARCHAR(3))
BEGIN 
    SELECT * FROM play AS TeamStats
    WHERE pos_team=teamName OR def_team=teamName;
END; 
// 
DELIMITER ;

CALL showTeamStats('PIT'); 

-- gets table of all passing stats 
DROP VIEW IF EXISTS passingStats;
CREATE VIEW passingStats AS 
SELECT player.player_name as passer, ps1.play_id, passer_id, pos_team as offense, season, yards_gained, touchdown, two_pt_conv, pass_outcome, reception, interceptor_id 
	FROM pass as ps1
	JOIN play as play1 on ps1.play_id = play1.play_id 
	JOIN game as gm1 on play1.game_id = gm1.game_id
	JOIN player on player.player_id = ps1.passer_id;


DROP VIEW IF EXISTS rushingStats;
CREATE VIEW rushingStats AS 
SELECT player.player_name as rusher, run.play_id, rusher_id, pos_team as offense, season, yards_gained, touchdown, two_pt_conv
	FROM run
	JOIN play as play1 on run.play_id = play1.play_id 
	JOIN game as gm1 on play1.game_id = gm1.game_id
	JOIN player on player.player_id = run.rusher_id;
	
DROP VIEW IF EXISTS receivingStats;
CREATE VIEW receivingStats AS 
SELECT player.player_name as WR, pass.play_id, receiver_id, pos_team as offense, season, yards_gained, touchdown, two_pt_conv, reception
	FROM pass
	JOIN play as play1 on pass.play_id = play1.play_id 
	JOIN game as gm1 on play1.game_id = gm1.game_id
	JOIN player on player.player_id = pass.receiver_id;



-- takes in a team name and returns their total stats 
DROP PROCEDURE IF EXISTS teamPassingTotalStats;
DELIMITER //
CREATE PROCEDURE teamPassingTotalStats() 
BEGIN
	SELECT offense as team, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns, SUM(reception) as completions,
		COUNT(play_id) AS attempts, (100 * (SUM(reception) / COUNT(play_id))) AS percentage, COUNT(interceptor_id) AS interceptions
		FROM passingStats as curPassStats
		-- WHERE curPassStats.offense=teamName
		GROUP BY offense
		ORDER BY total_yards DESC
		LIMIT 5;
END;
//
DELIMITER ;

CALL teamPassingTotalStats();

DROP PROCEDURE IF EXISTS teamReceivingTotalStats;
DELIMITER //
CREATE PROCEDURE teamReceivingTotalStats() 
BEGIN
	SELECT offense as team, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns, SUM(reception) as receptions,
		COUNT(play_id) AS targets, (100 * (SUM(reception) / COUNT(play_id))) AS percentage_when_targeted
		FROM receivingStats as curRecStats
		GROUP BY offense
		ORDER BY total_yards DESC
		LIMIT 5;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS teamRushingTotalStats;
DELIMITER //
CREATE PROCEDURE teamRushingTotalStats() 
BEGIN
	SELECT offense as team, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns,
		COUNT(play_id) AS attempts
		FROM rushingStats as curRushStats
		-- WHERE curPassStats.offense=teamName
		GROUP BY offense
		ORDER BY total_yards DESC
		LIMIT 5;
END;
//
DELIMITER ;

-- takes in a player name and returns their total stats 
DROP PROCEDURE IF EXISTS playerPassingTotalStats;
DELIMITER //
CREATE PROCEDURE playerPassingTotalStats() 
BEGIN
	SELECT passer, passer_id as player, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns, SUM(reception) as completions,
		COUNT(play_id) AS attempts, (100 * (SUM(reception) / COUNT(play_id))) AS percentage, COUNT(interceptor_id) AS interceptions 
		FROM passingStats as curPassStats
		-- WHERE curPassStats.passer_id=playerName
		GROUP BY player
		ORDER BY total_yards DESC
		LIMIT 5;
END;
//
DELIMITER ;

CALL playerPassingTotalStats();

DROP PROCEDURE IF EXISTS playerReceivingTotalStats;
DELIMITER //
CREATE PROCEDURE playerReceivingTotalStats() 
BEGIN
	SELECT WR, receiver_id as player, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns, SUM(reception) as receptions,
		COUNT(play_id) AS targets, (100 * (SUM(reception) / COUNT(play_id))) AS percentage_when_targeted
		FROM receivingStats as curRecStats
		-- WHERE curPassStats.passer_id=playerName
		GROUP BY player
		ORDER BY total_yards DESC
		LIMIT 5;
END;
//
DELIMITER ;

CALL playerReceivingTotalStats();

-- takes in a player name and returns their total stats 
DROP PROCEDURE IF EXISTS playerRushingTotalStats;
DELIMITER //
CREATE PROCEDURE playerRushingTotalStats() 
BEGIN
	SELECT rusher, rusher_id as player, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns,
		COUNT(play_id) AS attempts
		FROM rushingStats as curRushStats
		-- WHERE curPassStats.passer_id=playerName
		GROUP BY player
		ORDER BY total_yards DESC
		LIMIT 5;
END;
//
DELIMITER ;

-- creates a table for all the passers in each game 
-- 		returns game_id, passer_id, season 
DROP VIEW IF EXISTS passerGames ; 
CREATE VIEW passerGames AS 
SELECT DISTINCT (play1.game_id) AS game_id, ps1.passer_id, season 
	FROM pass AS ps1 
	JOIN play AS play1 ON ps1.play_id=play1.play_id
	JOIN game AS gm1 ON play1.game_id=gm1.game_id; 
	
SELECT * FROM passerGames;

-- gets the number of games a passes was in for a given season range 
-- 		returns the number of games a passer was in
DROP FUNCTION IF EXISTS passerNumGames;
DELIMITER // 
CREATE FUNCTION passerNumGames(curPlayer INT, startSeason INT, finishSeason INT)
RETURNS INT 
DETERMINISTIC 
BEGIN 
	DECLARE numGames INT;
	
	SELECT COUNT(psgm1.game_id) INTO numGames
		FROM passergames AS psgm1
		WHERE psgm1.passer_id=curPlayer AND psgm1.season>=startSeason AND psgm1.season<=finishSeason;
	
	RETURN numGames;
END;
// 
DELIMITER ;

SELECT passerNumGames(1,2009,2013);


DROP PROCEDURE IF EXISTS randomPassingTotalStats;
DELIMITER //
CREATE PROCEDURE randomPassingTotalStats()
BEGIN
	SELECT passer, passer_id as player, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns, SUM(reception) as completions,
		COUNT(play_id) AS attempts, (100 * (SUM(reception) / COUNT(play_id))) AS percentage, COUNT(interceptor_id) AS interceptions 
		FROM passingStats as curPassStats
		GROUP BY player
		ORDER BY RAND()
		LIMIT 1;
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS randomReceivingTotalStats;
DELIMITER //
CREATE PROCEDURE randomReceivingTotalStats() 
BEGIN
	SELECT WR, receiver_id as player, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns, SUM(reception) as receptions,
		COUNT(play_id) AS targets, (100 * (SUM(reception) / COUNT(play_id))) AS percentage_when_targeted
		FROM receivingStats as curRecStats
		GROUP BY player
		ORDER BY RAND()
		LIMIT 1;
END;
//
DELIMITER ;

CALL playerReceivingTotalStats();

-- takes in a player name and returns their total stats 
DROP PROCEDURE IF EXISTS randomRushingTotalStats;
DELIMITER //
CREATE PROCEDURE randomRushingTotalStats() 
BEGIN
	SELECT rusher, rusher_id as player, SUM(yards_gained) as total_yards, SUM(touchdown) as touchdowns,
		COUNT(play_id) AS attempts
		FROM rushingStats as curRushStats
		GROUP BY player
		ORDER BY RAND()
		LIMIT 1;
END;
//
DELIMITER ;

