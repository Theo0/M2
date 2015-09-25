----TP2

-- ** TRIGGERS **
--QUESTION 1
create or replace trigger pop_positive
	after insert or update on Commune
	for each row
	begin
		if(:new.pop_2010 < 0)
		then
		raise_application_error(-20022, :new.nom_com||'population négative interdite');
	end if;
	end;
/	

--QUESTION 2
create or replace procedure JourEtHeuresOuvrables is
	begin
		if (to_char(sysdate,'DY')='SAT') or (to_char(sysdate,'DY')='SUN')
		then
		raise_application_error(-20010, 'Modification interdite le '||to_char(sysdate,'DAY') ) ;
		end if ;
	end;
/	
--
create or replace trigger Ouvrable
before delete or insert or update on Region
begin
	JourEtHeuresOuvrables();
end ;
/

--QUESTION 3
CREATE TABLE Historique
(
dateOperation date,
nomUsager varchar(50),
typeOperation varchar(50)
);
--
create or replace trigger monitoring
	before delete or insert or update on Region
	begin
		INSERT INTO Historique (dateOperation, nomUsager)
		SELECT sysdate, user from dual;
	end;
/		

--QUESTION 4
create or replace trigger cascade
	after delete or update of reg on Region
	FOR EACH ROW
	begin
		if updating then
			UPDATE Departement SET reg=:new.reg WHERE reg = :old.reg;
		elsif deleting then
			DELETE FROM Departement WHERE reg = :old.reg;
		end if;	
end;
/	

-- **CURSEURS**
--QUESTION 1
DECLARE
nombre_hab VARCHAR(50);
begin
SELECT SUM(pop_2010) INTO nombre_hab FROM Commune WHERE dep='34';
dbms_output.put_line('Nombre dhabitants en 2010 dans lherault : ' || nombre_hab);
end;
/

--QUESTION 2
DECLARE
cursor population_2010 is
SELECT SUM(pop_2010), dep FROM Commune GROUP BY dep;
nombre_habitants Commune.pop_2010%type;
depart Commune.dep%type;
begin
open population_2010;
loop
fetch population_2010 into nombre_habitants, depart;
exit when population_2010%notfound;
dbms_output.put_line('Departement : ' ||depart|| ', Population : '||nombre_habitants);
end loop;
close population_2010;
end;
/

-- ** FONCTIONS/PROCEDURES
--QUESTION 1
create or replace function calcul_pop (annee in varchar, depart in varchar) return float
	is
	pop float;
	an varchar(15);
	begin
	an := 'pop_'||annee;
	dbms_output.put_line(an);
	SELECT SUM(an) INTO pop FROM Commune WHERE dep=depart; -- NE FONCTIONE PAS, FAIRE UNE REQUETE SIMPLE (sans SUM()) et utiliser un curseur pour calculer manuellement la somme
	return (pop);
	end;
	/


begin
	dbms_output.put_line(calcul_pop('2005','34'));
end;
/	

--QUESTION 2
create or replace function calcul_prcent return varchar
	is
	ret varchar(500);
	prcent float;
	nb_co float;
	nb_total float;
	begin
	SELECT COUNT(username) INTO nb_total from dba_users where username <> '%SYS%';
	SELECT COUNT(username) INTO nb_co FROM v$session where username is not null;
	prcent := (nb_co / nb_total)*100;
	ret := 'Il y a '||nb_co||' utilisateurs connectés sur '||nb_total||'utilisateurs total, soit '||prcent||'%';
	return (ret);
	end;
	/

	begin
	dbms_output.put_line(calcul_prcent());
end;
/	