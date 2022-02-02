--LIMITACIÓ ESPAI


--VOLTA 1

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;


INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;
ALTER TABLE GIMNASIO SHRINK SPACE;
ALTER TABLE REFRESCO SHRINK SPACE;
ALTER TABLE MENU SHRINK SPACE;

 ----------------------------  Update Statistics -----------------------------

DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES;
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => esquema,
    tabname => taula.table_name,
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;



/*50%:*/ SELECT id_pok, nom_pok, nivel FROM Pokemon WHERE entrenador ='ash';
/*35%:*/ SELECT p.id_pok, p.nom_pok, g.Id_Gim, g.Lider FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;
/*15%:*/ SELECT r.Nombre, r.Marca, r.Cantidad, m.bebida, m.comida FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;


CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');




INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;



SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
*/

-------------------------------INDEXS CANDIDATS:---------------------------------------
---------------------------------------------------------------------------------------
Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

------------------------------------Cluster Index--------------------------------------
-----------------------------------------id_pok----------------------------------------------

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON MOVE;  

-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 65
--query3 --> 76

SELECT SUM((f-i)*weight) FROM measure;

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
*/

------------------------------------Cluster Index--------------------------------------
--------------------------------------bebida----------------------------------------------
Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100),
PRIMARY KEY (bebida)
)ORGANIZATION INDEX PCTFREE 33;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE MENU MOVE;  

-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 972

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		56
*/

------------------------------------Cluster Index--------------------------------------
--------------------------------------Nombre----------------------------------------------
Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer,
PRIMARY KEY (nombre)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;


----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO MOVE;  

-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 1140

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	56
MENU		40
*/


----------------------------------------Btree------------------------------------------
---------------------------------------Entrenador-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  


CREATE INDEX name ON POKEMON (entrenador) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 3
--query2 --> 64
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/

----------------------------------------Btree------------------------------------------
---------------------------------------Pokemon-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE GIMNASIO SHRINK SPACE;  


CREATE INDEX name ON GIMNASIO (Pokemon) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/


----------------------------------------Btree------------------------------------------
---------------------------------------id_pok-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  


CREATE INDEX name ON POKEMON (id_pok) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 5
--query2 --> 63
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/

----------------------------------------Btree------------------------------------------
---------------------------------------ph-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;  


CREATE INDEX name ON REFRESCO (ph) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 74

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/

----------------------------------------Btree------------------------------------------
---------------------------------------bebida-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE MENU SHRINK SPACE;  


CREATE INDEX name ON MENU (bebida) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 70

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        32
*/

----------------------------------------Btree------------------------------------------
---------------------------------------Nombre-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;  


CREATE INDEX name ON REFRESCO (Nombre) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 74

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        32
*/



----------------------------------------Bitmap-----------------------------------------
---------------------------------------entrenador--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/


----------------------------------------Bitmap-----------------------------------------
---------------------------------------pokemon--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE GIMNASIO SHRINK SPACE;  

ALTER TABLE GIMNASIO MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON GIMNASIO(Pokemon) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/




----------------------------------------Bitmap-----------------------------------------
---------------------------------------ph--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;  

ALTER TABLE REFRESCO MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON REFRESCO(ph) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 276

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/

----------------------------------------Bitmap-----------------------------------------
---------------------------------------bebida--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE MENU SHRINK SPACE;  

ALTER TABLE MENU MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON MENU(bebida) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 70

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        24
*/


----------------------------------------Bitmap-----------------------------------------
---------------------------------------Nombre--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;  

ALTER TABLE REFRESCO MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON REFRESCO(nombre) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 74

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        24
*/


----------------------------------------Table with Hash-----------------------------------------
---------------------------------------entrenador--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (entrenador VARCHAR(100)) SINGLE TABLE HASHKEYS 0 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)CLUSTER name (entrenador);

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 66
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/


----------------------------------------Table with Hash-----------------------------------------
---------------------------------------pokemon--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (pokemon integer) SINGLE TABLE HASHKEYS 54 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)CLUSTER name (Pokemon);

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 73
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON     8
REFRESCO 	40
MENU		40
NAME        128
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------id_pok--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (id_pok integer) SINGLE TABLE HASHKEYS 0 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)CLUSTER name (id_pok);

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 5
--query2 --> 1162
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
REFRESCO 	40
MENU		40
NAME        8
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------ph--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (ph integer) SINGLE TABLE HASHKEYS 27 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)CLUSTER name (ph);

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 99

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
MENU		40
NAME        64
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------bebida--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (bebida VarChar(100)) SINGLE TABLE HASHKEYS 27 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)CLUSTER name (bebida);

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 1418

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
REFRESCO    40
POKEMON		8
NAME        48
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------nombre--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (nombre VarChar(100)) SINGLE TABLE HASHKEYS 27 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)CLUSTER name (nombre);

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 7
--query2 --> 68
--query3 --> 1696

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
MENU        40
POKEMON		8
NAME        56
*/



--Qualsevols dels CLUSTER INDEX id_pok o bitmap Entrenador 142 coost, noslatres agafarem bitmap Entrenador


---------------------------------------------------2a VOLTA ---------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/


-------------------------------INDEXS CANDIDATS:---------------------------------------
---------------------------------------------------------------------------------------

------------------------------------Cluster Index--------------------------------------
--------------------------------------bebida----------------------------------------------
Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100),
PRIMARY KEY (bebida)
)ORGANIZATION INDEX PCTFREE 33;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE MENU MOVE; 
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 972

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		56
NAME 		8
			
*/

------------------------------------Cluster Index--------------------------------------
--------------------------------------Nombre----------------------------------------------
Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer,
PRIMARY KEY (nombre)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;


----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO MOVE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;
-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 1140

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	56
MENU		40
*/




----------------------------------------Btree------------------------------------------
---------------------------------------Pokemon-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE GIMNASIO SHRINK SPACE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

CREATE INDEX name1 ON GIMNASIO (Pokemon) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/




----------------------------------------Btree------------------------------------------
---------------------------------------ph-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

CREATE INDEX name1 ON REFRESCO (ph) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 71

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/

----------------------------------------Btree------------------------------------------
---------------------------------------bebida-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE MENU SHRINK SPACE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

CREATE INDEX name1 ON MENU (bebida) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 70

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        32
*/

----------------------------------------Btree------------------------------------------
---------------------------------------Nombre-----------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

CREATE INDEX name1 ON REFRESCO (Nombre) PCTFREE 33;


-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',    --YO TAMBIEN HE IDO A COMER
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 71

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        32
*/




----------------------------------------Bitmap-----------------------------------------
---------------------------------------pokemon--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE GIMNASIO SHRINK SPACE;  
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;
ALTER TABLE GIMNASIO MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name1 ON GIMNASIO(Pokemon) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/




----------------------------------------Bitmap-----------------------------------------
---------------------------------------ph--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;
ALTER TABLE REFRESCO MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name1 ON REFRESCO(ph) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 2
--query2 --> 64
--query3 --> 276

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        8
*/

----------------------------------------Bitmap-----------------------------------------
---------------------------------------bebida--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE MENU SHRINK SPACE; 
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;
ALTER TABLE MENU MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON MENU(bebida) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 65
--query3 --> 70

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        24
*/


----------------------------------------Bitmap-----------------------------------------
---------------------------------------Nombre--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;


CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE REFRESCO SHRINK SPACE;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;
ALTER TABLE REFRESCO MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON REFRESCO(nombre) PCTFREE 0;




-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 65
--query3 --> 74

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON		8
GIMNASIO	64
REFRESCO 	40
MENU		40
NAME        24
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------pokemon--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (pokemon integer) SINGLE TABLE HASHKEYS 54 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)CLUSTER name (Pokemon);

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 67
--query3 --> 76

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
POKEMON     8
REFRESCO 	40
MENU		40
NAME        128
*/




----------------------------------------Table with Hash-----------------------------------------
---------------------------------------ph--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (ph integer) SINGLE TABLE HASHKEYS 27 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)CLUSTER name (ph);

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;
-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 65
--query3 --> 99

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
MENU		40
NAME        64
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------bebida--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (bebida VarChar(100)) SINGLE TABLE HASHKEYS 27 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)CLUSTER name (bebida);

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;

ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 65
--query3 --> 1418

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
REFRESCO    40
POKEMON		8
NAME        48
*/



----------------------------------------Table with Hash-----------------------------------------
---------------------------------------nombre--------------------------------------------


Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for s in (select sequence_name from user_sequences) loop
execute immediate ('drop sequence '||s.sequence_name);
end loop;
for mv in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||mv.mview_name);
end loop;
execute immediate ('purge recyclebin');
End;

SELECT  TABLE_NAME, NUM_ROWS, AVG_ROW_LEN FROM USER_TABLES

CREATE CLUSTER name (nombre VarChar(100)) SINGLE TABLE HASHKEYS 27 PCTFREE 0;

CREATE TABLE POKEMON(
id_pok integer, 
nom_pok VARCHAR(100),
tipus_pok VArchar(100),
entrenador VARCHAR(100),
nivel integer,
PRIMARY KEY (id_pok)
)ORGANIZATION INDEX PCTFREE 33;

CREATE TABLE Gimnasio (
Id_Gim VARCHAR(100),
Direccion Varchar(100),
Lider VARCHAR(100),
Pokemon integer,
Medalla VARCHAR(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE REFRESCO(
nombre VARCHAR(100),
marca VARCHAR(100),
ph integer,
cantidad Integer
)CLUSTER name (nombre);

CREATE TABLE MENU(
bebida VARchar(100),
comida Varchar(100)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----inserts-----
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (1, 'pikachu', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (2, 'raichu', 'light', 'ash', 12);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (3, 'blastoise', 'fire', 'ash', 45);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (4, 'bulbasour', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (5, 'geodude', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (6, 'meowth', 'plant', 'brock',46);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (7, 'mewtoo', 'light', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (8, 'charmander', 'fire', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (9, 'charizar', 'dark', 'ash', 1);
INSERT INTO Pokemon (id_pok, nom_pok, tipus_pok, entrenador, nivel) VALUES (10, 'psyduck', 'plant', 'ash', 1);

DECLARE
  i INTEGER;
BEGIN
DBMS_RANDOM.seed(0);

-- Insercions de Gimnasio
FOR i IN 1..1100 LOOP
  INSERT INTO Gimnasio (Id_Gim, Direccion, Lider, Pokemon, Medalla) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 
 -- Insercions de Refresco
FOR i IN 1..1100 LOOP
  INSERT INTO REFRESCO (nombre, marca, ph, cantidad) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
    LPAD(dbms_random.string('U',10),100,'*'),
	dbms_random.value(1,10),
	dbms_random.value(1,10)
    );
  END LOOP;
 
 -- Insercions de Menu
FOR i IN 1..1100 LOOP
  INSERT INTO MENU (bebida, comida) VALUES (
    LPAD(dbms_random.string('U',10),100,'*'),
	LPAD(dbms_random.string('U',10),100,'*')
    );
  END LOOP;
 END;
ALTER TABLE POKEMON SHRINK SPACE;  

ALTER TABLE POKEMON MINIMIZE RECORDS_PER_BLOCK;

CREATE BITMAP INDEX name ON POKEMON(entrenador) PCTFREE 0;

-- Actualitzar estadÌstiques
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;

----------------------COSTOS----------------
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT); DECLARE
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;

BEGIN
	
select value INTO i0 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

---- Primera query
SELECT MAX(LENGTH (id_pok||nom_pok||nivel)) INTO r FROM Pokemon WHERE entrenador ='ash';

select value INTO i1 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');

---- Segona query
SELECT MAX(LENGTH (p.id_pok||p.nom_pok||g.Id_Gim||g.Lider)) INTO r FROM Pokemon p, Gimnasio g WHERE g.Pokemon = p.id_pok;

select value INTO i2 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets'); 

---- Tercera query
SELECT MAX(LENGTH (r.Nombre||r.Marca||r.cantidad||m.bebida||m.comida)) INTO r FROM Refresco r , Menu m WHERE r.ph > 2 and m.bebida = r.Nombre;

select value INTO i3 from v$statname c, v$sesstat a
where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid
and c.name in ('consistent gets');


INSERT INTO measure (id,weight,i,f) VALUES (1,0.5,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.35,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.15,i2,i3);
END;


SELECT f-i FROM measure;

--query1 --> 1
--query2 --> 65
--query3 --> 1696

SELECT SEGMENT_NAME, BLOCKS FROM USER_SEGMENTS

/*          BLOCKS
MEASURE		8
Gimnasio    64
MENU        40
POKEMON		8
NAME        56
*/

