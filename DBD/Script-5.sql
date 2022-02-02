create table AlumnesUPC(
 id  number(8,0),
 especialitat char(20),
 edat  number(17,0),
 nota_mitjana number(2,0),
 nom char(250)
) PCTFREE 0;


DECLARE id int;
pn int;
i int;
nz INT;
especialitat CHAR(20);
edat INT;
nota_mitjana INT;

begin
pn:= 1;
for i in 1..1000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 1002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) MOD 10 + 1; 
	edat := (id - 1) mod 80 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'IT'; END if;
	if (nz = 3) then especialitat := 'SI'; END if;
	if (nz = 4) then especialitat := 'HW'; END if;
	if (nz = 5) then especialitat := 'C'; END if;
	insert into alumnesUPC values (id, especialitat, edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;
end;

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

SELECT especialitat from alumnesupc where edat = 25;

SELECT TABLE_NAME, BLOCKS, NUM_ROWS FROM USER_TABLES;

---------BTree candidat------------

CREATE INDEX name_alumnes ON alumnesupc (edat) PCTFREE 33;

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

SELECT PCT_FREE, BLEVEL, LEAF_BLOCKS, DISTINCT_KEYS FROM USER_INDEXES;

 SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = 1 + ((1/80)*1000-1)/(1000/3) + (1/80)*1000 = 13.53
 * Cost oracle = 14
 * Oracle el fa servir*/

DROP INDEX name_alumnes;
DROP TABLE alumnesupc;

CREATE CLUSTER name_alumnes (edat  number(17,0) ) SINGLE TABLE HASHKEYS 54 PCTFREE 0;

create table AlumnesUPC(
 id  number(8,0),
 especialitat char(20),
 edat  number(17,0),
 nota_mitjana char(100),
 nom char(250)
) CLUSTER name_alumnes(edat);


DECLARE id int;
pn int;
i int;
nz INT;
especialitat CHAR(20);
edat INT;
nota_mitjana INT;

begin
pn:= 1;
for i in 1..1000 loop
	if (pn = 1) then 
		id := i;
	else
		id := 1002 - i;
	END if;
	nz := (id - 1) Mod 5 + 1;
	nota_mitjana := (id - 1) MOD 10 + 1; 
	edat := (id - 1) mod 80 + 1;
	if (nz = 1) then especialitat := 'SW'; END if;
	if (nz = 2) then especialitat := 'IT'; END if;
	if (nz = 3) then especialitat := 'SI'; END if;
	if (nz = 4) then especialitat := 'HW'; END if;
	if (nz = 5) then especialitat := 'C'; END if;
	insert into alumnesUPC values (id, especialitat, edat, nota_mitjana, 'n' || id);
	pn:=pn * (-1);
end loop;
end;


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

SELECT * FROM USER_TS_QUOTAS;

/*
 * Cost teoric = v(1+k) = 2*(1+13) = 28
 * Cost oracle = 0
 * Oracle el fa servir*/