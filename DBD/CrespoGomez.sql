El lider d’un gimnas de tipo X ha de tenir algún pokemon capturat de naturaleza X. 

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
 

CREATE ASSERTION A1  
(NOT EXISTS (SELECT e.nom_entr
			FROM ENTRENADOR e, CAPTURADO c, Pokemon pk
			WHERE e.NOM_ENTR = c.NOM_ENTR AND c.ID_POKEMON = pk.ID_POKEMON AND 
				pk.NATURALEZA <> e.TIPO_GIMNASIO)
			GROUP BY e.NOM_ENTR);

CREATE MATERIALIZED VIEW MVA1
	BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND AS( 
	SELECT 'x' AS x 
			FROM ENTRENADOR e, CAPTURADO c, POKEMON pk
			WHERE e.NOM_ENTR = c.NOM_ENTR AND c.ID_POKEMON = pk.ID_POKEMON AND 
				pk.NATURALEZA <> e.TIPO_GIMNASIO
			GROUP BY e.NOM_ENTR);
ALTER TABLE MVA1 ADD CONSTRAINT MVA1_check CHECK (x IS NULL);

--INSERT OKEY TOT BÉ
INSERT INTO ENTRENADOR
VALUES ('BROCK', '17', 'M', 'Pewter','Ciudad Plateada', 'Roca');

INSERT INTO POKEMON
VALUES ('095', 'Volador');

INSERT INTO CAPTURADO
VALUES ('Onix', '095', 'BROCK');

BEGIN DBMS_MVIEW.REFRESH('MVA1'); END;

--INSERTS SALTA VIEW MVA1

INSERT INTO ENTRENADOR
VALUES ('BROCK', '17', 'M', 'Pewter','Ciudad Plateada', 'Roca');

INSERT INTO POKEMON
VALUES ('095', 'Volador');

INSERT INTO CAPTURADO
VALUES ('Onix', '095', 'BROCK');

BEGIN DBMS_MVIEW.REFRESH('MVA1'); END;





