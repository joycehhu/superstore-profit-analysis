/*=============================================================================
  SUPERSTORE PORTFOLIO PROJECT | 01 DATA CLEANING / 数据清洗
  Environment / 环境 : MySQL 8.0+
  Purpose / 目的     : Create analysis-ready copies while preserving raw tables.
                       在保留原始表的前提下，创建可重复使用的分析表。
  Input / 输入       : orders, returns, people
  Output / 输出      : orders_clean, returns_clean, people_clean
=============================================================================*/

USE superstore;

-- 1. Rebuild clean tables / 重建清洗表
DROP TABLE IF EXISTS orders_clean;
CREATE TABLE orders_clean AS SELECT * FROM orders;

-- 2. Standardize Orders column names to snake_case / 将 Orders 字段名统一为 小写+下划线
ALTER TABLE orders_clean
  	RENAME COLUMN `Row ID` TO row_id,
  	RENAME COLUMN `Order ID` TO order_id,
  	RENAME COLUMN `Order Date` TO order_date,
  	RENAME COLUMN `Ship Date` TO ship_date,
  	RENAME COLUMN `Ship Mode` TO ship_mode,
  	RENAME COLUMN `Customer ID` TO customer_id,
  	RENAME COLUMN `Customer Name` TO customer_name,
  	RENAME COLUMN `Segment` TO segment,
  	RENAME COLUMN `Country/Region` TO country,
  	RENAME COLUMN `City` TO city,
  	RENAME COLUMN `State/Province` TO state,
  	RENAME COLUMN `Postal Code` TO postal_code,
  	RENAME COLUMN `Region` TO region,
  	RENAME COLUMN `Product ID` TO product_id,
  	RENAME COLUMN `Category` TO category,
  	RENAME COLUMN `Sub-Category` TO sub_category,
  	RENAME COLUMN `Product Name` TO product_name,
  	RENAME COLUMN `Sales` TO sales,
  	RENAME COLUMN `Quantity` TO quantity,
  	RENAME COLUMN `Discount` TO discount,
  	RENAME COLUMN `Profit` TO profit;

-- 3. Apply analysis-ready data types and constraints / 设置适合分析的数据类型与约束
ALTER TABLE orders_clean
  	MODIFY row_id INT NOT NULL,
  	MODIFY order_date DATE NOT NULL,
  	MODIFY ship_date DATE NOT NULL,
  	MODIFY sales DECIMAL(12,4) NOT NULL,
  	MODIFY quantity INT NOT NULL,
  	MODIFY discount DECIMAL(5,2) NOT NULL,
  	MODIFY profit DECIMAL(12,4) NOT NULL,
  	ADD PRIMARY KEY (row_id);

-- Row-level diagnostic field only / 仅用于行级诊断。
-- Aggregate margin must use SUM(profit)/SUM(sales) / 聚合利润率必须使用 SUM(profit)/SUM(sales)。
ALTER TABLE orders_clean
  	ADD COLUMN profit_margin DECIMAL(14,8)
  	GENERATED ALWAYS AS (profit / NULLIF(sales, 0)) STORED;

-- 4. Standardize Returns / 标准化退货表
DROP TABLE IF EXISTS returns_clean;
CREATE TABLE returns_clean AS SELECT * FROM returns;
ALTER TABLE returns_clean
  	RENAME COLUMN `Order ID` TO order_id,
  	RENAME COLUMN `Returned` TO returned,
  	MODIFY order_id VARCHAR(50) NOT NULL,
  	ADD PRIMARY KEY (order_id);

-- 5. Standardize People / 标准化区域负责人表
DROP TABLE IF EXISTS people_clean;
CREATE TABLE people_clean AS SELECT * FROM people;
ALTER TABLE people_clean
  	RENAME COLUMN `Regional Manager` TO regional_manager,
  	RENAME COLUMN `Region` TO region,
  	MODIFY region VARCHAR(20) NOT NULL,
  	ADD PRIMARY KEY (region);

-- 6. Completion check / 完成性检查
SELECT 'orders_clean' AS table_name, COUNT(*) AS row_count FROM orders_clean
UNION ALL SELECT 'returns_clean', COUNT(*) FROM returns_clean
UNION ALL SELECT 'people_clean', COUNT(*) FROM people_clean;

