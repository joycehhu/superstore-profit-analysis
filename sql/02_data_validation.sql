/*=============================================================================
  SUPERSTORE PORTFOLIO PROJECT | 02 DATA VALIDATION / 数据验证
  Purpose / 目的: Prove completeness, validity, uniqueness, and join integrity.
                 验证数据完整性、有效性、唯一性与关联完整性。
=============================================================================*/
USE superstore;

-- A. Row-count reconciliation / 原始表与清洗表行数核对
SELECT (SELECT COUNT(*) FROM orders) AS raw_rows,
       (SELECT COUNT(*) FROM orders_clean) AS clean_rows,
       (SELECT COUNT(*) FROM orders) - (SELECT COUNT(*) FROM orders_clean) AS variance;

-- B. Primary-key completeness and uniqueness / 主键完整性与唯一性
SELECT COUNT(*) AS total_rows, COUNT(row_id) AS non_null_ids,
       COUNT(DISTINCT row_id) AS unique_ids,
       COUNT(*) - COUNT(DISTINCT row_id) AS duplicate_ids
FROM orders_clean;

-- C. Critical-field completeness / 关键字段缺失检查
SELECT
  SUM(order_id IS NULL OR TRIM(order_id)='') AS missing_order_id,
  SUM(order_date IS NULL) AS missing_order_date,
  SUM(ship_date IS NULL) AS missing_ship_date,
  SUM(customer_id IS NULL OR TRIM(customer_id)='') AS missing_customer_id,
  SUM(product_id IS NULL OR TRIM(product_id)='') AS missing_product_id,
  SUM(category IS NULL OR TRIM(category)='') AS missing_category,
  SUM(sub_category IS NULL OR TRIM(sub_category)='') AS missing_sub_category,
  SUM(region IS NULL OR TRIM(region)='') AS missing_region,
  SUM(sales IS NULL) AS missing_sales,
  SUM(quantity IS NULL) AS missing_quantity,
  SUM(discount IS NULL) AS missing_discount,
  SUM(profit IS NULL) AS missing_profit
FROM orders_clean;

-- D. Date and numeric validity / 日期与数值范围有效性
SELECT MIN(order_date) AS first_order_date, MAX(order_date) AS last_order_date,
       MIN(ship_date) AS first_ship_date, MAX(ship_date) AS last_ship_date,
       SUM(ship_date < order_date) AS ship_before_order,
       SUM(sales <= 0) AS nonpositive_sales,
       SUM(quantity <= 0) AS nonpositive_quantity,
       SUM(discount < 0 OR discount > 1) AS invalid_discount
FROM orders_clean;

-- E. Dimension cardinality and accepted values / 维度基数与取值范围
SELECT 'segment' AS dimension_name, COUNT(DISTINCT segment) AS distinct_values FROM orders_clean
UNION ALL SELECT 'region', COUNT(DISTINCT region) FROM orders_clean
UNION ALL SELECT 'category', COUNT(DISTINCT category) FROM orders_clean
UNION ALL SELECT 'sub_category', COUNT(DISTINCT sub_category) FROM orders_clean
UNION ALL SELECT 'ship_mode', COUNT(DISTINCT ship_mode) FROM orders_clean;

-- F. Business-grain checks / 业务粒度检查
SELECT COUNT(*) AS order_lines, COUNT(DISTINCT order_id) AS orders,
       COUNT(DISTINCT customer_id) AS customers,
       COUNT(DISTINCT product_id) AS product_ids,
       COUNT(DISTINCT product_id, product_name) AS product_keys
FROM orders_clean;

-- Product IDs and names are not one-to-one / 产品 ID 与名称并非严格一一对应。
-- Use product_id + product_name in product analysis / 产品层分析使用组合键。
SELECT
  SUM(name_count > 1) AS product_ids_with_multiple_names
FROM (SELECT product_id, COUNT(DISTINCT product_name) AS name_count
      FROM orders_clean GROUP BY product_id) x;

SELECT
  SUM(id_count > 1) AS product_names_with_multiple_ids
FROM (SELECT product_name, COUNT(DISTINCT product_id) AS id_count
      FROM orders_clean GROUP BY product_name) x;

-- G. Generated-field reconciliation / 生成字段复核
SELECT COUNT(*) AS inconsistent_margin_rows
FROM orders_clean
WHERE sales <> 0 AND ABS(profit_margin - profit / sales) > 0.000001;

-- H. Referential integrity / 关联完整性检查
SELECT COUNT(*) AS orphan_return_orders
FROM returns_clean r LEFT JOIN orders_clean o USING (order_id)
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_manager_regions
FROM people_clean p
LEFT JOIN (SELECT DISTINCT region FROM orders_clean) o USING (region)
WHERE o.region IS NULL;
