-- Taules 

create table AlumneUPC(
 id number(8,0),
 especialitat char(20),
 edat number(17,0),
 nota_mitjana number(17,0),
 nom char(100)
) PCTFREE 0;

create table Projecte(
 id number(8,0),
 alumne number(8,0),
 tema char(20),
 nota number(17,0)
) PCTFREE 0;

DECLARE id int;
pn int;
i int;
proj int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..5000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 5002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) mod 555 + 1;
	edat := (id - 1) mod 62 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'Compu'; END if;
	if (nz = 3) then especialitat := 'HW'; END if;
	if (nz = 4) then especialitat := 'SI'; END if;
	if (nz = 5) then especialitat := 'IT'; END if;
	insert into AlumneUPC values (id, ESPECIALITAT , edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;

pn:= 1;
for i in 1..10000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 10002 - i;
	END if;
	nota_mitjana := (id - 1) mod 10 + 1;
    proj := (id - 1) mod 2500 + 1;
	nz := (id - 1) Mod 5 + 1;
	if (nz = 1) then especialitat := 'Grafics'; END if;
	if (nz = 2) then especialitat := 'BD'; END if;
	if (nz = 3) then especialitat := 'Algoritmia'; END if;
	if (nz = 4) then especialitat := 'Xarxes'; END if;
	if (nz = 5) then especialitat := 'Empresa'; END IF;
	insert into Projecte values (id, proj, especialitat, nota_mitjana);
    pn:=pn * (-1);
end loop;
end;

-- ---------------------AlumneUPC / Projectes ------------------------

-- Actualitzar estadÃŒstiques

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


SELECT a.id, a.edat, a.especialitat, p.id, p.tema, p.nota
FROM AlumneUPC a, Projecte p
WHERE a.id = p.alumne;

SELECT TABLE_NAME, BLOCKS, NUM_ROWS FROM USER_TABLES;


-- ---------------------AlumneUPC Btree / Projectes ------------------------

CREATE UNIQUE INDEX name ON AlumneUPC (id) PCTFREE 33;

-- Actualitzar estadÃŒstiques
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

SELECT PCT_FREE, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS FROM USER_INDEXES;

SELECT * FROM USER_TS_QUOTAS;


/*
 * Cost teoric = 50 + 10000*(1 + (10000-1)/(5000/4) + 10000) = 100090042
 * Cost Oracle = 140
 * Oracle no el fa servir
*/


-- ---------------------AlumneUPC Hash / Projectes ------------------------

DROP INDEX name;
DROP TABLE AlumneUPC;

CREATE CLUSTER name (id NUMBER(8,0)) SINGLE TABLE HASHKEYS 110 PCTFREE 0;

create table AlumneUPC(
 id  number(8,0),
 especialitat char(20),
 edat  number(17,0),
 nota_mitjana number(17, 0),
 nom char(100)
) CLUSTER name(id);

DECLARE id int;
pn int;
i int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..5000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 5002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) mod 500 + 1;
	edat := (id - 1) mod 62 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'Compu'; END if;
	if (nz = 3) then especialitat := 'HW'; END if;
	if (nz = 4) then especialitat := 'SI'; END if;
	if (nz = 5) then especialitat := 'IT'; END if;
	insert into AlumneUPC values (id, ESPECIALITAT , edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;
end;

-- Actualitzar estadÃŒstiques
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


SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 50 + 1 = 51
 * Cost Oracle = 51
 * Oracle el fa servir
*/

-- ---------------------AlumneUPC / Projectes Btree ------------------------

DROP TABLE AlumneUPC;
DROP CLUSTER name;

create table AlumneUPC(
 id  number(8,0),
 especialitat char(20),
 edat  number(17,0),
 nota_mitjana number(17, 0),
 nom char(100)
) PCTFREE 0;

DECLARE id int;
pn int;
i int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..5000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 5002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) mod 500 + 1;
	edat := (id - 1) mod 62 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'Compu'; END if;
	if (nz = 3) then especialitat := 'HW'; END if;
	if (nz = 4) then especialitat := 'SI'; END if;
	if (nz = 5) then especialitat := 'IT'; END if;
	insert into AlumneUPC values (id, ESPECIALITAT , edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;
end;

CREATE UNIQUE INDEX name ON PROJECTE (id) PCTFREE 33;

-- Actualitzar estadÃŒstiques
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

SELECT PCT_FREE, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS FROM USER_INDEXES;

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 88 + 5000*(1 + (5000-1)/10000/27) + 5000) = 25072574.5
 * Cost Oracle = 140
 * Oracle no el fa servir
*/



-- ---------------------AlumneUPC / Projectes Hash ------------------------

DROP INDEX name;
DROP TABLE PROJECTE;

CREATE CLUSTER name (id NUMBER(8,0)) SINGLE TABLE HASHKEYS 110 PCTFREE 0;

create table Projecte(
 id number(8,0),
 alumne number(8,0),
 tema char(20),
 nota number(17,0)
 ) CLUSTER name(id);

DECLARE id int;
pn int;
i int;
proj int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..10000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 10002 - i;
	END if;
	nota_mitjana := (id - 1) mod 10 + 1;
    proj := (id - 1) mod 2500 + 1;
	nz := (id - 1) Mod 5 + 1;
	if (nz = 1) then especialitat := 'Grafics'; END if;
	if (nz = 2) then especialitat := 'BD'; END if;
	if (nz = 3) then especialitat := 'Algoritmia'; END if;
	if (nz = 4) then especialitat := 'Xarxes'; END if;
	if (nz = 5) then especialitat := 'Empresa'; END IF;
	insert into Projecte values (id, proj, especialitat, nota_mitjana);
    pn:=pn * (-1);
end loop;
end;

-- Actualitzar estadÃŒstiques
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

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 88 + 5000*10000 =50000088
 * Cost Oracle = 213
 * Oracle no el fa servir
*/


-- ---------------------AlumneUPC Btree / Projectes Btree ------------------------

DROP TABLE ALUMNEUPC;
DROP TABLE PROJECTE;
DROP CLUSTER name;

create table AlumneUPC(
 id number(8,0),
 especialitat char(20),
 edat number(17,0),
 nota_mitjana number(17,0),
 nom char(100)
) PCTFREE 0;

create table Projecte(
 id number(8,0),
 alumne number(8,0),
 tema char(20),
 nota number(17,0)
) PCTFREE 0;

DECLARE id int;
pn int;
i int;
proj int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..5000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 5002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) mod 555 + 1;
	edat := (id - 1) mod 62 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'Compu'; END if;
	if (nz = 3) then especialitat := 'HW'; END if;
	if (nz = 4) then especialitat := 'SI'; END if;
	if (nz = 5) then especialitat := 'IT'; END if;
	insert into AlumneUPC values (id, ESPECIALITAT , edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;

pn:= 1;
for i in 1..10000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 10002 - i;
	END if;
	nota_mitjana := (id - 1) mod 10 + 1;
    proj := (id - 1) mod 2500 + 1;
	nz := (id - 1) Mod 5 + 1;
	if (nz = 1) then especialitat := 'Grafics'; END if;
	if (nz = 2) then especialitat := 'BD'; END if;
	if (nz = 3) then especialitat := 'Algoritmia'; END if;
	if (nz = 4) then especialitat := 'Xarxes'; END if;
	if (nz = 5) then especialitat := 'Empresa'; END IF;
	insert into Projecte values (id, proj, especialitat, nota_mitjana);
    pn:=pn * (-1);
end loop;
end;

CREATE UNIQUE INDEX projIndex ON PROJECTE (id) PCTFREE 33;
CREATE UNIQUE INDEX alumneIndex ON ALUMNEUPC (id) PCTFREE 33;

-- Actualitzar estadÃŒstiques
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

SELECT PCT_FREE, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS FROM USER_INDEXES;

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 100090042 
 * Cost Oracle = 140
 * Oracle no el fa servir
*/

-- ---------------------AlumneUPC Btree / Projectes Hash ------------------------

DROP INDEX projIndex;
DROP TABLE PROJECTE;

CREATE CLUSTER projHash (id NUMBER(8,0)) SINGLE TABLE HASHKEYS 110 PCTFREE 0;

create table Projecte(
 id number(8,0),
 alumne number(8,0),
 tema char(20),
 nota number(17,0)
 ) CLUSTER projHash(id);

DECLARE id int;
pn int;
i int;
proj int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..10000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 10002 - i;
	END if;
	nota_mitjana := (id - 1) mod 10 + 1;
    proj := (id - 1) mod 2500 + 1;
	nz := (id - 1) Mod 5 + 1;
	if (nz = 1) then especialitat := 'Grafics'; END if;
	if (nz = 2) then especialitat := 'BD'; END if;
	if (nz = 3) then especialitat := 'Algoritmia'; END if;
	if (nz = 4) then especialitat := 'Xarxes'; END if;
	if (nz = 5) then especialitat := 'Empresa'; END IF;
	insert into Projecte values (id, proj, especialitat, nota_mitjana);
    pn:=pn * (-1);
end loop;
end;

-- Actualitzar estadÃŒstiques
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

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 50000088
 * Cost Oracle = 213
 * Oracle no el fa servir
*/


-- ---------------------AlumneUPC Hash / Projectes Hash ------------------------

DROP INDEX alumneIndex;
DROP TABLE AlumneUPC;

CREATE CLUSTER alumneHash (id NUMBER(8,0)) SINGLE TABLE HASHKEYS 110 PCTFREE 0;

create table AlumneUPC(
 id  number(8,0),
 especialitat char(20),
 edat  number(17,0),
 nota_mitjana number(17, 0),
 nom char(100)
) CLUSTER alumneHash(id);

DECLARE id int;
pn int;
i int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..5000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 5002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) mod 500 + 1;
	edat := (id - 1) mod 62 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'Compu'; END if;
	if (nz = 3) then especialitat := 'HW'; END if;
	if (nz = 4) then especialitat := 'SI'; END if;
	if (nz = 5) then especialitat := 'IT'; END if;
	insert into AlumneUPC values (id, ESPECIALITAT , edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;
end;

-- Actualitzar estadÃŒstiques
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

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 50000088
 * Cost Oracle = 124
 * Oracle el fa servir
*/


-- ---------------------AlumneUPC Hash / Projectes Btree ------------------------

DROP TABLE PROJECTE;
DROP CLUSTER projHash;


create table Projecte(
 id number(8,0),
 alumne number(8,0),
 tema char(20),
 nota number(17,0)
 ) PCTFREE 0;

DECLARE id int;
pn int;
i int;
proj int;
nz INT;
ESPECIALITAT CHAR(20);
nota_mitjana INT;
edat int;

begin
pn:= 1;
for i in 1..10000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 10002 - i;
	END if;
	nota_mitjana := (id - 1) mod 10 + 1;
    proj := (id - 1) mod 2500 + 1;
	nz := (id - 1) Mod 5 + 1;
	if (nz = 1) then especialitat := 'Grafics'; END if;
	if (nz = 2) then especialitat := 'BD'; END if;
	if (nz = 3) then especialitat := 'Algoritmia'; END if;
	if (nz = 4) then especialitat := 'Xarxes'; END if;
	if (nz = 5) then especialitat := 'Empresa'; END IF;
	insert into Projecte values (id, proj, especialitat, nota_mitjana);
    pn:=pn * (-1);
end loop;
end;

CREATE UNIQUE INDEX projIndex ON PROJECTE (id) PCTFREE 33;

-- Actualitzar estadÃŒstiques
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

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 50 + 1 = 51
 * Cost Oracle = 51
 * Oracle el fa servir 
*/