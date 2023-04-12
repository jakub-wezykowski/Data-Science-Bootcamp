/*2. Wykonaj zapytania, które odpowiedzą na te pytania:*/

/*a. Jakie są miasta, w których mieszka więcej niż 3 pracowników?
 
 *Odpowiedź: Tylko w Londynie mieszka więcej niż 3 pracowników.*/

select "City" 
from employees e
group by "City" 
having count(*) > 3;


/*b. Zakładając, że produkty, które kosztują (UnitPrice) mniej niż 10$ możemy
uznać za tanie, te między 10$ a 50$ za średnie, a te powyżej 50$ za drogie, le
produktów należy do poszczególnych przedziałów? 
 
 *Odpowiedź: Przedział tani - 11 produktów, średni - 59, a drogi to 7 produktów*/

select 
	case
		when "UnitPrice" < 10 then 'tani'
		when "UnitPrice" < 50 then 'sredni'
		else 'drogi'
	end ProductCategory
	,count(*) 
from products p 
group by 
	case
		when "UnitPrice" < 10 then 'tani'
		when "UnitPrice" < 50 then 'sredni'
		else 'drogi'
	end;


/*c. Czy najdroższy produkt z kategorii z największą średnią ceną to najdroższy
produkt ogólnie? */

select max("UnitPrice") najdroższy_produkt_ogólnie
	,(
	select max("UnitPrice")
	from products p 
	where "CategoryID" = 
		(
		select "CategoryID" 
		from products p 
		group by "CategoryID" 
		order by avg("UnitPrice") desc 
		limit 1
		)
	) najdroższy_produkt_z_kategorii_z_największą_średnią_ceną
from products p;

/*Odpowiedź: Najdroższy produkt z kategorii z największą średnią ceną nie jest najdroższym produktem ogólnie.*/


---alternatywne rozwiązanie z odpowiedzią tak/nie w jednej kwerendzie: 
select 
	case when max("UnitPrice") =
		(
		select max("UnitPrice")
		from products p 
		where "CategoryID" = 
			(
			select "CategoryID" 
			from products p 
			group by "CategoryID" 
			order by avg("UnitPrice") desc 
			limit 1
			)
		)
	then 'Tak'
	else 'Nie'
	end Odpowiedź
from products p;



/* d. Ile kosztuje najtańszy, najdroższy i ile średnio kosztuje produkt od każdego z
dostawców? UWAGA – te dane powinny być przedstawione z nazwami
dostawców, nie ich identyfikatorami */

select s."CompanyName"  
	,min("UnitPrice") najtańszy_produkt
	,max("UnitPrice") najdroższy_produkt
	,avg("UnitPrice") średni_koszt_produktów
from products p 
join suppliers s 
	on p."SupplierID" = s."SupplierID" 
group by s."CompanyName";



/* e. Jak się nazywają i jakie mają numery kontaktowe wszyscy dostawcy i klienci
(ContactName) z Londynu? Jeśli nie ma numeru telefonu, wyświetl faks. */

select "ContactName"  
	,case 
		when "Phone" = '' then "Fax" 
		else coalesce("Phone","Fax") 
	end contact_number_or_fax
from suppliers s 
where "City"  = 'London'
union 
select "ContactName"  
	,case 
		when "Phone" = '' then "Fax" 
		else coalesce("Phone","Fax") 
	end contact_number_or_fax
from customers c 
where "City"  = 'London';



/*f. Które miejsce cenowo (od najtańszego) zajmują w swojej kategorii
(CategoryID) wszystkie produkty? */

select c."CategoryName" 
	,"ProductName" 
	,rank() over (partition by p."CategoryID" order by "UnitPrice")
	,"UnitPrice" 
from products p 
left join categories c 
	on p."CategoryID" = c."CategoryID";

-------------------------------------------------------------------------------------------------------------

/* 4. Wykonaj zapytania, które odpowiedzą na te pytania:*/
	
/*a. Jaka była i w jakim kraju miała miejsce najwyższa dzienna amplituda
temperatury?*/

--przyjmując wartości z kaggle dla stopni celcjusza tak jak są (błąd!): 	
select wsl."STATE/COUNTRY ID"
	,max(maxtemp-mintemp) dzienna_amplituda
from summary_of_weather sow 
join weather_station_locations wsl 
	on sow.sta = wsl.wban
group by wsl."STATE/COUNTRY ID" 
order by max(maxtemp-mintemp) desc 
limit 1;
	
/*Odpowiedź: Najwyższa dzienna amplituda temperatury wystąpiłą na Kostaryce i wynosiła 46 stopni.*/

-- Dane dotyczące stopni celcjusza są wyliczane na podstawie pomiarów wyrażonych w fahrenheit, ale zostało to zrobione niepoprawnie. 
-- Tam gdzie brakuje pomiarów (wartość null dla fahrenheit'a) wyliczenie wskazało -17.777779 stopni celcjusza zamiast wykazać brak pomiaru.  
-- Poniżej rozwiązanie, które wyklucza rekordy gdzie brakuje pomiarów temperatury w fahrenheit.

select wsl."STATE/COUNTRY ID" 
	,max(maxtemp-mintemp) dzienna_amplituda
from summary_of_weather sow 
join weather_station_locations wsl 
	on sow.sta = wsl.wban 
where "max" is not null 
	and "min" is not null
group by wsl."STATE/COUNTRY ID" 
order by max("max" - "min") desc 
limit 1;

/*Odpowiedź: Najwyższa dzienna amplituda temperatury wystąpiłą na Grenlandii i wynosiła 28,89 stopni celcjusza.*/


/*b. Z czym silniej skorelowana jest średnia dzienna temperatura dla stacji –
szerokością (lattitude) czy długością (longtitude) geograficzną?*/

select 
	case
		when corr(sow.meantemp, wsl.latitude) < 0 and corr(sow.meantemp, wsl.longitude) < 0 and corr(sow.meantemp, wsl.latitude) < corr(sow.meantemp, wsl.longitude) then 'Latitude'
		when corr(sow.meantemp, wsl.latitude) < 0 and corr(sow.meantemp, wsl.longitude) < 0 and corr(sow.meantemp, wsl.latitude) > corr(sow.meantemp, wsl.longitude) then 'Longitude'
		when corr(sow.meantemp, wsl.latitude) > corr(sow.meantemp, wsl.longitude) then 'Latitude'
		else 'Longitude'
	end silniejsza_korelacja_ze_śr_dzienną_temp
	,corr(sow.meantemp, wsl.latitude) corr_latitude
	,corr(sow.meantemp, wsl.longitude) corr_longitude
from summary_of_weather sow 
join weather_station_locations wsl 
	on sow.sta = wsl.wban;

/*Odpowiedź: średnia dzienna temeperatura dla stacji jest silniej skorelowana z szerkością geograficzną.*/
	

/* c. Pokaż obserwacje, w których suma opadów atmosferycznych (precipitation)
przekroczyła sumę opadów z ostatnich 5 obserwacji na danej stacji. */

select sta
	,"Date"
	,precip
	,coalesce(day_1, 0) + coalesce(day_2,0) + coalesce(day_3,0) + coalesce(day_4,0) + coalesce(day_5,0) sum_of_last_5_days
from (
	select sta
		,"Date" 
		,precip::numeric 
		,lag(precip) over (partition by sta)::numeric  day_1
		,lag(precip,2) over (partition by sta)::numeric day_2
		,lag(precip,3) over (partition by sta)::numeric day_3
		,lag(precip,4) over (partition by sta)::numeric day_4
		,lag(precip,5) over (partition by sta)::numeric day_5
	from (
		select sta
		,"Date"
		,case 
			when precip = 'T' then '0' 
			else precip 
		end precip 
		from summary_of_weather sow 
		) y
	) x 
where precip > coalesce(day_1, 0) + coalesce(day_2,0) + coalesce(day_3,0) + coalesce(day_4,0) + coalesce(day_5,0);
