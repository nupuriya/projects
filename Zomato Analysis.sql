drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1   What is the total amount each customer spent on zomato?

select a.userid, sum(b.price) total_amt from sales a inner join product b on a.product_id=b.product_id group by a.userid;

--2  How many days has each customer visited zomato?

select userid, count(distinct created_date)  no_of_days from sales group by userid;

--3  what was the first product purchased by each customer?

select userid, product_id, rnk from
(select *, rank() over(partition by userid order by created_date) rnk from sales)a where rnk=1;

--4  What is the most purchased item on the menu and how many times was it purchased by all customers?

select userid, count(product_id) from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid

--5   whict item was the most popular for each customer?

select b.* from(
select a.*, rank() over(partition by userid order by cnt desc) rnk from
(select userid, product_id, count(product_id) cnt from sales group by userid, product_id) a)b where rnk=1

--6  Which item was purchased first by the customer after they became a memeber

select d.* from
(select c.*, rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid = b.userid 
and a.created_date>= b.gold_signup_date)c) d where rnk=1

--7  Which item was purchased just before a customer became a member?

select d.* from
(select c.*, rank() over(partition by userid order by created_date desc) rnk from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid = b.userid 
and a.created_date<= b.gold_signup_date)c) d where rnk=1

--8  What is the total order and amount spent for each member before they became a member?

select e.userid, count(e.created_date) cnt, sum(e.price) amt from
(select c.*, d.price from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid = b.userid 
and a.created_date<= b.gold_signup_date)c inner join product d on c.product_id = d.product_id)e group by userid

--9  If buying each product generates points for e.g. 5rs=2 zomato points and each product has different purchasing points for e.g. 
--for p1 5rs = 1zomato points, for p2 10rs = 5 zomato points and p3 5rs = 1 zomato points. Calculate points collected by each customer and for which product points have been given till now.

select userid, sum(zomato_points)*2.5 total_money_earned from
(select d.*, case
when product_id=1 then amt/5
when product_id=2 then amt/2
else amt/5
end as zomato_points from
(select c.userid, c.product_id, sum(c.price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id) c 
group by c.userid, c.product_id) d) e group by userid

select * from
(select *, rank() over(order by total_points desc) rnk from
(select product_id, sum(zomato_points) total_points from
(select d.*, case
when product_id=1 then amt/5
when product_id=2 then amt/2
else amt/5
end as zomato_points from
(select c.userid, c.product_id, sum(c.price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id) c 
group by c.userid, c.product_id) d) e group by product_id) f) g where rnk = 1


--10 In the first year the customer joins the gold program(including their join date) irrespective of what the customer has purchased they earn 5 zomato points for every 5 rs spent, who earned more 1 or 3?


select c.*, d.price* 0.5 total_points_earned from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a inner join goldusers_signup b on a.userid = b.userid 
and a.created_date>= gold_signup_date and created_date<= dateadd(year,1, b.gold_signup_date) ) c inner join product d on c.product_id = d.product_id

--11  rank all the transaction of the customer

select *, rank() over(partition by userid order by created_date) from sales

