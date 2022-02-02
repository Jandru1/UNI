CREATE TABLE  poll_answers(
  ref INTEGER,
  pobl INTEGER NOT NULL,
  edat INTEGER NOT NULL,
  cand INTEGER NOT NULL,
  val INTEGER NOT NULL,
  resposta_1 VARCHAR2(10),
  resposta_2 VARCHAR2(10),
  resposta_3 VARCHAR2(10),
  resposta_4 VARCHAR2(10),
  resposta_5 VARCHAR2(10)
)PCTFREE 0 ENABLE ROW MOVEMENT;

----------------------------- INSERTS
DECLARE
  j INTEGER;
  maxTuples CONSTANT INTEGER := 20000;
  maxPobl CONSTANT INTEGER := 120;
  maxEdat CONSTANT INTEGER := 100;  
  maxCand CONSTANT INTEGER := 10;
  maxVal CONSTANT INTEGER := 10;  
BEGIN
DBMS_RANDOM.seed(0);
-- Insertions 
FOR j IN 1..(maxTuples) LOOP
    INSERT INTO poll_answers(ref,pobl,edat,cand,val,resposta_1,resposta_2,resposta_3,resposta_4,resposta_5)--,resposta_6,resposta_7,resposta_8,resposta_9,resposta_10) 
    VALUES (
    j, 
    dbms_random.value(1, maxPobl), 
    dbms_random.value(1,maxEdat), 
    dbms_random.value(1, maxCand),     
    dbms_random.value(1, maxVal),    
    LPAD(dbms_random.string('U',50),10,'-'),
    LPAD(dbms_random.string('U',50),10,'-'),
    LPAD(dbms_random.string('U',50),10,'-'),
    LPAD(dbms_random.string('U',50),10,'-'),
    LPAD(dbms_random.string('U',50),10,'-')
  );
END LOOP;
END;

COMMIT;

ALTER TABLE poll_answers SHRINK SPACE;

/*
--Index --
CREATE INDEX indice ON poll_answers (pobl) PCTFREE 33; 
DROP INDEX indice;

--Bitmap--
ALTER TABLE poll_answers MINIMIZE RECORDS_PER_BLOCK;
CREATE BITMAP INDEX indice1 ON poll_answers(edat) PCTFREE 0;

--MV--
CREATE MATERIALIZED VIEW VIEW1 ORGANIZATION HEAP PCTFREE 0
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND ENABLE QUERY REWRITE AS
( SELECT cand, AVG(val) FROM poll_answers GROUP BY cand);
*/

--MIO--

--Q1
/*
CREATE INDEX indice ON poll_answers (pobl) PCTFREE 33; 
DROP INDEX indice;
*/

CREATE MATERIALIZED VIEW view1 ORGANIZATION HEAP PCTFREE 0
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND ENABLE QUERY REWRITE AS
(SELECT pobl, MIN(edat), MAX(edat), COUNT(*) FROM poll_answers GROUP BY pobl);

--DROP MATERIALIZED VIEW view1;
/*
CREATE BITMAP INDEX indice1 ON poll_answers(pobl) PCTFREE 0;
CREATE BITMAP INDEX indice2 ON poll_answers(edat) PCTFREE 0;
CREATE BITMAP INDEX indice3 ON poll_answers(pobl, edat) PCTFREE 0;

DROP INDEX indice1;
DROP INDEX indice2;
DROP INDEX indice3;
*/
SELECT pobl, MIN(edat), MAX(edat), COUNT(*) FROM poll_answers GROUP BY pobl;

--Q2
/*
CREATE INDEX indice2 ON poll_answers (pobl) PCTFREE 33; 
DROP INDEX indice2;
*/
/*
CREATE MATERIALIZED VIEW view2 ORGANIZATION HEAP PCTFREE 0
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND ENABLE QUERY REWRITE AS
(SELECT pobl, edat, cand, MAX(val), MIN(val), AVG(val) FROM poll_answers GROUP BY pobl, edat, cand);

DROP MATERIALIZED VIEW view2;
*/
ALTER TABLE poll_answers MINIMIZE RECORDS_PER_BLOCK; 

CREATE BITMAP INDEX indice1 ON poll_answers(edat) PCTFREE 0;
CREATE BITMAP INDEX indice2 ON poll_answers(val, cand) PCTFREE 0;
CREATE BITMAP INDEX indice3 ON poll_answers(pobl) PCTFREE 0;

--per separata -> 60
--pobl,edat ->73
--pobl,cand ->48
--pobl,val ->48
--edat,cand ->47
--edat,val ->47
--cand,val ->46
--pobl, cand, val-> 60
--pobl, cand, edat -> 88
--pobl,edat, val ->88
--edat, val, cand -> 56
--pobl, edat, cand, val -> 81
--MV: 61


--DROP INDEX indice1;
--DROP INDEX indice2;
--DROP INDEX indice3;


SELECT pobl, edat, cand, MAX(val), MIN(val), AVG(val) FROM poll_answers GROUP BY pobl, edat, cand;

--Q3
/*
CREATE INDEX indice3 ON poll_answers (pobl) PCTFREE 33; 
DROP INDEX indice3;
*/

CREATE MATERIALIZED VIEW view3 ORGANIZATION HEAP PCTFREE 0
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND ENABLE QUERY REWRITE AS
(SELECT cand, AVG(val) FROM poll_answers GROUP BY cand);

--DROP MATERIALIZED VIEW view3;
CREATE BITMAP INDEX indice4 ON poll_answers(pobl) PCTFREE 0;
CREATE BITMAP INDEX indice5 ON poll_answers(edat) PCTFREE 0;
CREATE BITMAP INDEX indice6 ON poll_answers(pobl, edat) PCTFREE 0;

SELECT cand, AVG(val) FROM poll_answers GROUP BY cand;


SELECT TABLE_NAME, BLOCKS FROM USER_TABLES;
SELECT * FROM USER_TS_QUOTAS;
SELECT SUM(BLOCKS) FROM USER_TS_QUOTAS;


 ------------------------------------------- Update Statistics ---------------------------
DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES UNION SELECT TABLE_NAME FROM USER_OBJECT_TABLES;
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

---------------------------- To check the real costs -------------------------

--DELETE FROM measure;
CREATE TABLE measure (id INTEGER, weight FLOAT, i FLOAT, f FLOAT);

DECLARE 
i0 INTEGER;
i1 INTEGER;
i2 INTEGER;
i3 INTEGER;
r INTEGER;
BEGIN
select value INTO i0 from v$statname c, v$sesstat a where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

SELECT MAX(LENGTH(a||b||c||d)) INTO r FROM (SELECT pobl AS a, MIN(edat) AS b, MAX(edat) AS c, COUNT(*) AS d 
FROM poll_answers
GROUP BY pobl
);

select value INTO i1 from v$statname c, v$sesstat a where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

SELECT MAX(LENGTH(a||b||c||d||e||f)) INTO r FROM (SELECT pobl AS a, edat AS b, cand AS c, MAX(val) AS d, MIN(val) AS e, AVG(val) AS f 
FROM poll_answers 
GROUP BY pobl, edat, cand
);

select value INTO i2 from v$statname c, v$sesstat a where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

SELECT MAX(LENGTH(a||b)) INTO r FROM (SELECT cand AS a, AVG(val) AS b 
FROM poll_answers 
GROUP BY cand
);

select value INTO i3 from v$statname c, v$sesstat a where a.statistic# = c.statistic# and sys_context('USERENV','SID') = a.sid and c.name in ('consistent gets');

INSERT INTO measure (id,weight,i,f) VALUES (1,0.2,i0,i1);
INSERT INTO measure (id,weight,i,f) VALUES (2,0.3,i1,i2);
INSERT INTO measure (id,weight,i,f) VALUES (3,0.5,i2,i3);
END;

--SELECT * FROM MEASURE;
SELECT SUM((f-i)*weight) FROM measure;
DROP TABLE measure PURGE;

Begin
for t in (select view_name from user_views) loop
execute immediate ('drop view '||t.view_name);
end loop;
for t in (select mview_name from user_mviews) loop
execute immediate ('drop materialized view '||t.mview_name);
end loop;
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for i in (select type_name from user_types where typecode = 'COLLECTION') loop
execute immediate ('drop type '||i.type_name);
end loop;

for i in (select type_name from user_types) loop
execute immediate ('drop type '||i.type_name);
end loop;
execute immediate ('purge recyclebin');
End;
