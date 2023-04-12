/* Stworzenie tabeli AllYears */


/* Ujednolicenie nazw krajów pomiędzy tabelami */

update year2017 set country = 'Taiwan' where country = 'Taiwan Province of China';
update year2017 set country = 'Hong Kong' where country = 'Hong Kong S.A.R., China';
update year2018 set "Country or region" = 'Trinidad and Tobago' where "Country or region" = 'Trinidad & Tobago';
update year2018 set "Country or region" = 'North Cyprus' where "Country or region" = 'Northern Cyprus';
update year2019 set "Country or region" = 'Trinidad and Tobago' where "Country or region" = 'Trinidad & Tobago';
update year2019 set "Country or region" = 'North Cyprus' where "Country or region" = 'Northern Cyprus';
update year2019 set "Country or region" = 'Macedonia' where "Country or region" = 'North Macedonia';


/* Przygotowanie tabeli year2017
 * Dodanie kolumny "Region"
 * Uzupełnienie kolumny region na podstawie danych z 2016*/

update year2017
	set "Region" = 
		(
		select region
		from year2016
		where year2017.country = year2016.country 
		);

		
/* Przygotowanie tabeli year2018
 * Dodanie kolumny "Region"
 * Uzupełnienie kolumny region na podstawie danych z 2016
 * Zmiana typu danych na float dla kolumny "Perceptions of corruption"*/

alter table year2018
	add column "Region" varchar(50)
	
update year2018
	set "Region" = 
		(
		select region
		from year2016
		where year2018."Country or region" = year2016.country 
		);

update year2018
set "Perceptions of corruption" = 0
where "Perceptions of corruption" is null

alter table year2018
	alter column "Perceptions of corruption" type float using (trim("Perceptions of corruption")::float)
		

/* Przygotowanie tabeli year2019
 * Dodanie kolumny "Region"
 * Uzupełnienie kolumny region na podstawie danych z 2016*/

alter table year2019
	add column "Region" varchar(50)
	
update year2019
	set "Region" = 
		(
		select region
		from year2016
		where year2019."Country or region" = year2016.country 
		);
		
/* Stworzenie nowej tabeli AllYears 
 * Dodanie kolumny Year - odpowiednio do danych z każdej tabeli*/
create table AllYears as 
select 
	'2015' as "Year"
	,"Happiness Rank"
	,"country"
	,"region"
	,"Happiness Score"
	,"Economy (GDP per Capita)"
	,"Health (Life Expectancy)"
	,"freedom"
	,"generosity"
	,"Trust (Government Corruption)"
	,"Family"
from year2015
union
select 
	'2016' as "Year"
	,"Happiness Rank"
	,"country"
	,"region"
	,"Happiness Score"
	,"Economy (GDP per Capita)"
	,"Health (Life Expectancy)"
	,"freedom"
	,"generosity"
	,"Trust (Government Corruption)"
	,"Family"
from year2016
union
select 
	'2017' as "Year"
	,"Happiness.Rank"
	,"country"
	,"Region"
	,"Happiness.Score"
	,"Economy..GDP.per.Capita."
	,"Health..Life.Expectancy."
	,"freedom"
	,"generosity"
	,"Trust..Government.Corruption."
	,"Family"
from year2017
union
select
	'2018' as "Year"
	,"Overall rank"
	,"Country or region"
	,"Region"
	,"score"
	,"GDP per capita"
	,"Healthy life expectancy"
	,"Freedom to make life choices"
	,"generosity"
	,"Perceptions of corruption"
	,"Social support"
from year2018 
union
select 
	'2019' as "Year"
	,"Overall rank"
	,"Country or region"
	,"Region"
	,"score"
	,"GDP per capita"
	,"Healthy life expectancy"
	,"Freedom to make life choices"
	,"generosity"
	,"Perceptions of corruption"
	,"Social support"
from year2019 
order by 1, 2


/*Zmiana nazw kolumn na te ustalone - wersja skrótowa*/

alter table allyears rename column "Happiness Rank" to "HappiRank";
alter table allyears rename column "country" to "Country";
alter table allyears rename column "region" to "Region";
alter table allyears rename column "Happiness Score" to "HappiScore";
alter table allyears rename column "Economy (GDP per Capita)" to "GDP";
alter table allyears rename column "Health (Life Expectancy)" to "Health";
alter table allyears rename column "freedom" to "Freedom";
alter table allyears rename column "generosity" to "Generosity";
alter table allyears rename column "Trust (Government Corruption)" to "Trust";
alter table allyears rename column "Family" to "SocSupport";

/*Ujednolicenie typu danych w poszczególnych kolumnach*/
alter table allyears alter column "Year" type varchar(50);
alter table allyears alter column "HappiRank" type numeric;
alter table allyears alter column "Country" type varchar(50);
alter table allyears alter column "Region" type varchar(50);
alter table allyears alter column "HappiScore" type numeric;
alter table allyears alter column "GDP" type numeric;
alter table allyears alter column "Health" type numeric;
alter table allyears alter column "Freedom" type numeric;
alter table allyears alter column "Generosity" type numeric;
alter table allyears alter column "Trust" type numeric;
alter table allyears alter column "SocSupport" type numeric;


/*Usunięcie tych państw, które nie występują we wszystkich regionach*/

delete from allyears where "Country" = 'Angola';
delete from allyears where "Country" = 'Belize';
delete from allyears where "Country" = 'Central African Republic';
delete from allyears where "Country" = 'Comoros';
delete from allyears where "Country" = 'Djibouti';
delete from allyears where "Country" = 'Gambia';
delete from allyears where "Country" = 'Laos';
delete from allyears where "Country" = 'Lesotho';
delete from allyears where "Country" = 'Mozambique';
delete from allyears where "Country" = 'Namibia';
delete from allyears where "Country" = 'Oman';
delete from allyears where "Country" = 'Puerto Rico';
delete from allyears where "Country" = 'Somalia';
delete from allyears where "Country" = 'Somaliland region';
delete from allyears where "Country" = 'Somaliland Region';
delete from allyears where "Country" = 'South Sudan';
delete from allyears where "Country" = 'Sudan';
delete from allyears where "Country" = 'Suriname';
delete from allyears where "Country" = 'Swaziland';
delete from allyears where "Country" = 'United Arab Emirates';

