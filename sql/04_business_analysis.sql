/*=============================================================================
  SUPERSTORE PORTFOLIO PROJECT | 04 BUSINESS ANALYSIS / 业务分析
  Diagnostic chain / 诊断链路:
  category -> region -> discount -> state/product/customer
  品类 -> 区域 -> 折扣 -> 州/产品/客户
=============================================================================*/
USE superstore;

-- B01 | Sub-category profit leakage / 子类利润泄漏定位
SELECT category, sub_category, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(DISTINCT order_id) AS orders
FROM orders_clean
GROUP BY category, sub_category ORDER BY profit;

-- B02 | Central diagnostic: category and sub-category / Central 区域品类与子类下钻
SELECT region, category, sub_category, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(DISTINCT order_id) AS orders
FROM orders_clean
WHERE region='Central'
GROUP BY region, category, sub_category ORDER BY profit;

-- B03 | Discount threshold and exposure / 折扣风险阈值与业务暴露
WITH discount_perf AS (
  SELECT CASE
    WHEN discount=0 THEN '0%'
    WHEN discount<=0.10 THEN '1-10%'
    WHEN discount<=0.20 THEN '11-20%'
    WHEN discount<=0.30 THEN '21-30%'
    WHEN discount<=0.50 THEN '31-50%'
    ELSE '>50%' END AS discount_band,
    CASE WHEN discount=0 THEN 1 WHEN discount<=0.10 THEN 2
         WHEN discount<=0.20 THEN 3 WHEN discount<=0.30 THEN 4
         WHEN discount<=0.50 THEN 5 ELSE 6 END AS band_order,
    sales, profit, order_id
  FROM orders_clean
)
SELECT discount_band, COUNT(*) AS line_items,
       COUNT(DISTINCT order_id) AS orders, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin
FROM discount_perf GROUP BY discount_band, band_order ORDER BY band_order;

-- B04 | Material and unprofitable intersections / 具有业务规模但仍亏损的交叉组合
SELECT region, category, sub_category, discount,
       ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(*) AS line_items
FROM orders_clean
GROUP BY region, category, sub_category, discount
HAVING SUM(sales)>=1000 AND SUM(profit)<0
ORDER BY profit;

-- B05 | State-level losses / 州级亏损定位
-- Filter before LIMIT to avoid hiding loss states / 先筛选亏损再 LIMIT，避免被盈利州掩盖。
SELECT region, state, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin
FROM orders_clean
GROUP BY region, state HAVING SUM(profit)<0
ORDER BY profit LIMIT 20;

-- B06 | Product losses / 产品级亏损清单；组合键用于保留源数据粒度
SELECT product_id, product_name, category, sub_category,
       ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(DISTINCT order_id) AS orders
FROM orders_clean
GROUP BY product_id, product_name, category, sub_category
HAVING SUM(profit)<0 ORDER BY profit LIMIT 20;

-- B07 | Customer value and concentration / 客户价值与销售集中度
WITH customer_value AS (
  SELECT customer_id, customer_name, segment, SUM(sales) AS sales,
         SUM(profit) AS profit, COUNT(DISTINCT order_id) AS orders
  FROM orders_clean GROUP BY customer_id, customer_name, segment
), ranked AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY sales DESC) AS sales_rank,
         SUM(sales) OVER () AS total_sales
  FROM customer_value
)
SELECT customer_id, customer_name, segment, ROUND(sales,2) AS sales,
       ROUND(sales/total_sales,4) AS sales_share, ROUND(profit,2) AS profit,
       ROUND(profit/NULLIF(sales,0),4) AS profit_margin, orders
FROM ranked WHERE sales_rank<=20 ORDER BY sales_rank;

-- B08 | Return rate by region / 区域退货率
-- Order-level denominator avoids line-item bias / 使用订单级分母，避免订单行重复造成偏差。
WITH order_region AS (
  SELECT DISTINCT order_id, region FROM orders_clean
)
SELECT o.region, COUNT(*) AS orders,
       SUM(r.order_id IS NOT NULL) AS returned_orders,
       ROUND(SUM(r.order_id IS NOT NULL)/COUNT(*),4) AS return_rate
FROM order_region o LEFT JOIN returns_clean r USING (order_id)
GROUP BY o.region ORDER BY return_rate DESC;

-- B09 | Shipping-mode context / 配送方式背景分析（仅描述，不作因果判断）
SELECT ship_mode, ROUND(AVG(DATEDIFF(ship_date,order_date)),2) AS avg_ship_days,
       COUNT(DISTINCT order_id) AS orders, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin
FROM orders_clean GROUP BY ship_mode ORDER BY avg_ship_days;
