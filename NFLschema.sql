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
    drive       INT, 
    quarter     INT, 
    down        INT, 
    time        VARCHAR(5), -- made this VARCHAR(5) since all times are "mm:ss"
    side_of_field   VARCHAR(3), 
    yard_line   INT, 
    yard_line_100   INT, 
    yards_to_go     INT, 
    yards_net       INT, 
    goal_to_go      INT, 
    first_down      INT, 
    pos_team        VARCHAR(3), 
    def_team        VARCHAR(3), 
    yards_gained    INT, 
    touchdown       INT, 
    two_pt_conv       VARCHAR(10), 
    def_two_pt_conv   VARCHAR(10),
    safety          INT, 
    play_type       VARCHAR(20), 
    tackler_1       VARCHAR(40), -- maybe foreign key 
    tackler_2       VARCHAR(40), -- maybe foreign key 
    rec_fumble_team VARCHAR(3), 
    rec_fumble_player   VARCHAR(40), -- maybe foreign key 
    sack        INT, 
    accepted_penalty    INT, 
    penalty_team    VARCHAR(3), 
    penalty_type    VARCHAR(300), 
    penalty_player  VARCHAR(40), -- maybe foreign key 
    penalty_yards   INT, 
    pos_team_score  INT, 
    def_team_score  INT, 
    win_probability FLOAT(3), 
    PRIMARY KEY (play_id), 
    FOREIGN KEY (game_id) REFERENCES game (game_id)
    ); 

-- *Weak Entities of PLAY* 

CREATE TABLE run  
    (play_id    INT, 
    rusher_id   INT,
    FOREIGN KEY (play_id) REFERENCES play (play_id), 
    FOREIGN KEY (rusher_id) REFERENCES player (player_id)
    );


CREATE TABLE pass 
    (play_id    INT, 
    passer_id   INT, 
    pass_outcome    VARCHAR(20), 
    air_yards   INT, 
    receiver_id  INT, 
    reception   INT, 
    yards_after_catch   INT, 
    qb_hit      INT, 
    pass_location   VARCHAR(10),
    interceptor_id INT, 
    FOREIGN KEY (play_id) REFERENCES play (play_id), 
    FOREIGN KEY (passer_id) REFERENCES player (player_id), 
    FOREIGN KEY (receiver_id) REFERENCES player (player_id),
    FOREIGN KEY (interceptor_id) REFERENCES player (player_id)
    );

CREATE TABLE special_teams
    (play_id    INT,
    punt_result VARCHAR(10),
    return_result   VARCHAR(10), -- !! this includes int/fumble returns !! might need to adjust 
    returner_id    INT, 
    blocking_player_id INT,
    fg_result   VARCHAR(10), 
    fg_distance     INT, 
    extra_point_result VARCHAR(10), 
    FOREIGN KEY (play_id) REFERENCES play (play_id), 
    FOREIGN KEY (returner_id) REFERENCES player (player_id), 
    FOREIGN KEY (blocking_player_id) REFERENCES player (player_id) 
    );
