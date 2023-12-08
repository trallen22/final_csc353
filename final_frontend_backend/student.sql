DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
	id 		INT,
	name 		VARCHAR(100),
	birthdate 	DATE,
	balance 	DECIMAL,
	PRIMARY KEY (id)
);

INSERT INTO Student VALUES ('1', 'Alice', '1981-01-14', 132.3);
INSERT INTO Student VALUES ('2', 'Bob', '1983-02-15', 42);
INSERT INTO Student VALUES ('3', 'Carlos', '1985-03-16', 32);
INSERT INTO Student VALUES ('4', 'Denise', '1987-04-17', 21.3);
INSERT INTO Student VALUES ('5', 'Elmar', '1989-05-18', 400);
INSERT INTO Student VALUES ('6', 'Fernanda', '1989-05-05', 2.3);