select * from swiggy_cleaned

select 
    sum(case when hotel_name='' then 1 else 0  end) as hotel_name,
    sum(case when rating='' then 1 else 0  end) as rating,
	sum(case when time_minutes='' then 1 else 0  end) as time_minutes,
	sum(case when food_type='' then 1 else 0  end) as food_type,
    sum(case when location='' then 1 else 0  end) as location,
	sum(case when offer_above='' then 1 else 0  end) as offer_above,
    sum(case when offer_percentage='' then 1 else 0  end) as offer_percentage
    from swiggy_cleaned
    
    
-- schemas, group concate, concate , prepare , execute  etc.    

select* from information_schema.columns  where table_name= 'swiggy_cleaned'
select column_name from information_schema.columns  where table_name= 'swiggy_cleaned'

-- concat
select concat('Ajay Sati','campusX')

-- group concat
   -- it concates the o/p of concat function.
   

delimiter //
create procedure  count_blank_rows()
begin
		select group_concat(
			   concat('sum(case when`', column_name, '`='''' Then 1 else 0 end) as `', column_name ,'`')
			) into @sql 
			from information_schema.columns  where table_name= 'swiggy_cleaned';

		set @sql = concat('select ', @sql,' from swiggy_cleaned');


		prepare smt from  @sql;
		execute  smt ;
		deallocate  prepare smt;
	end
//
delimiter;

call count_blank_rows()

select * from swiggy_cleaned 



-- shifting values of rating to time_minutes

create table clean as
select * from swiggy_cleaned where rating like '%mins%'

create table cleaned as 
select *, f_name(rating) as 'rat'  from clean 
set sql_safe_updates= 0

 update swiggy_cleaned as s
 inner join cleaned as c 
 on s.hotel_name= c.hotel_name
 set s.time_minutes= c.rat


select * from swiggy_cleaned
drop table cleaned 

-- clening for ('-')

create table clean as
select * from swiggy_cleaned where time_minutes like '%-%'
select * from clean

create table cleaned as 
select *, f_name(time_minutes) as f1, l_name(time_minutes) as f2 from clean
'NH1 Bowls - Highway To North'
 update swiggy_cleaned as s
 inner join cleaned as c 
 on s.hotel_name= c.hotel_name
 set s.time_minutes =((c.f1+c.f2)/2)
 
 select * from swiggy_cleaned where hotel_name='NH1 Bowls - Highway To North'
 
 select * from swiggy_cleaned
 
 
 
 --              time_minutes column is cleaned
 
 
 
 
 
 -- Cleaning rating column.

select location, round(avg(rating),2) as average
from swiggy_cleaned 
where rating not like '%mins%'
group by location


update swiggy_cleaned AS t
JOIN (
    SELECT location, round(AVG(rating),2) AS avg_rating
    FROM swiggy_cleaned
    WHERE rating not like '%mins%'
    GROUP BY location
) AS avg_table ON t.location = avg_table.location
set t.rating= avg_table.avg_rating
where t.rating like '%mins%'

select * from swiggy_cleaned  where rating like '%mins%'

set @average = (select round(avg(rating),2) from swiggy_cleaned where rating not like '%mins%');
select @average

update  swiggy_cleaned 
set rating = @average 
where rating like '%mins%'


-- our rating column is also cleaned.

select distinct(location) from swiggy_cleaned  where  location like '%Kandivali%'

update swiggy_cleaned 
set location  ='Kandivali East'
where location like '%East%'

update swiggy_cleaned 
set location  ='Kandivali West'
where location like '%West%'


update swiggy_cleaned 
set location  ='Kandivali East'
where location like '%E%'

update swiggy_cleaned 
set location  ='Kandivali West'
where location like '%W%'


   -- location column is also cleaned.
   
select * from swiggy_cleaned

-- cleaning offer_precentage column.

update swiggy_cleaned
set offer_percentage = 0
where  offer_above = 'not_available'


-- percentage column is also cleaned.




-- cleaning food_type column
'American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks'

select substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',3)
select substring_index( substring_index('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',5),',', -1)



select char_length('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks')
select char_length(replace('American, Burgers, Italian, Continental, Pizzas, Pastas, Beverages, Snacks',',',''))





select distinct food from 
(
select *, substring_index( substring_index(food_type ,',',numbers.n),',', -1) as 'food'
from  swiggy_cleaned 
	join
	(
		select 1+a.N + b.N*10 as n from 
		(
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9) a
			cross join 
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9)b
		)
	)  as numbers 
    on  char_length(food_type)  - char_length(replace(food_type ,',','')) >= numbers.n-1
)a



-- 


-- 



