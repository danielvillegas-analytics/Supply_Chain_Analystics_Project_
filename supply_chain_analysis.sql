create database supplychain;
use supplychain;

CREATE TABLE cleaninformation (
Type VARCHAR(20),
Days_for_shipping_real INT,
Days_for_shipment_scheduled INT,
Days_delivery_delay INT,
On_Time_Delivery_Flag VARCHAR(20),
OnTimeNumeric INT,
Benefit_per_order DOUBLE,
Sales_per_customer DOUBLE,
Delivery_Status VARCHAR(50),
Late_delivery_risk INT,
Category_Name VARCHAR(100),
Customer_City VARCHAR(100),
Customer_Country VARCHAR(100),
Customer_Id INT,
Repeat_Customer_Flag INT,
Customer_Segment VARCHAR(50),
Customer_State VARCHAR(50),
Department_Name VARCHAR(100),
Market VARCHAR(100),
Order_City VARCHAR(100),
Order_Country VARCHAR(100),
order_date DATE,
Order_Id INT,
Order_Item_Discount DOUBLE,
Order_Item_Discount_Rate DOUBLE,
Order_Item_Product_Price DOUBLE,
Order_Item_Profit_Ratio DOUBLE,
Order_Item_Quantity INT,
Sales DOUBLE,
Order_Region VARCHAR(100),
Order_State VARCHAR(100),
Order_Status VARCHAR(50),
Product_Name VARCHAR(255),
shipping_date DATE,
Shipping_Mode VARCHAR(50),
Customer_Purchase_Count INT
);

select * from cleaninformation;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/copycleaninformation.csv'
INTO TABLE cleaninformation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(type) from cleaninformation;

select * from cleaninformation;

DROP TABLE IF EXISTS cleaninformation;

/*total revenue and total profit. */

select round(sum(sales),2) as total_revenue, round(sum(benefit_per_order),2) as total_profit
from cleaninformation;

/*total sales for each market. */

select market, sum(sales) as total_sales
from cleaninformation
group by market;

/*average profit per order by customer segment. */

select customer_segment , round(avg(benefit_per_order),2) as avg_profit
from cleaninformation
group by customer_segment;

/*total number of orders placed in each country. */

select order_country, count(distinct order_id) as total_order
from cleaninformation
group by order_country
order by order_country asc;

/*top 10 products by total sales. */

select product_name, round(sum(sales),2) as total_sale 
from cleaninformation
group by product_name
limit 10;

/*average shipping delay by shipping mode. */

select shipping_mode, round(avg(days_delivery_delay)) as avg_shipping_delay
from cleaninformation
group by shipping_mode
order by avg_shipping_delay desc ;

/*total profit by category name. */

select category_name, round(sum(benefit_per_order),2) as total_profit
from cleaninformation
group by category_name
order by total_profit desc;

/*percentage of late deliveries. */

select sum(late_delivery_risk) * 100 / count(late_delivery_risk) as percentage_late_deliveries
from cleaninformation;

/*total revenue and profit for orders that were delivered late vs on time. */

select on_time_delivery_flag, round(sum(benefit_per_order),2) as total_profit, round(sum(sales),2) as total_revenue
from cleaninformation
group by on_time_delivery_flag
order by on_time_delivery_flag desc ;

/*average discount rate by customer segment. */

select customer_segment, round(avg(order_item_discount_rate),4) * 100 as avg_discount_rates 
from cleaninformation
group by customer_segment;

/*top 5 most profitable markets. */

select market, round(sum(benefit_per_order),2) as total_profit, round(sum(sales),2) as total_revenue
from cleaninformation
group by market
order by market desc
limit 5;

/*total sales and total quantity sold per product. */

select product_name,count(order_item_quantity) as total_item_quantity,  sum(sales) as total_sales
from cleaninformation
group by product_name
order by total_item_quantity desc;

/*customers who made more than 5 purchases. */

select customer_id, count(*) as total_purchases
from cleaninformation
group by customer_id
having total_purchases > 5
order by total_purchases desc;

select * from cleaninformation;

/*monthly total sales based on order_date. */

select date_format(order_date, '%Y,%m') AS months_sales, round(sum(sales),2) as total_sales
from cleaninformation
group by date_format(order_date, '%Y,%m') 
order by months_sales;

/*average profit margin (profit/sales) per department. */

select department_name, round(sum(benefit_per_order) / sum(sales) *100,4) as avg_pofit_margin
FROM cleaninformation
GROUP BY department_name
order by avg_pofit_margin desc;

/*number of repeat customers vs new customers. */

SELECT SUM(total_orders = 1) AS new_customers, SUM(total_orders > 1) AS repeat_customers
FROM ( SELECT customer_id, COUNT(*) AS total_orders
    FROM cleaninformation
    GROUP BY customer_id
) total;

/*rank products by total profit from highest to lowest. */

select product_name, round(sum(benefit_per_order),2) as total_profit, 
		rank() over (order by sum(benefit_per_order) desc) as profit_rank
from cleaninformation
GROUP BY product_name;

/*market’s contribution (%) to total company sales. */

select market, sum(sales) as total_sales, round(sum(sales) * 100 / (select sum(sales) from cleaninformation),2) as percentage_contribution
from cleaninformation
group by market;

/*markets where total profit is above the overall average profit. */

with markets_profit as ( select market, sum(benefit_per_order) as total_profit
				from cleaninformation
                group by market
) 
select market, total_profit 
from markets_profit
where total_profit > (select avg(total_profit)
						from markets_profit);

/*running total of sales ordered by date, like accumulated*/ 

select order_date, sum(sales) as total_sales, 
		sum(sum(sales)) over (order by order_date) as running_total
FROM cleaninformation 
group by order_date
order by order_date;

/*total spending by customer and rank them by spending. */

select customer_id, sum(sales) as total_spend,  
	rank() over (order by sum(sales) desc) as spending_rank
FROM cleaninformation 
group by customer_id;

/*top 10% highest spending customers. */

select * 
from ( select customer_id, round(sum(sales),2) as total_spend,
		ntile(10) over(order by sum(sales) desc) as spending_group
        from cleaninformation
        group by customer_id
) total 
where spending_group = 1; 

/*percentage of total orders by shipping mode */

SELECT shipping_mode, COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM cleaninformation
GROUP BY shipping_mode;

/*average profit products is below the overall average profit. */

with product_profit as ( select product_name, sum(benefit_per_order) as total_profit
						from cleaninformation
                        group by product_name
) 
select product_name, total_profit
from product_profit
where total_profit < (select avg(total_profit) 
						from product_profit);
                        