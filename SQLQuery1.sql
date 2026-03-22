create database OptiShop_SupplyChain ;
use  OptiShop_SupplyChain;
-----
-- test 
-- Check row counts
SELECT 'suppliers' AS table_name, COUNT(*) AS row_count FROM suppliers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales', COUNT(*) FROM sales
UNION ALL
SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL
SELECT 'inventory_daily', COUNT(*) FROM inventory_daily;
--
--Financial Overview
select 
SUM(revenue)AS total_revnue,
SUM(cost) AS total_cost,
SUM(profit)AS total_profit,
(SUM(profit) /SUM(revenue))*100 as profit_margin_pct
from sales
where is_return=0;
--Return Rate Analysis
select 
count(case when is_return=1 then 1 end) as returned_orders,
count(*) as total_orders,
cast(count(case when is_return = 1 then 1 end) as float ) / count(*) *100 
as return_rate_pct
from sales ;

---Warehouse Capacity Check
select 
warehouse_location,
count(distinct product_id) as unique_products,
Sum(stock_on_hand) as total_units_stored
from inventory_daily
where date= (select max(date) from inventory_daily)
group by warehouse_location;
---Supplier Reliability Baseline
select 
supplier_name,
reliability_score, 
average_lead_time_days
from suppliers
where active= 1
order by reliability_score;
 
 --Revenue by Product Category
 select
 p.category,
 SUM(s.revenue) AS category_revenue,
 SUM(s.quantity) as units_sold
 from sales s 
 join products p on s.product_id = p.product_id
 group by p.category
 order by category_revenue desc;
 --Regional Performance by Channel
 select region, channel ,
 sum (revenue) as regional_revenue
 from sales
 group by region, channel
 order by region , regional_revenue desc;

 --Supplier to Product Mapping
 select 
 s.supplier_name,
 s.country,
 p.product_name,
 p.category
 from suppliers s 
 join products p on s.supplier_id = p.supplier_id where s.active=1;

 --Profitability by Brand
 select 
 p.brand,
 sum(s.profit) as total_brand_profit,
 avg(s.discount_pct) as avg_discount_given
 from sales s
 join products p on s.product_id =p.product_id
 group by p.brand 
 order by total_brand_profit desc;
 --Storage Type Inventory Value
 select 
 p.storage_type,
 sum(i.stock_on_hand * p.unit_cost) as total_inventory_value
 from inventory_daily i 
 join products p on i.product_id = p.product_id 
 where i.date=(select max(date) from inventory_daily)
 group by p.storage_type;

 --Top 5 Best Selling Products per Category
 select* from ( 
 select 
 p.category,
 p.product_name,
 sum(s.quantity) as total_qty,
 rank() over(partition by p.category order by sum( s.quantity) desc) as rank_num
 from sales s 
 join products p on s.product_id = p.product_id
 group by p.category,p.product_name
 )t
 where rank_num <=5;

 --Critical Stockout Alert
 select 
 product_id,
 stock_on_hand,
 reorder_point,
 (select avg (quantity)from sales where sales.product_id = i.product_id) 
 as avg_daily_sales
 from inventory_daily i 
 where date= (select max(date)from inventory_daily)
 and stock_on_hand > reorder_point;
 --Products with no sales

 select product_id, product_name,category 
 from products 
 where product_id not in (select distinct product_id from sales);
 --. High-Value Orders vs. Average Order Value
 with OrderTotals as (
 select transaction_id,sum(revenue) as order_value
 from sales 
 group by transaction_id
 ) 
 select * from OrderTotals
 where order_value  >(select avg(order_value) from OrderTotals);
 -- Supplier Lead Time Accuracy
 select 
 po.supplier_id,
 s.supplier_name,
 avg ( po.delay_days) as actual_avg_delay,
 s.average_lead_time_days as promised_lead_time
 from purchase_orders po
 join suppliers s on po.supplier_id=s.supplier_id
 group by po.supplier_id,s.supplier_name,s.average_lead_time_days;


 --Seasonal Peak Analysis
 with seasonalperformance as (
 select
 p.category,
 p.is_seasonal,
 sum(s.revenue) as total_rev
 from products p 
 join sales s on p.product_id= s.product_id 
 group by p.category , p.is_seasonal )
 select* from seasonalperformance where is_seasonal =1;

 --Warehouse Bottleneck Analysis

 select 
 receiving_warehouse,
 count(po_number)as late_shipments,
 avg(delay_days) as avg_days_late
 from purchase_orders
 where delay_days>0
 group by receiving_warehouse;

 --Rush Order" Cost Impact

 select 
 rush_order,
 count(*) as total_orders,
 avg(unit_cost) as avg_item_cost,
 sum(total_cost) as total_spend
 from purchase_orders
 group by rush_order;
 -- Inventory Turnover Ratio
 select 
 s.product_id,
 sum(s.quantity) as total_units_sold,
 avg(i.stock_on_hand) as avg_inventory_level,
 sum(s.quantity) / nullif (avg(i.stock_on_hand),0) as turnover_rate
 from sales s
 join inventory_daily i on s.product_id = i.product_id
 group by s.product_id;

 --Fulfillment Gap
 select supplier_id,
 sum (quantity_ordered) as  units_requested ,
 sum (quantity_received) as units_delivered,
 sum (quantity_ordered) - sum(quantity_received) as shortfall
 from purchase_orders
 group by supplier_id
 having sum(quantity_ordered) - sum( quantity_received) >0;
 --Return Revenue Erosion
 select 
 p.category,
 sum(case when s.is_return =0then s.revenue else 0 end) as gross_revenue,
 sum( case when s.is_return= 1 then s.revenue else 0 end) as lost_revenue,
 (sum(case when s.is_return= 1 then s.revenue else 0 end ) / nullif(sum(s.revenue),0))*100 
 as erosion_rate
 from sales s 
 join products p on s.product_id = p.product_id 
 group by p.category;

 --Monthly Revenue Growth

 select 
 format(date,'yyyy-mm') as month,
 sum(revenue) as current_month_revenue,
 lag(sum(revenue)) over (order by format (date,'yyyy-mm')) 
 as prev_month_revenue,
 (sum(revenue)- lag(sum(revenue)) over (order by format(date,'yyyy-mm' ))) /
 nullif (lag(sum(revenue))over(order by format(date,'yyyy-mm')),0)*100 as growth_pct
 from sales
 group by format (date,'yyyy-mm');

 -- Product Revenue Contribution %
 select 
 product_id,
 revenue,
 sum(revenue) over () as total_company_revenue,
 (revenue / sum(revenue)over())*100.0as pct_of_total_revenue
 from sales;
 --Running Total of Sales by Region
 SELECT 
 date,
 region,
 revenue,
SUM(revenue) OVER(PARTITION BY region ORDER BY date) AS running_total_region
FROM sales;

--Ranking Products by Profit within Category
SELECT 
category,
product_name,
total_profit,
DENSE_RANK() OVER(PARTITION BY category ORDER BY total_profit DESC) AS profit_rank
FROM (
SELECT p.category, p.product_name, SUM(s.profit) AS total_profit
FROM sales s JOIN products p ON s.product_id = p.product_id
GROUP BY p.category, p.product_name
) t;

--Customer Purchase Frequency
SELECT 
customer_id,
transaction_id,
date,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY date) AS purchase_count
FROM sales;
--Creating a Reusable Supplier Scorecard
CREATE VIEW v_SupplierPerformance AS
SELECT 
s.supplier_id,
s.supplier_name,
 AVG(po.delay_days) AS avg_delay,
 COUNT(po.po_number) AS total_orders,
 SUM(po.total_cost) AS total_spent
FROM suppliers s
LEFT JOIN purchase_orders po ON s.supplier_id = po.supplier_id
GROUP BY s.supplier_id, s.supplier_name;


--Inventory Health Summary
CREATE VIEW v_InventoryHealth AS
SELECT 
product_id,
stock_on_hand,
reorder_point,
CASE WHEN stock_on_hand <= reorder_point THEN 'REORDER' ELSE 'OK' END
AS action_status
FROM inventory_daily
WHERE date = (SELECT MAX(date) FROM inventory_daily);

--Moving Average of Sales
SELECT 
date,
SUM(revenue) AS daily_rev,
AVG(SUM(revenue)) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) 
AS seven_day_moving_avg
FROM sales
GROUP BY date;

--Lead Time Variability vs. Reliability
SELECT 
supplier_id,
STDEV(delay_days) AS delay_spread,
AVG(delay_days) AS avg_delay
FROM purchase_orders
GROUP BY supplier_id;
--Supply Chain Master Record
SELECT 
    s.transaction_id,
    s.date,
    p.product_name,
    p.category,
    sup.supplier_name,
    i.stock_on_hand,
    s.revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN suppliers sup ON p.supplier_id = sup.supplier_id
JOIN inventory_daily i ON s.product_id = i.product_id AND s.date = i.date;