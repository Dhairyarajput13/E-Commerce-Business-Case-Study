create database casestudy_Ecommerce_db;
use casestudy_Ecommerce_db;

-- Data cleaning 
select * from customers;
select count(*) from customers;

select distinct * from customers;
select count(*)
from (select distinct * from customers) as c ;

select * from orderdetails;
select count(*) from orderdetails;

select distinct * from orderdetails;
select count(*)
from (select distinct * from orderdetails) as o ;

select * from orders;
select count(*) from orders;

select distinct * from orders;
select count(*)
from (select distinct * from orders) as o ;

select * from products;
select count(*) from products;

select distinct * from products;
select count(*)
from (select distinct * from products) as p ;

select * from orderdetails;

select distinct * from orderdetails;

-- create a table with distinct orderdetails
create table distinct_orderdetails(
select distinct * from orderdetails);

select * from distinct_orderdetails;

select count(*) from distinct_orderdetails;

--  change the data type to date of orders table
select * from orders;
alter table orders
modify column order_date date;

--  Case study queries 

--  analyze all the tables by describing their contents.
-- Task: Describe the Tables:
-- Customers
-- Products
-- Orders
-- OrderDetails

desc customers;
desc Products;
desc Orders;
desc Orderdetails;

-- Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
-- Use the “Customers” Table.
-- Return the result table limited to top 3 locations in descending order

select location, count(customer_id) as number_of_customers
from Customers 
group by location
order by number_of_customers desc
limit 3;

-- Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.
-- Use the “Orders” table.
-- Return the result table which helps you to segment customers on the basis of the number of orders in ascending order.

SELECT 
    NumberOfOrders,COUNT(*) AS CustomerCount
FROM (
    SELECT customer_id, COUNT(order_id) AS NumberOfOrders
    FROM Orders
    GROUP BY customer_id
) AS OrderSummary
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders ASC;

-- Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
-- Use “OrderDetails”.
-- Return the result table which includes average quantity and the total revenue in descending order.

select Product_Id , avg(quantity) as AvgQuantity, 
sum(quantity*price_per_unit) as TotalRevenue
from OrderDetails
group by Product_Id
having AvgQuantity=2
order by TotalRevenue desc;

-- For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.
-- Use the “Products”, “OrderDetails” and “Orders” table.
-- Return the result table which will help you count the unique number of customers in descending order.

select p.category as category, count(distinct o.customer_id) as unique_customers
from Products p join OrderDetails od on p.product_id = od.product_id
join Orders o on od.order_id = o.order_id
group by p.category
order by unique_customers desc;


-- Analyze the month-on-month percentage change in total sales to identify growth trends.
-- Use the “Orders” table.
-- Return the result table which will help you get the month (YYYY-MM), Total Sales and Percent Change of the
--  total amount (Present month value- Previous month value/ Previous month value)*100.
-- The resulting change in percentage should be rounded to 2 decimal places

WITH cte AS (
    SELECT DATE_FORMAT(order_date, "%Y-%m") AS YearMonth, SUM(total_amount) AS TotalSales
    FROM orders
    GROUP BY DATE_FORMAT(order_date, "%Y-%m")
),
cte_2 AS (
    SELECT YearMonth, TotalSales,
        LAG(TotalSales) OVER (ORDER BY YearMonth) AS prev_month_sales
    FROM cte
)
SELECT YearMonth, TotalSales,
    ROUND(((TotalSales - prev_month_sales) / prev_month_sales) * 100, 2) AS PercentChange
FROM cte_2;


-- Examine how the average order value changes month-on-month. 
-- Insights can guide pricing and promotional strategies to enhance order value.
-- Use the “Orders” Table.
-- Return the result table which will help you get the month (YYYY-MM), 
-- Average order value and Change in the average order value (Present month value- Previous month value).
-- Both the resulting AvgOrderValue and ChangeInValue column should be rounded to two decimal places, 
-- with the final results ordered in descending order by ChangeInValue.

WITH cte AS (
    SELECT DATE_FORMAT(order_date, "%Y-%m") AS YearMonth, avg(total_amount) AS AvgOrderValue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, "%Y-%m")
),
cte_2 AS (
    SELECT YearMonth, AvgOrderValue,
        LAG(AvgOrderValue) OVER (ORDER BY YearMonth) AS prev_month_avgValue
    FROM cte
)
SELECT YearMonth, AvgOrderValue,
    ROUND((AvgOrderValue - prev_month_avgValue), 2) AS ChangeInValue
FROM cte_2;


-- Based on sales data, identify products with the fastest turnover rates,
-- suggesting high demand and the need for frequent restocking.
-- Use the “OrderDetails” table.
-- Return the result table limited to top 5 product according to the SalesFrequency column in descending order.

select product_id, count(order_id) as SalesFrequency
from orderdetails
group by product_id
order by SalesFrequency desc
limit 5;


-- List products purchased by less than 40% of the customer base, indicating potential mismatches between 
-- inventory and customer interest.
-- Use the “Products”, “Orders”, “OrderDetails” and “Customers” table.
-- Return the result table which will help you get the product names along with the count of unique customers 
-- who belong to the lower 40% of the customer pool.

select p.product_id as Product_id, p.name as Name, count(distinct o.customer_id) as UniqueCustomerCount
from Products p join OrderDetails od on p.product_id = od.product_id
join Orders o on od.order_id = o.order_id
group by p.product_id,p.name 
having count(distinct o.customer_id) < 0.4 * (select count(distinct customer_id) from customers);


-- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing 
-- campaigns and market expansion efforts.
-- Use the “Orders” table.
-- Return the result table which will help you get the count of the number of customers who made the first purchase on monthly basis.
-- The resulting table should be ascendingly ordered according to the month.

with cte as(
    select customer_id, DATE_FORMAT(MIN(order_date), "%Y-%m") AS FirstPurchaseMonth
    FROM Orders
    GROUP BY customer_id
)
SELECT FirstPurchaseMonth , COUNT(*) AS TotalNewCustomers
FROM cte
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;

-- Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, 
-- and staffing in anticipation of peak demand periods.
-- Use the “Orders” table.
-- Return the result table which will help you get the month (YYYY-MM) and the Total sales made by the company 
-- limiting to top 3 months.
-- The resulting table should be in descending order suggesting the highest sales month.

select DATE_FORMAT((order_date), "%Y-%m") AS Month, sum(total_amount) as TotalSales
FROM Orders
group by DATE_FORMAT((order_date), "%Y-%m")
order by TotalSales desc
limit 3;









