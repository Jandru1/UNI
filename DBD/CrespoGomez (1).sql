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
 

