-- Tristan Allen, Will Cox, and Daniel Carter 
Use NFLdata; 

DROP PROCEDURE IF EXISTS showTeamStats;
DELIMITER // 
CREATE PROCEDURE showTeamStats(teamName VARCHAR(3)) 
BEGIN 
    SELECT * FROM play 
    WHERE pos_team=teamName; 
END; 
// 
DELIMITER ; 

CALL showTeamStats('PIT'); 

