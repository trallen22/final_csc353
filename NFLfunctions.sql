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

DROP VIEW IF EXISTS combinedStats;
CREATE VIEW combinedStats AS 

-- Passing Statistics
SELECT 
    player.player_name as player_name,
    ps1.play_id,
    passer_id as player_id,
    pos_team as offense,
    season,
    yards_gained,
    touchdown,
    two_pt_conv,
    pass_outcome as outcome,
    reception,
    interceptor_id,
    rec_fumble
FROM pass as ps1
JOIN play as play1 ON ps1.play_id = play1.play_id 
JOIN game as gm1 ON play1.game_id = gm1.game_id
JOIN player ON player.player_id = ps1.passer_id

UNION ALL

-- Rushing Statistics
SELECT player.player_name as player_name, run.play_id, rusher_id as player_id, pos_team as offense, season, 
	yards_gained, touchdown, two_pt_conv, NULL as outcome, NULL as reception, NULL as interceptor_id, rec_fumble
FROM run
JOIN play as play2 ON run.play_id = play2.play_id 
JOIN game as gm2 ON play2.game_id = gm2.game_id
JOIN player ON player.player_id = run.rusher_id

UNION ALL

-- Receiving Statistics
SELECT 
    player.player_name as player_name,
    pass.play_id,
    receiver_id as player_id,
    pos_team as offense,
    season,
    yards_gained,
    touchdown,
    two_pt_conv,
    NULL as outcome,
    reception,
    NULL as interceptor_id,
    rec_fumble
FROM pass
JOIN play as play3 ON pass.play_id = play3.play_id 
JOIN game as gm3 ON play3.game_id = gm3.game_id
JOIN player ON player.player_id = pass.receiver_id;




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

DROP VIEW IF EXISTS totalPlayerStats;
CREATE VIEW totalPlayerStats AS 

SELECT player_name, SUM(yards_gained) AS total_yards, SUM(touchdown) AS TDs, COUNT(interceptor_id) AS INTs, SUM(reception) AS receptions
	FROM (combinedStats)
	GROUP BY player_name;



-- DROP PROCEDURE IF EXISTS filterPlayerStats;
-- DELIMITER //
-- CREATE PROCEDURE filterPlayerStats(season_year INT)
-- BEGIN
	-- SELECT player_name, SUM(yards_gained) AS total_yards, 
		-- SUM(touchdown) AS TDs, COUNT(interceptor_id) AS INTs, SUM(reception) AS receptions
		-- FROM (SELECT * 
				 -- FROM combinedStats
				-- WHERE season = season_year) as filtered_stats
		-- GROUP BY player_name;
	
-- END
-- //
-- DELIMITER ;

DROP PROCEDURE IF EXISTS filterPlayerStats;
DELIMITER //
CREATE PROCEDURE filterPlayerStats(season_year INT, order_column VARCHAR(20), sort_way VARCHAR(10))
BEGIN
    SET @query = CONCAT('
        SELECT player_name, 
               SUM(yards_gained) AS total_yards, 
               SUM(touchdown) AS TDs, 
               COUNT(interceptor_id) AS INTs, 
               SUM(reception) AS receptions
        FROM (
            SELECT * 
            FROM combinedStats
            WHERE season = ', season_year, '
        ) AS filtered_stats
        GROUP BY player_name
        ORDER BY ', order_column, ' ', sort_way);

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
DELIMITER ;


DROP PROCEDURE IF EXISTS filterTeamStats;
DELIMITER //
CREATE PROCEDURE filterTeamStats(season_year INT, order_column VARCHAR(20), sort_way VARCHAR(10))
BEGIN
    SET @query = CONCAT('
		SELECT offense AS team, 
			   SUM(yards_gained) AS total_yards,
			   SUM(touchdown) AS TDs, 
			   COUNT(reception) AS completions, 
			   COUNT(interceptor_id) AS INTs
		FROM combinedStats
		WHERE season = ', season_year, '
		GROUP BY team
		ORDER BY ', order_column, ' ', sort_way);

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
DELIMITER ;

DROP PROCEDURE IF EXISTS filterTeamStatsTotal;
DELIMITER //
CREATE PROCEDURE filterTeamStatsTotal(order_column VARCHAR(20), sort_way VARCHAR(10))
BEGIN
    SET @query = CONCAT('
		SELECT offense AS team, 
			   SUM(yards_gained) AS total_yards,
			   SUM(touchdown) AS TDs, 
			   COUNT(reception) AS completions, 
			   COUNT(interceptor_id) AS INTs
		FROM combinedStats
		GROUP BY team
		ORDER BY ', order_column, ' ', sort_way);

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
DELIMITER ;


DROP PROCEDURE IF EXISTS filterPlayerStatsCareer;
DELIMITER //
CREATE PROCEDURE filterPlayerStatsCareer(order_column VARCHAR(20), sort_way VARCHAR(10))
BEGIN
    SET @query = CONCAT('
        SELECT player_name, 
               SUM(yards_gained) AS total_yards, 
               SUM(touchdown) AS TDs, 
               COUNT(interceptor_id) AS INTs, 
               SUM(reception) AS receptions
        FROM (
            SELECT * 
            FROM combinedStats) AS filtered_stats
        GROUP BY player_name
        ORDER BY ', order_column, ' ', sort_way);

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
DELIMITER ;


DROP PROCEDURE IF EXISTS searchPlayerStats;
DELIMITER //
CREATE PROCEDURE searchPlayerStats(search_player_1 VARCHAR(20), search_player_2 VARCHAR(20))
BEGIN
    SET @query = CONCAT('
        SELECT player_name,
			   SUM(yards_gained) AS total_yards, 
               SUM(touchdown) AS TDs, 
               COUNT(reception) AS receptions, 
               (COUNT(interceptor_id) + SUM(rec_fumble)) AS turnovers
        FROM combinedStats
        WHERE player_name = ''', search_player_1, ''' OR player_name = ''', search_player_2, '''
		GROUP BY player_name');

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
//
DELIMITER ;



