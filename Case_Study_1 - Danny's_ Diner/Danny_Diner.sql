
--CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  select * from sales
  select * from menu
  select * from members

   --Qus 1:  What is the total amount each customer spent at the restaurant? 
   '''
with cte as
(
select 
      s.customer_id ,m.price , m.product_id
from 
    sales as s inner join menu as m 
on  s.product_id = m.product_id)
select 
      customer_id , sum(price) as total_ampount from cte
group by 
      customer_id
order by 
      customer_id;
	'''

  --RESULT 
  --customer_id A spent 76 rs 
  --customer_id B spent 74 rs 
  --customer_id C spent 36 rs as total_amount


 --Qus 2: How many days has each customer visited the restaurant?

 SELECT
        customer_id , count(distinct(order_date)) as total_visit 
 from 
        sales 
 group by 
        customer_id 
 order by
        customer_id;

  --RESULT
  --customer_id A has 4
  --customer_id B has 6 
  --customer _id c has 2 total_visit

  -- Qus 3: What was the first item from the menu purchased by each customer?

  with cte as 
 ( 
 select
     s.customer_id, s.order_date,  m.product_name , DENSE_RANK() over (partition by customer_id order by order_date) as rn
 from 
     sales as s inner join menu as m 
 on
     s.product_id = m.product_id)
 select 
       customer_id , product_name
 from
     cte 
 where rn = 1;

 --RESULT     
 --customer_id	  product_name
 --   A	            sushi
 --   A	            curry
 --   B             curry
 --   C	            ramen
 --   C	            ramen

 --Qus 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1 product_name , count(s.product_id) as total_order from sales as  s inner join 
menu as m on s.product_id = m.product_id 
group by  product_name
order by count(s.product_id) desc;

--RESULT:
--product_name	total_order
--ramen	           8

--Qus 5. Which item was the most popular for each customer?


with cte_1 as 
 (select
       s.customer_id, count(s.product_id) as total_order, m.Product_name, DENSE_RANK () over (partition by customer_id order by count(s.product_id)desc) as rn 
 from 
     sales as s inner join menu as m
 on 
  s.product_id = m.product_id
 group by 
        s.customer_id,m.product_name)
 select 
      customer_id , total_order, product_name
 from 
    cte_1
 where
     rn =1

--RESULT:
--customer_id	 total_order	   product_name
--A	           3        	         ramen
--B	           2	                 sushi
--B	           2	                 curry
--B	           2	                 ramen
--C                3	                 ramen
 

 --Qus 6. Which item was purchased first by the customer after they became a member?

 with cte_2 as
 (select
         s.customer_id , s.order_date, m.join_date , me.product_name,  dense_rank() over(partition by s.customer_id order by s.order_date) as rn 
 from  
      sales as s inner join members as m 
 on 
   s.customer_id = m.customer_id inner join menu as me
 on 
  me.product_id = s.product_id
 where 
      join_date < order_date
 
 )
 select
      customer_id ,   product_name 
 from
      cte_2 where  rn = 1;

 --RESULT:
 --customer_id	product_name
 --  A	             ramen
 --  B	             sushi

 --Qus 7.Which item was purchased just before the customer became a member?

 
 with cte_2 as
 (
select
     s.customer_id , s.order_date, m.join_date , me.product_name,   dense_rank() over(partition by s.customer_id order by s.order_date desc) as rn 
 from 
     sales as s inner join members as m 
 on 
    s.customer_id = m.customer_id inner join menu as me
 on 
   me.product_id = s.product_id
 where 
   join_date > order_date
 
 )
 select 
      customer_id ,   product_name 
 from 
      cte_2 
 where  rn = 1;

 --RESULT:
 --customer_id	product_name
 --   A	             sushi
 --   A              curry
 --   B	             sushi

 --Qus 8. What is the total items and amount spent for each member before they became a member?
 
 with cte_4 as
(
 select 
      s.customer_id , s.order_date, m.join_date , me.product_name, s.product_id ,me.price, dense_rank() over(partition by s.customer_id order by s.order_date desc) as rn 
 from 
     sales as s inner join members as m 
 on 
  s.customer_id = m.customer_id inner join menu as me
 on 
   me.product_id = s.product_id
 where
      join_date > order_date
 )
 select
       customer_id, sum(price) as total_amount , count(product_id) as total_item 
 from 
       cte_4
 group by 
       customer_id 
 order by
       count(product_id), sum(price);


  --RESULT:
  --customer_id	total_amount	total_item
  --   A	          25	            2
  --   B	          40                3

--Qus 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

  with points as
(SELECT *, 
CASE WHEN product_name = 'sushi' then price*20 ELSE price*10 END as points
from menu m)

SELECT s.customer_id, SUM(p.points) as total_points
from points as p
join sales s
on s.product_id = p.product_id
group by customer_id

--RESULT :
--customer_id  	total_points
--    A	           860
--    B	           940
--    C	           360

--Qus 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all
--        items, not just sushi - how many points do customer A and B have at the end of January?
 
 WITH dates AS 
(
   SELECT *, 
      DATEADD(DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM members AS m
)

SELECT d.customer_id,
	SUM(
	CASE WHEN product_name = 'sushi' then price*20
	 WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN price * 20
	ELSE price*10 END 
	) as total_points
from dates d
join sales s
on d.customer_id = s.customer_id
join menu m
on m.product_id = s.product_id
WHERE s.order_date < d.last_date
group by d.customer_id

--RESULT:
--customer_id	   total_points
--      A	          1370
--      B	          820
