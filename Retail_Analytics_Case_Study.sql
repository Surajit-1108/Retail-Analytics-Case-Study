create database business;
use business;
select * from customer_profiles;
select * from sales_transaction;
select * from product_inventory;

/* 1. Write a query to identify the number of duplicates in "sales_transaction" table. 
Also, create a separate table containing the unique values and remove the original table
 from the databases and replace the name of the new table with the original name. */
 
select TransactionID, count(*) from sales_transaction group by 1 having count(*) > 1;
create table sales_transaction1 like sales_transaction;
insert into sales_transaction1 (select distinct * from sales_transaction);
drop table sales_transaction;
alter table sales_transaction1 rename to sales_transaction;
select * from sales_transaction;

/* 2. Write a query to identify the discrepancies in the price of the same product in
 "sales_transaction" and "product_inventory" tables. Also, update those discrepancies
 to match the price in both the tables. */

select TransactionID, t.price TransactionPrice, p.price InventoryPrice
from sales_transaction t INNER JOIN product_inventory p using(ProductID)
where t.price <> p.price;

update sales_transaction s INNER JOIN product_inventory p using(ProductID)
set s.price = p.price where s.price <> p.price;

select * from sales_transaction;

/* 3. Write a SQL query to identify the null values in the dataset and
 replace those by “Unknown”. */

SELECT count(*) from customer_profiles WHERE location IS NULL OR Location = '';
UPDATE customer_profiles
SET Location = "Unknown" WHERE Location IS NULL OR Location = '';

select * from customer_profiles;                    

/* 4. Write a SQL query to clean the DATE column in the dataset. */

alter table Sales_transaction add column TransactionDate_updated date;
update Sales_transaction
set TransactionDate_updated = str_to_date(TransactionDate, "%d/%m/%y");

select * from Sales_transaction;            

/* 5. Write a SQL query to summarize the total sales and quantities sold per product by the company. */

select ProductID, sum(QuantityPurchased) TotalUnitsSold, 
sum(QuantityPurchased * Price) TotalSales
from Sales_transaction
Group by ProductID order by TotalSales desc;           

/* 6. Write a SQL query to count the number of transactions per customer 
to understand purchase frequency. */

select CustomerID, count(TransactionID) NumberOfTransactions
from Sales_transaction
Group by CustomerID order by NumberOfTransactions desc;

/* 7. Write a SQL query to evaluate the performance of the product categories based on 
the total sales which help us understand the product categories which needs to be 
promoted in the marketing campaigns. */

select p.Category as Category, sum(s.QuantityPurchased) as TotalUnitsSold,
sum(s.QuantityPurchased * s.Price) as TotalSales
from product_inventory p INNER JOIN Sales_transaction s using(ProductID)
Group by p.Category Order by TotalSales desc;

/* 8. Write a SQL query to find the top 10 products with the highest total sales revenue 
from the sales transactions. This will help the company to identify the High sales products
 which needs to be focused to increase the revenue of the company. */
 
select ProductID, sum(QuantityPurchased * Price) TotalRevenue
from Sales_transaction
Group by ProductID Order by TotalRevenue desc limit 10;
 
/* 9. Write a SQL query to find the ten products with the least amount of units sold 
from the sales transactions, provided that at least one unit was sold for those products. */

select ProductID, sum(QuantityPurchased) TotalUnitsSold
from Sales_transaction
Group by ProductID Having TotalUnitsSold >= 1 Order by TotalUnitsSold  limit 10;

/* 10. Write a SQL query to identify the sales trend to understand the revenue pattern
 of the company. */
 
select TransactionDate_updated DATETRANS, count(TransactionID) Transaction_count,
sum(QuantityPurchased) TotalUnitsSold, sum(QuantityPurchased * Price) TotalSales
from sales_transaction
Group by DATETRANS order by DATETRANS desc;

/* 11. Write a SQL query to understand the month on month growth rate of sales of the
 company which will help understand the growth trend of the company. */
 
 With CTE as (select month(TransactionDate) month, sum(QuantityPurchased * Price) total_sales, 
lag(sum(QuantityPurchased * Price)) over(order by month(TransactionDate))
as previous_month_sales
from sales_transaction
group by month)
select *, 
(((total_sales - previous_month_sales) / previous_month_sales)) * 100  mom_growth_percentage
from CTE;

/* 12. Write a SQL query that describes the number of transaction along with the total amount
 spent by each customer which are on the higher side and will help us understand the
 customers who are the high frequency purchase customers in the company. */

select CustomerID, count(TransactionID) NumberOfTransactions, sum(QuantityPurchased * Price) TotalSpent
from sales_transaction
Group by CustomerID
having NumberOfTransactions > 10 and TotalSpent > 1000
order by TotalSpent desc;

/* 13. Write a SQL query that describes the number of transaction along with the
 total amount spent by each customer, which will help us understand the customers 
 who are occasional customers or have low purchase frequency in the company. */
 
select CustomerID, count(TransactionID) NumberOfTransactions, sum(QuantityPurchased * Price) TotalSpent
from Sales_transaction
Group by CustomerID having NumberOfTransactions <= 2
order by NumberOfTransactions asc, TotalSpent desc ;

/* 14. Write a SQL query that describes the total number of purchases made by each 
customer against each productID to understand the repeat customers in the company. */

select CustomerID, ProductID, count(TransactionID) TimesPurchased
from Sales_transaction
Group by CustomerID, ProductID
having TimesPurchased > 1 order by TimesPurchased desc;
 
/* 15. Write a SQL query that describes the duration between the first and the last
 purchase of the customer in that particular company to understand 
 the loyalty of the customer. */
 
update Sales_transaction
set TransactionDate = str_to_date(TransactionDate, "%d/%m/%y");

select CustomerID,
min(TransactionDate) FirstPurchase, max(TransactionDate) LastPurchase,
datediff(max(TransactionDate), min(TransactionDate)) DaysBetweenPurchases
from Sales_transaction
Group by CustomerID
having DaysBetweenPurchases > 0
order by DaysBetweenPurchases desc;

/* 16. Write a SQL query that segments customers based on the total quantity of products
 they have purchased. Also, count the number of customers in each segment
 which will help us target a particular segment for marketing. */

create table Cust_segment as
Select
    CASE WHEN qnt between 1 and 9 THEN "Low"
    WHEN qnt between 10 and 30 THEN "Med"
    WHEN qnt > 30 THEN "High"
    END as CustomerSegment, COUNT(*)
from (select c.CustomerID, sum(s.QuantityPurchased) as qnt
from Sales_transaction s INNER JOIN Customer_profiles c using(CustomerID)
Group by c.CustomerID) as xyz
Group by CustomerSegment;

select * from Cust_segment;
