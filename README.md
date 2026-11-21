# 🍽️ Swiggy Sales & Business Performance Analysis (SQL)

## 📌 Project Overview

This project focuses on analyzing Swiggy's food delivery business data using **Microsoft SQL Server** to uncover meaningful business insights related to sales performance, customer spending patterns, restaurant performance, cuisine preferences, and geographical trends.

The project involves end-to-end SQL analysis, starting with data cleaning and validation, followed by database design using a Star Schema, KPI development, and in-depth business analysis.

The primary objective is to transform raw food delivery data into a structured analytical database and generate insights that can support data-driven business decisions.

## 🎯 Business Objectives

- Ensure data accuracy and consistency through data cleaning and validation.
- Design an optimized relational database using Dimensional Modelling.
- Develop key business performance indicators (KPIs).
- Analyze revenue and order trends across different time periods.
- Identify top-performing cities, states, restaurants, and food categories.
- Understand customer spending patterns and food rating distributions.

## 🛠️ Tools & Technologies

- **Database:** Microsoft SQL Server
- **Query Language:** SQL
- **Database Design:** Star Schema (Dimensional Modelling)
- **Analysis:** Exploratory Data Analysis (EDA) using SQL

## 🧹 Project Workflow

### 1. Data Cleaning & Validation
- Performed NULL value checks across business-critical columns.
- Identified duplicate records using GROUP BY and HAVING clauses.
- Removed duplicate records using CTEs and ROW_NUMBER().
- Validated data consistency before loading it into the analytical database.

### 2. Database Design – Star Schema

Designed a Star Schema to organize the raw dataset into a structured analytical database.

**Dimension Tables:**
- `dim_date` – Date, year, month, quarter, day, and week.
- `dim_location` – State, city, and location.
- `dim_restaurant` – Restaurant information.
- `dim_category` – Food categories and cuisines.
- `dim_dish` – Dish information.

**Fact Table:**
- `fact_orders` – Contains order-level measures such as price, rating, rating count, and foreign keys connecting the dimension tables.

Implemented primary key and foreign key relationships to maintain referential integrity and enable efficient analytical queries.

### 3. KPI Development

Developed SQL queries to calculate the following key performance indicators:

- Total Orders
- Total Revenue (INR Million)
- Average Dish Price
- Average Rating

### 4. Business Analysis

Conducted in-depth analysis across multiple business dimensions.

**Time-Based Analysis**
- Monthly and quarterly order trends.
- Revenue performance across different months and quarters.
- Day-of-week order and revenue patterns.

**Geographical Analysis**
- Top 10 cities by order volume.
- Top and bottom-performing cities by revenue.
- Top 5 states by revenue.

**Restaurant & Food Performance**
- Top 20 restaurants by revenue.
- Most popular food categories by order volume.
- Top 50 most-ordered dishes.
- Cuisine performance based on order volume and average ratings.

**Customer Spending Analysis**
- Categorized orders into spending ranges:
  - Under ₹100
  - ₹100–₹199
  - ₹200–₹299
  - ₹300–₹499
  - ₹500+

- Analyzed order distribution across different price ranges.
- Examined dish rating distributions.

## 💡 Key SQL Concepts Applied

- Data Cleaning & Validation
- SELECT, WHERE, GROUP BY, HAVING
- INNER JOIN and Multi-table JOINs
- Common Table Expressions (CTEs)
- Window Functions (ROW_NUMBER)
- Aggregate Functions (SUM, AVG, COUNT)
- CASE Statements
- Subqueries
- Primary & Foreign Keys
- Dimensional Modelling
- Star Schema Design

## 📊 Business Value

This project demonstrates how SQL can be used beyond basic data retrieval to build structured analytical databases and solve practical business problems.

The analysis helps identify revenue patterns, geographical performance differences, popular food categories, restaurant contributions, and customer spending behaviour.

It also establishes a structured database foundation that can be extended for further business intelligence and dashboard development.

## 🚀 Learning Outcomes

Through this project, I gained practical experience in:

- Handling real-world data quality challenges.
- Designing relational databases using dimensional modelling.
- Implementing Star Schema architecture.
- Writing complex SQL queries for business analysis.
- Translating business requirements into analytical SQL queries.
- Developing KPIs and extracting actionable business insights.

---

**Project Name:** Swiggy Sales & Business Performance Analysis  
**Domain:** Food Delivery & E-commerce Analytics  
**Technology:** Microsoft SQL Server  
**Role:** Data Analyst Project
