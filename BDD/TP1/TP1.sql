----- PARTIE 2 
-- 2.1 CREATION
CREATE TABLE Region
(
	reg varchar(4) NOT NULL PRIMARY KEY,
	chef_lieu varchar(46),
	nom_reg varchar(30)
);

CREATE TABLE Departement
(
	reg varchar(4),
	dep varchar(4) NOT NULL PRIMARY KEY,
	chef_lieu varchar(46),
	nom_dep varchar(30)
);

CREATE TABLE Commune
(
reg varchar(4),dep varchar(4),com varchar(4),article varchar(4),com_nom varchar(46),longitude
float,latitude float,pop_1975 float,pop_1976 float, pop_1977 float,pop_1978 float,pop_1979 float,pop_1980
float,pop_1981 float,pop_1982 float,pop_1983 float,pop_1984 float,pop_1985 float,pop_1986 float,pop_1987
float,pop_1988 float,pop_1989 float,pop_1990 float,pop_1991 float, pop_1992 float,pop_1993 float,pop_1994
float,pop_1995 float,pop_1996 float,pop_1997 float,pop_1998 float,pop_1999 float,pop_2000 float,pop_2001
float,pop_2002 float,pop_2003 float,pop_2004 float,pop_2005 float,pop_2006 float,pop_2007 float,pop_2008
float,pop_2009 float,pop_2010 float
);

ALTER TABLE Commune ADD CONSTRAINT fk_com_dep FOREIGN KEY (dep) REFERENCES Departement (dep);
ALTER TABLE Commune ADD CONSTRAINT fk_com_reg FOREIGN KEY (reg) REFERENCES Region (reg);
ALTER TABLE Departement ADD CONSTRAINT fk_reg FOREIGN KEY (reg) REFERENCES Region(reg); 
;


-- 2.2 SQL Loader
--VOIR FICHIERS DANS Archive_TP1

--PARTIE 3
ALTER TABLE Commune ADD (code_insee varchar(6));

UPDATE Commune c1
SET code_insee = (SELECT CONCAT(dep, com) FROM Commune c2 WHERE c1.com = c2.com AND c1.dep = c2.dep);

ALTER TABLE Commune ADD CONSTRAINT pk_com PRIMARY KEY (code_insee);

ALTER TABLE Commune DROP CONSTRAINT fk_com_reg;
ALTER TABLE Commune DROP COLUMN reg;

ALTER TABLE Commune RENAME COLUMN com_nom TO nom_com;

--PARTIE 4
--1
SELECT nom_com, pop_2010 FROM Commune WHERE dep=(SELECT dep FROM Departement WHERE nom_dep='HERAULT');
--2
SELECT nom_com, pop_1975, pop_2010 FROM Commune WHERE pop_2010 > pop_1975;
--3
SELECT nom_com, pop_1975, pop_2010 FROM Commune WHERE pop_1975 > pop_2010 ORDER BY nom_com ASC;
--4
CREATE VIEW vue_pop_baisse (nom_com, nom_dep, nom_reg, baisse_pop) AS (SELECT c.nom_com, d.nom_dep, r.nom_reg, ((c.pop_2000)-(c.pop_2010)) FROM Commune c, Departement d, Region r WHERE c.dep = d.dep AND d.reg = r.reg AND (c.pop_2010 < c.pop_2000));
--5
SELECT DISTINCT d1.nom_dep FROM Departement d1 MINUS SELECT v.nom_dep FROM vue_pop_baisse v;
--6
SELECT nom_com FROM Commune c, Departement d, Region r WHERE (r.nom_reg='LANGUEDOC-ROUSSILLON' AND r.reg = d.reg AND d.dep = c.dep AND ((c.pop_1975)-(c.pop_2010) = (SELECT MAX((c.pop_1975)-(c.pop_2010)) FROM Commune c, Departement d, Region r WHERE c.pop_1975 > c.pop_2010 AND r.nom_reg='LANGUEDOC-ROUSSILLON' AND r.reg = d.reg AND d.dep = c.dep)) ) ;
--7
SELECT nom_com FROM Commune WHERE pop_2010 = (SELECT MIN(pop_2010) FROM Commune);
--8
SELECT DISTINCT c.nom_com FROM Departement d, Region r, Commune c WHERE d.chef_lieu = r.chef_lieu AND r.reg = d.reg AND d.chef_lieu = c.code_insee;
--9
SELECT DISTINCT c.nom_com FROM Departement d, Region r, Commune c WHERE d.chef_lieu != r.chef_lieu AND r.reg = d.reg AND d.chef_lieu = c.code_insee;
--10
SELECT DISTINCT c.nom_com FROM Departement d, Region r, Commune c WHERE d.chef_lieu != r.chef_lieu AND r.reg = d.reg AND r.chef_lieu = c.code_insee;
--11
SELECT DISTINCT c.nom_com, d.dep FROM Departement d, Commune c WHERE c.dep = d.dep AND d.chef_lieu = (SELECT d1.chef_lieu FROM Departement d1, Commune c1 WHERE c1.dep = d1.dep AND c1.code_insee='34101');
--12
SELECT r.nom_reg, COUNT(d.dep) FROM Region r, Departement d WHERE r.reg = d.reg GROUP BY r.nom_reg;