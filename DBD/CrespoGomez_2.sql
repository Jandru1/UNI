Un pokemon capturat que resideix a una pokeball amb identificador X ha de pertanyer a 
l’entrenador propietari de la pokeball amb identificador X.

CREATE TABLE Pokemon (
Id_Pokemon Integer,
Naturaleza VARCHAR(1),
PRIMARY KEY (Id_Pokemon));

CREATE TABLE Entrenador (
Nom_Entr VARCHAR(1),
Edad Integer,
Sexo VARCHAR(1),
Nom_Gimnasio VARCHAR(1) UNIQUE,
Dirección_Gimnasio VARCHAR(1),
Tipo_Gimnasio VARCHAR(1), 
PRIMARY KEY (Nom_Entr));
 
CREATE TABLE Capturado (
Nom_Pokemon VARCHAR(1),
Id_Pokemon Integer,
Nom_Entr varchar(1) NOT NULL,
FOREIGN KEY (Id_Pokemon) REFERENCES Pokemon(Id_Pokemon),
FOREIGN KEY (Nom_Entr) REFERENCES Entrenador(Nom_Entr),
PRIMARY KEY (Id_Pokemon));

CREATE TABLE Pokeball (
Id_Pokeball Integer,
Color VARCHAR(1),
Tipo VARCHAR(1),
Nom_Pokemon VARCHAR(1) UNIQUE,
Nom_Entr varchar(1) NOT NULL,
FOREIGN KEY (Nom_Pokemon) REFERENCES Capturado(Nom_Pokemon),
FOREIGN KEY (Nom_Entr) REFERENCES Entrenador(Nom_Entr),
PRIMARY KEY (Id_Pokeball));


CREATE ASSERTION A2 
(NOT EXISTS (SELECT c.ID_POKEMON
			FROM ENTRENADOR e, CAPTURADO c, POKEBALL pb
			WHERE e.NOM_ENTR = c.NOM_ENTR AND pb.ID_POKEMON = c.ID_POKEMON 
			AND e.NOM_ENTR <> pb.NOM_ENTR)
			GROUP BY c.ID_POKEMON);


CREATE MATERIALIZED VIEW MVA2 
	BUILD IMMEDIATE Refresh Complete ON DEMAND AS( 
	SELECT e.NOM_ENTR AS Entrenador1, pb.NOM_ENTR AS Entrenador2
			FROM ENTRENADOR e, CAPTURADO c, POKEBALL pb
			WHERE e.NOM_ENTR = c.NOM_ENTR AND 
				pb.ID_POKEMON = c.ID_POKEMON
			GROUP BY e.NOM_ENTR, pb.NOM_ENTR);
ALTER TABLE MVA2 ADD CONSTRAINT mva2_check CHECK (Entrenador1 = Entrenador2);

--INSERTS TOT BÉ

INSERT INTO ENTRENADOR
VALUES ('BROCK', '17', 'M', 'Pewter','Ciudad Plateada', 'Roca');

INSERT INTO POKEMON
VALUES ('095', 'Roca');

INSERT INTO CAPTURADO
VALUES ('Onix', '095', 'BROCK');

INSERT INTO POKEBALL
VALUES ('124', 'violeta-rosa', 'masterball', '095', 'BROCK');

BEGIN DBMS_MVIEW.REFRESH('MVA2'); END;

--INSERTS SALTA VIEW MVA2
INSERT INTO ENTRENADOR
VALUES ('ASH', '15', 'M', NULL, NULL, NULL);

INSERT INTO ENTRENADOR
VALUES ('BROCK', '17', 'M', 'Pewter','Ciudad Plateada', 'Roca');

INSERT INTO POKEMON
VALUES ('096', 'Roca');

INSERT INTO CAPTURADO
VALUES ('Geodude', '096', 'BROCK');

INSERT INTO POKEBALL
VALUES ('123', 'violeta-rosa', 'masterball', '096', 'ASH');

BEGIN DBMS_MVIEW.REFRESH('MVA2'); END;