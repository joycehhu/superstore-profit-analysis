# Superstore Sales & Profit Quality Analysis

A business-oriented data analytics project using **MySQL and Tableau** to investigate why sales growth does not always lead to healthy profit growth.

一个基于 MySQL 与 Tableau的业务数据分析项目，通过数据清洗、数据验证、探索分析、业务分析与可视化，分析销售增长背后的利润质量问题，并提出业务优化方向。

## Dashboard Preview



## Project Background \| 项目背景

Management observed that sales growth and profit growth were not always
aligned.

This project simulates a business scenario where management wants to
understand:

-   Whether revenue growth creates sustainable profitability
-   Which categories and regions affect profit performance
-   How discount strategies influence profitability

本项目模拟企业经营分析场景：

管理层发现销售额增长并不一定带来利润同步增长，因此希望通过数据分析回答：

-   销售增长是否带来健康盈利？
-   哪些品类和区域影响利润表现？
-   折扣策略是否影响利润质量？

## Tools

- MySQL 8.0
- DBeaver
- Tableau Public
- Excel

## Project Workflow

    Data Source
        ↓
    Data Cleaning
        ↓
    Data Validation
        ↓
    Exploratory Analysis
        ↓
    Business Analysis
        ↓
    Dashboard & Recommendations

## Key Findings \| 核心发现

### 1. Overall Business Performance

-   Sales: **\$2.33M**
-   Profit: **\$292.30K**
-   Profit Margin: **12.56%**
-   Orders: **5,111**
-   Customers: **804**

The business is profitable overall, but profitability varies
significantly across different dimensions.

整体业务保持盈利，但不同品类、区域和折扣策略之间存在明显盈利差异。

### 2. Sales Growth Does Not Equal Profit Growth

Revenue changes alone cannot represent business health.

The analysis compares sales, profit and profit margin together to
evaluate business quality.

销售额变化不能单独代表经营质量，需要结合利润和利润率进行综合判断。

### 3. Furniture Profitability Issue

Furniture generated high sales contribution but relatively weak
profitability.

-   Sales contribution: **32.44%**
-   Profit contribution: **6.75%**
-   Profit Margin: **2.61%**

家具品类贡献较高销售额，但利润率明显偏低，是重点优化方向。

### 4. Regional Profitability Risk

Central region showed weaker profitability compared with other regions.

Further drill-down analysis identified category-level profitability
issues.

Central区域盈利表现较弱，需要进一步关注其品类结构和利润来源。

### 5. Discount Impact

High discount levels require careful evaluation because aggressive
discounting may reduce profitability.

高折扣策略可能降低盈利能力，需要结合品类和产品进行精细化管理。

## Analysis Scope \| 分析范围

### SQL Analysis

The SQL analysis includes:

-   Data cleaning and standardization
-   Data validation
-   KPI calculation
-   Trend analysis
-   Category analysis
-   Regional analysis
-   Customer analysis
-   Discount impact analysis
-   Loss-making product identification

Detailed SQL scripts are available in the `/sql` folder.

SQL详细分析脚本存放于 `/sql` 文件夹，包括：

-   数据清洗与字段标准化
-   数据验证
-   核心指标计算
-   趋势分析
-   品类分析
-   区域分析
-   客户分析
-   折扣影响分析
-   亏损产品识别

## Tableau Dashboard \| Tableau可视化仪表板

The dashboard contains:

### Executive Overview

-   Business KPI overview
-   Sales and profit trends
-   Performance comparison

### Profit Analysis

-   Category profitability
-   Regional performance
-   Discount impact
-   Loss-making products

Dashboard file is available in the `/tableau` folder.

仪表板文件存放于 `/tableau` 文件夹。

## Business Recommendations \| 业务建议

1.  Review high discount strategies, especially for low-margin
    categories.

    审查高折扣策略，尤其关注低利润率品类。

2.  Improve profitability management for Central region and Furniture
    category.

    优化Central区域及Furniture品类的盈利管理。

3.  Monitor products with high sales but low or negative profit.

    持续关注高销售额但低利润或亏损产品。

4.  Evaluate business performance using revenue, profit and margin
    together.

    综合销售额、利润和利润率评价经营表现。

## Limitations \| 项目限制

This analysis is based on the Superstore dataset.

The dataset does not include:

-   Procurement cost
-   Inventory information
-   Promotion details
-   Customer contract information

Therefore, findings indicate business patterns rather than direct causal
relationships.

本项目基于Superstore公开数据集进行分析。

由于数据集中缺少：

-   采购成本
-   库存信息
-   促销活动信息
-   客户合同信息

因此，本项目分析结果主要用于发现业务规律与潜在问题，不代表严格的因果关系。

## Repository Structure \| 项目结构

    superstore-profit-analysis

    ├── README.md
    ├── data
    │   └── sample_superstore.csv
    │
    ├── sql
    │   ├── 01_data_cleaning.sql
    │   ├── 02_data_validation.sql
    │   ├── 03_exploratory_analysis.sql
    │   └── 04_business_analysis.sql
    │
    ├── tableau
    │   └── superstore_dashboard.twbx
    │
    ├── docs
    │   ├── DATA_DICTIONARY.md
    │   ├── Superstore_Project_Report_EN.pdf
    │   ├── Superstore_Project_Report_CN.pdf
    │
    └── images
        ├── dashboard.png
        ├── category_contribution.png
        └── regional_profitability.png
