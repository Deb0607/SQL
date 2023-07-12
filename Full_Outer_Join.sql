create table product_master 
(
product_id int,
product_name varchar(100)
);

insert into product_master values(100,'iphone5'),(200,'hp laptop'),(300,'dell laptop');

create table orders_usa
(
order_id int,
product_id int,
sales int
);

insert into orders_usa values (1,100,500);
insert into orders_usa values (7,100,500);

create table orders_europe
(
order_id int,
product_id int,
sales int
);

insert into orders_europe values (2,200,600);


create table orders_india
(
order_id int,
product_id int,
sales int
);

insert into orders_india values (3,100,500);
insert into orders_india values (4,200,600);
insert into orders_india values (8,100,500);


select * from orders_usa
select * from orders_europe
select * from orders_india


-- Approch-1
select coalesce(u.product_id , e.product_id, i.product_id) as product_id , u.sales as usa_sales,
e.sales as europe_sales , i.sales as india_sales
from orders_usa as u
full outer join orders_europe  as e on u.product_id = e.product_id
full outer join orders_india as i on  u.product_id = i.product_id


-- Approch-2
select coalesce(u.product_id , e.product_id, i.product_id) as product_id , u.sales as usa_sales,
e.sales as europe_sales , i.sales as india_sales
from orders_usa as u
full outer join orders_europe  as e on u.product_id = e.product_id
full outer join orders_india as i on  coalesce(u.product_id , e.product_id) = i.product_id


-- Approch-1 with full outer join
select coalesce(u.product_id , e.product_id, i.product_id) as product_id , u.sales as usa_sales,
e.sales as europe_sales , i.sales as india_sales
from (select product_id, sum(sales) as sales from orders_usa group by product_id) u
full outer join (select product_id, sum(sales) as sales from orders_europe group by product_id) e on u.product_id = e.product_id
full outer join (select product_id, sum(sales) as sales from orders_india group by product_id) i 
on  coalesce(u.product_id , e.product_id) = i.product_id


-- Alternative Approch with Master Table 
select pm.product_id, u.sales as usa_sales,e.sales as europe_sales, i.sales as india_sales
from product_master as pm
left join (select product_id, sum(sales) as sales from orders_usa group by product_id) u on pm.product_id = u.product_id
left join (select product_id, sum(sales) as sales from orders_europe group by product_id) e on pm.product_id = e.product_id
left join (select product_id, sum(sales) as sales from orders_india group by product_id) i on pm.product_id = i.product_id
where not (u.sales is  null and e.sales is  null and i.sales is  null)


-- Alternative Approch with union
select pm.product_id , u.sales as usa_sales , e.sales as europe_sales , i.sales as india_sales
from (select product_id from orders_usa
		union
	select product_id from orders_europe
		union
	select product_id from orders_india) as pm
left join (select product_id, sum(sales) as sales from orders_usa group by product_id) as u on pm.product_id = u.product_id
left join (select product_id, sum(sales) as sales from orders_europe group by product_id) as e on pm.product_id = e.product_id
left join (select product_id, sum(sales) as sales from orders_india group by product_id) as i on pm.product_id = i.product_id

-- Alternative Approch with cte
with product_sale as (
select u.product_id , u.sales as usa_sales , 0 as europe_sales, 0 as india_sales  from orders_usa as u
union all
select e.product_id , 0 as usa_sales, e.sales as europe_sales , 0 as india_sales  from orders_europe as e
union all 
select i.product_id , 0 as usa_sales , 0 as europe_sales, i.sales as india_sales from orders_india as i)
select product_id , SUM(usa_sales) as usa_sales, SUM(europe_sales) as europe_sales , SUM (india_sales) as india_sales 
from product_sale group by product_id
