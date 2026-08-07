/*=============================================================================
  SUPERSTORE PORTFOLIO PROJECT | 03 EXPLORATORY ANALYSIS / 探索性分析
  Question / 核心问题: Are sales and profit moving together, and where do they diverge?
                       销售与利润是否同步变化？差异主要出现在哪里？
=============================================================================*/
USE superstore;

-- E01 | Portfolio KPI baseline / 整体经营 KPI 基线
SELECT ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(DISTINCT order_id) AS orders,
       COUNT(DISTINCT customer_id) AS customers, SUM(quantity) AS quantity
FROM orders_clean;

-- E02 | Annual performance and YoY synchronization / 年度表现与销售—利润同比同步性
WITH annual AS (
  SELECT YEAR(order_date) AS order_year, SUM(sales) AS sales,
         SUM(profit) AS profit, COUNT(DISTINCT order_id) AS orders
  FROM orders_clean GROUP BY YEAR(order_date)
), compared AS (
  SELECT *, LAG(sales) OVER (ORDER BY order_year) AS prior_sales,
            LAG(profit) OVER (ORDER BY order_year) AS prior_profit
  FROM annual
)
SELECT order_year, ROUND(sales,2) AS sales, ROUND(profit,2) AS profit,
       ROUND(profit/NULLIF(sales,0),4) AS profit_margin, orders,
       ROUND((sales-prior_sales)/NULLIF(prior_sales,0),4) AS sales_yoy,
       ROUND((profit-prior_profit)/NULLIF(prior_profit,0),4) AS profit_yoy,
       ROUND((profit-prior_profit)/NULLIF(prior_profit,0)
            -(sales-prior_sales)/NULLIF(prior_sales,0),4) AS growth_gap
FROM compared ORDER BY order_year;

-- E03 | Monthly trend for seasonality and outliers / 月度趋势、季节性与异常月份识别
SELECT DATE_FORMAT(order_date,'%Y-%m') AS order_month,
       ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(DISTINCT order_id) AS orders
FROM orders_clean
GROUP BY DATE_FORMAT(order_date,'%Y-%m') ORDER BY order_month;

-- E04 | Category contribution: scale vs. profit quality / 品类规模与利润质量对比
WITH category_perf AS (
  SELECT category, SUM(sales) AS sales, SUM(profit) AS profit,
         COUNT(DISTINCT order_id) AS orders
  FROM orders_clean GROUP BY category
)
SELECT category, ROUND(sales,2) AS sales,
       ROUND(sales/SUM(sales) OVER (),4) AS sales_share,
       ROUND(profit,2) AS profit,
       ROUND(profit/SUM(profit) OVER (),4) AS profit_share,
       ROUND(profit/NULLIF(sales,0),4) AS profit_margin, orders
FROM category_perf ORDER BY sales DESC;

-- E05 | Region contribution / 区域贡献与盈利质量
WITH region_perf AS (
  SELECT region, SUM(sales) AS sales, SUM(profit) AS profit,
         COUNT(DISTINCT order_id) AS orders
  FROM orders_clean GROUP BY region
)
SELECT region, ROUND(sales,2) AS sales,
       ROUND(sales/SUM(sales) OVER (),4) AS sales_share,
       ROUND(profit,2) AS profit,
       ROUND(profit/SUM(profit) OVER (),4) AS profit_share,
       ROUND(profit/NULLIF(sales,0),4) AS profit_margin, orders
FROM region_perf ORDER BY sales DESC;

-- E06 | Customer segment baseline / 客户分群经营基线
SELECT segment, ROUND(SUM(sales),2) AS sales, ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin,
       COUNT(DISTINCT order_id) AS orders, COUNT(DISTINCT customer_id) AS customers
FROM orders_clean GROUP BY segment ORDER BY sales DESC;

-- E07 | Discount baseline / 折扣基线；进一步业务诊断见 04 文件
SELECT discount, COUNT(*) AS line_items, ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/NULLIF(SUM(sales),0),4) AS profit_margin
FROM orders_clean GROUP BY discount ORDER BY discount;
