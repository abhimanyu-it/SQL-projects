create database project;
use project;
-- CREATING THE DATABASE---
create table main (
invoice_id varchar(255) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
VAT float(6,4) not null, -- 6 digits of which 4 are after decimal place
total decimal(12,4) not null,
date datetime not null,
time TIME not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income decimal(12,4) not null,
rating float(2,1)
);

-- FEATURE ENGINEERING----
-- 1st feature engineering--
-- time_of_day--
select time,
(case 
when time between "00:00:00" and "12:00:00" then "Morning"
when time between "12:00:00" and "16:00:00" then "AfterNoon"
else "Evening"
end
) as time_of_day from main;
alter table main add column time_of_day varchar(20);

update main
set time_of_day = (select
case 
when time between "00:00:00" and "12:00:00" then "Morning"
when time between "12:00:00" and "16:00:00" then "AfterNoon"
else "Evening"
end
);
-- 2nd feature engineering---
-- day_name---
select dayname(date) as day_name from main;
alter table main add column day_name varchar(25);
update main set day_name = dayname(date);

-- 3rd feature engineering---
-- month_name---
select monthname(date) as month_name from main;
alter table main add column month_name varchar(25);
update main set month_name = monthname(date);

-- GENERIC---------------
-- How many unique cities does the data have?
select distinct(city) from main;
-- In which city is each branch?
select distinct city, branch from main;

-- ----------------------------PRODUCT ANALYSIS-------------------------------
-- How many unique product lines does the data have?
select count(distinct product_line) from main;
-- What is the most common payment method?
select count(payment_method),payment_method from main group by payment_method order by count(payment_method) desc limit 1;
-- what is most selling product line.
select count(product_line),product_line from main group by product_line order by count(product_line) desc limit 1;
-- what is total revenue by month.
select sum(total) as total_revenue,month_name as month from main group by month_name order by month desc limit 1;
-- which month has largest cogs.
select sum(cogs) as total_cogs, month_name as month from main group by month_name order by sum(cogs) desc limit 1;
-- which product line had the largest revenue?
select sum(total) as tota_revenue , product_line from main group by product_line order by sum(total) desc limit 1;
-- what is the city with largest revenue?
select sum(total) as revenue , city from main group by city order by sum(total) desc limit 1;
-- which product line has largest VAT
select sum(VAT) , product_line from main group by product_line order by sum(VAT) desc limit 1;

-- Which branch sold more products than average product sold?
select sum(quantity),branch from main group by branch having sum(quantity) > (select avg(quantity) from main);
-- what is most common product line by gender?
select count(product_line),gender,product_line from main group by gender,product_line order by count(product_line) desc limit 1;
-- what is avg rating of each product line?
select avg(rating),product_line from main group by product_line; 

-- -------------------------SALES ANALYSIS -----------------
-- Number of sales made in each time of the day per weekday
select sum(total) as sales, time_of_day from main where day_name  = 'Monday' group by time_of_day;
-- Which of the customer types brings the most revenue?
select sum(total) as revenue , customer_type from main group by customer_type;
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, sum(VAT) from main group by city order by sum(VAT) desc limit 1;
-- which customer type pays the most in VAT?
select customer_type , avg(VAT) as VAT from main group by customer_type order by VAT desc;


-- -------------------------CUSTOMER ANALYSIS------------------
-- How many unique customer types does the data have?
select distinct(customer_type) from main;
-- How many unique payment methods does the data have?
select distinct(payment_method) from main;
-- What is the most common customer type?
select count(customer_type),customer_type from main group by customer_type order by count(customer_type) desc limit 1;
-- Which customer type buys the most?
select sum(quantity),customer_type from main group by customer_type;
-- What is the gender of most of the customers
select gender,count(*) from main group by gender order by count(*);
-- What is the gender distribution per branch?
select count(gender) as gender_count,gender,branch from main group by gender,branch order by branch;
-- Which time of the day do customers give most ratings?
select time_of_day, avg(rating) from main group by time_of_day;
-- Which time of the day do customers give most ratings per branch?
select time_of_day, avg(rating) from main where branch = "C" group by time_of_day;
-- Which day fo the week has the best avg ratings?
select day_name, avg(rating) as avg_rating from main group by day_name order by avg(rating) desc limit 1;
-- Which day of the week has the best average ratings per branch?
select branch,avg(rating) as avg_rating from main group by branch;
    


