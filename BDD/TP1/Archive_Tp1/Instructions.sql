
-- sqlldr userid=user/mdp@venus/master control=Commune_ctl.txt
-- quelques manipulations après chargement des tuples dans communes

update Commune set dep='0'||dep where dep <10;

update Commune set dep='2A' where dep ='201';
update Commune set dep='2B' where dep ='202';

update Commune set com='00'||com where length(com)=1;
update Commune set com='0'||com where length(com)=2;

