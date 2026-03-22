Supply Chain & Logistics Performance Analytics
 Business Overview
In a globalized economy, supply chain efficiency is the difference between profitability and failure. This project simulates the role of a Data Analyst at OptiShop, a mid-sized logistics company.

The objective was to analyze 60,000+ rows of transactional, inventory, and procurement data to identify operational bottlenecks, reduce "dead stock" costs, and optimize supplier reliability.

Tech Stack
Database: SQL Server (T-SQL)

Advanced SQL Techniques: CTEs, Window Functions, Subqueries, Views, Joins.

Data Visualization: Power BI 

Key Concepts: Inventory Turnover, Lead Time Variance, Revenue Erosion, ABC Analysis.

Data Architecture (ERD)
The project utilizes a relational schema consisting of five normalized tables:

sales: Transactional data, revenue, and customer regions.

products: Catalog details, categories, and storage types.

inventory_daily: Daily snapshots of stock levels and reorder points.

purchase_orders: Procurement cycles, lead times, and carrier performance.

suppliers: Supplier reliability scores and geographic origin.

Key Insights & Business Impact
Through 30 targeted SQL queries, the following business-critical insights were uncovered:

1. Inventory Risk & "Ghost" Products
The Problem: High warehouse costs were eating into margins.

The Discovery: Identified over 150 "Dead Stock" products (Query #12) that haven't sold in 6 months, occupying valuable warehouse space.

The Solution: Recommended a clearance strategy to liquidate stagnant inventory and free up liquidity  in working capital.

2. Supplier Reliability & Lead Time Gaps
The Problem: Frequent stockouts were hurting customer satisfaction.

The Discovery: Analysis of purchase_orders (Query #14) revealed that 3 specific suppliers had a lead time variance of >10 days, significantly higher than their promised windows.

The Action: Proposed a Supplier Scorecard system to penalize late deliveries and shift volume to "Preferred Partners."

3. Revenue Erosion via Returns
The Problem: High Gross Revenue was masking underlying refund issues.

The Discovery: Calculated a Return Erosion Rate (Query #20) showing that the "Electronics" category lost 18% of its potential profit to returns due to "Fragile" storage handling errors.
