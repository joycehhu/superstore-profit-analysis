# Data Dictionary | 数据字典

## Fact Table: `orders_clean`

| Field / 字段 | Type / role / 类型与角色 | Definition / 定义 |
|---|---|---|
| `row_id` | Primary key / 主键 | Unique order-line identifier / 唯一订单行标识 |
| `order_id` | Order dimension / 订单维度 | Order identifier / 订单编号；订单数使用 `COUNT(DISTINCT order_id)` |
| `order_date` | Date / 日期 | Order date / 下单日期 |
| `ship_date` | Date / 日期 | Shipping date / 发货日期 |
| `ship_mode` | Dimension / 维度 | Shipping service level / 配送服务级别 |
| `customer_id` | Customer key / 客户键 | Customer identifier / 客户编号 |
| `customer_name` | Dimension / 维度 | Customer name / 客户名称 |
| `segment` | Dimension / 维度 | Customer segment / 客户分群 |
| `country`, `state`, `city`, `region` | Geography / 地理维度 | Location hierarchy / 地理层级 |
| `product_id` | Product key component / 产品键组成 | Not strictly one-to-one with product name / 与产品名称并非严格一一对应 |
| `product_name` | Product key component / 产品键组成 | Use together with `product_id` / 与 `product_id` 组合使用 |
| `category`, `sub_category` | Product dimensions / 产品维度 | Product hierarchy / 产品层级 |
| `sales` | Measure / 度量 | Line-level sales amount / 订单行销售额 |
| `quantity` | Measure / 度量 | Units sold / 销售数量 |
| `discount` | Measure / 度量 | Decimal discount rate / 小数形式折扣率；`0.3 = 30%` |
| `profit` | Measure / 度量 | Line-level profit / 订单行利润 |
| `profit_margin` | Diagnostic field / 诊断字段 | Row-level `profit / sales` / 行级利润率；聚合时使用 `SUM(profit)/SUM(sales)` |

## Supporting Tables

| Table / 表 | Key / 键 | Use / 用途 |
|---|---|---|
| `returns_clean` | `order_id` | Identify returned orders / 识别退货订单 |
| `people_clean` | `region` | Map region to regional manager / 将区域映射至区域负责人 |

## Core Metric Definitions

| Metric / 指标         | Definition / 定义                                                       |
| ------------------- | --------------------------------------------------------------------- |
| Sales / 销售额         | `SUM(sales)`                                                          |
| Profit / 利润         | `SUM(profit)`                                                         |
| Profit Margin / 利润率 | `SUM(profit) / NULLIF(SUM(sales), 0)`                                 |
| Orders / 订单数        | `COUNT(DISTINCT order_id)`                                            |
| Customers / 客户数     | `COUNT(DISTINCT customer_id)`                                         |
| Return Rate / 退货率   | Returned distinct orders / distinct orders            退货去重订单数 ÷ 去重订单数 |
| Sales YoY / 销售同比    | `(Current Sales - Prior Sales) / Prior Sales`                         |
| Profit YoY / 利润同比   | `(Current Profit - Prior Profit) / Prior Profit`                      |
| Growth Gap / 增长差    | `Profit YoY - Sales YoY`                                              |
