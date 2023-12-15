-- Tristan Allen, Will Cox, and Daniel Carter 
DROP SCHEMA IF EXISTS NFLdata; 
CREATE SCHEMA NFLdata; 
USE NFLdata; 

CREATE TABLE game
    (game_id    INT NOT NULL,
    date        DATE NOT NULL,
    home_team    VARCHAR(3) NOT NULL, 
    away_team    VARCHAR(3) NOT NULL, 
    season      YEAR NOT NULL, 
    PRIMARY KEY (game_id)
    );

CREATE TABLE player  
    (player_id  INT AUTO_INCREMENT,
    player_name  VARCHAR(40),
    PRIMARY KEY (player_id)
    );

CREATE TABLE play
    (play_id     INT AUTO_INCREMENT, 
    game_id     INT NOT NULL,
    yards_net       INT, 
    pos_team        VARCHAR(3), 
    def_team        VARCHAR(3), 
    yards_gained    INT, 
    touchdown       INT, 
    two_pt_conv       VARCHAR(10), 
    play_type       VARCHAR(20), 
    rec_fumble_team VARCHAR(3),
    rec_fumble INT,
    rec_fumble_player   VARCHAR(40), -- maybe foreign key 
    PRIMARY KEY (play_id), 
    FOREIGN KEY (game_id) REFERENCES game (game_id) ON DELETE CASCADE
    ); 

-- *Weak Entities of PLAY* 

CREATE TABLE run  
    (play_id    INT, 
    rusher_id   INT,
    FOREIGN KEY (play_id) REFERENCES play (play_id) ON DELETE CASCADE, 
    FOREIGN KEY (rusher_id) REFERENCES player (player_id) ON DELETE CASCADE
    );


CREATE TABLE pass 
    (play_id    INT, 
    passer_id   INT, 
    pass_outcome    INT, -- complete/incomplete 
    receiver_id  INT, 
    reception   INT, 
    interceptor_id INT, 
    FOREIGN KEY (play_id) REFERENCES play (play_id) ON DELETE CASCADE, 
    FOREIGN KEY (passer_id) REFERENCES player (player_id) ON DELETE SET NULL, 
    FOREIGN KEY (receiver_id) REFERENCES player (player_id) ON DELETE SET NULL,
    FOREIGN KEY (interceptor_id) REFERENCES player (player_id) ON DELETE SET NULL
    );
