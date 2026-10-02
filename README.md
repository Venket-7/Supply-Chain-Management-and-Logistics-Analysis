# Supply Chain Management & Logistics Analysis

## 📊 Project Overview

This project analyzes procurement, supplier performance, logistics, delivery reliability, freight cost, and procurement target variance for a supply chain operation.

The analysis combines **Excel, MySQL, Power BI, and Python** to build an end-to-end data analytics workflow.

The project focuses on identifying procurement cost variances, supplier risks, delivery delays, freight cost patterns, product rejection rates, contract compliance issues, and carrier performance.

---

## 🎯 Business Problem

Supply chain teams need better visibility into procurement spending, supplier performance, delivery reliability, and logistics costs.

This project addresses key business questions such as:

- Which months and product categories are above or below procurement spend targets?
- Which suppliers or categories have actual prices above contracted prices?
- Which high-spend suppliers have weak delivery, quality, or risk scores?
- Which suppliers, carriers, regions, or transport modes have the most late deliveries?
- Which carriers and transport modes have the highest freight costs?
- Which product categories have the highest rejection rates?
- How concentrated is procurement spend among suppliers?
- Which purchase orders were placed outside supplier contract dates?
- Which purchase orders contain mixed line statuses?
- Are delivery delays occurring before dispatch or during transit?
- Which carriers and transport modes have different cost and delivery performance?

---

## 📌 Project Objectives

1. Analyze procurement spend against monthly and category targets.
2. Identify purchase-price variance between actual and contracted prices.
3. Evaluate supplier spend, risk, quality, and delivery performance.
4. Measure supplier and carrier on-time delivery performance.
5. Analyze freight cost and transit time.
6. Identify product categories with high rejection rates.
7. Measure supplier spend concentration and top supplier contribution.
8. Detect procurement orders outside supplier contract periods.
9. Analyze purchase orders with mixed line statuses.
10. Identify the main sources of delivery delays.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| Excel | Data preparation and source dataset |
| Python | Importing Excel worksheets into MySQL |
| MySQL | Data storage and SQL analysis |
| Power BI | Dashboard and business reporting |
| GitHub | Project version control and portfolio |


---

## 📂 Project Structure

```text
Supply_Chain_Management_and_Logistics_Analysis/
│
├── Dashboard/
│   └── Supply_chain_analysis.pbix
|   └──Images/
|      ├── Supply chain Analytics.png
|      ├── Supplier & Procurement Performance.png
|      └── Logistics & Delivery Performance.png
│
├── Dataset/
│   ├── Supply_Chain_Procurement.xlsx
│   └── Supply_Chain_Procurement_Cleaned.xlsx
│
├── Documentation/
│   ├── Business_Question.txt
│   └── Supply_Chain_Dashboard_Overview.txt
|   └── Business_Insights.pdf
│
├── SQL/
│   └── Supply_Chain_Analysis.sql
│
├── gitignore
└── README.md
```

---

## 🗂️ Dataset

The cleaned workbook contains the following worksheets:

- Procurement
- Supplier_Master
- Supplier_Risk_Rating
- Product_Master
- Warehouse_Master
- Buyer_Master
- Quantity_Log
- Logistics_Shipments
- Carrier_Master
- Procurement_Targets
- Targets_Long

The workbook is structured around procurement transactions, supplier information, product details, warehouse information, quantity records, shipment records, carrier details, and procurement targets.

---

## 🔍 Business Analysis

### 1. Procurement Spend Analysis

Analyzes actual procurement spend against target spend by month and product category.

Key metric:

**Variance = Actual Spend - Target Spend**

### 2. Purchase Price Variance

Identifies suppliers and product categories where the actual unit price is higher than the contracted unit price.

### 3. Supplier Performance & Risk

Combines procurement spend with supplier risk, rating, quality, and delivery scores.

### 4. Delivery Reliability

Measures on-time and late deliveries across:

- Suppliers
- Carriers
- Regions
- Transport modes

Carrier performance is also compared with the carrier's OTD SLA target.

### 5. Freight & Transit Analysis

Analyzes:

- Total freight cost
- Average freight cost
- Average transit time
- Carrier performance
- Transport mode performance

### 6. Product Rejection Analysis

Calculates ordered, received, rejected quantities and rejection rates by product category.

### 7. Supplier Spend Concentration

Measures supplier-level procurement spend and identifies the contribution of the top suppliers.

### 8. Contract Compliance

Identifies purchase order lines created outside the supplier contract start and end dates and measures their recorded value and price variance.

### 9. Purchase Order Status Analysis

Identifies purchase orders containing mixed line statuses and measures the affected line count and recorded value.

### 10. Delivery Delay Analysis

Separates delays into:

- Pre-dispatch delay
- Transit delay
- Overall delivery delay

The analysis is performed by supplier, carrier, and warehouse.

---

## 📊 Power BI Dashboard

The Power BI dashboard is organized into three main pages.

### Dashboard Preview

#### Page 1 — Supply Chain Analytics

![Supply Chain Analytics](Dashboard/Images/Supply%20chain%20Analytics.png)

#### Page 2 — Supplier & Procurement Performance

![Supplier & Procurement Performance](Dashboard/Images/Supplier%20%26%20Procurement%20Performance.png)

#### Page 3 — Logistics & Delivery Performance

![Logistics & Delivery Performance](Dashboard/Images/Logistics%20%26%20Delivery%20Performance.png)

### Page 1 — Overview

Focuses on:

- Procurement spend vs target
- Category variance
- PO status mix
- Supplier risk and spend
- Delivery delays

### Page 2 — Supplier & Procurement

Focuses on:

- Purchase-price variance
- Supplier spend
- Supplier performance
- Supplier risk
- PPV trend

### Page 3 — Logistics & Delivery

Focuses on:

- Carrier OTD performance
- Carrier SLA comparison
- Freight cost
- Transport mode cost
- Transit time
- Monthly OTD trend

---

## 🧮 Key KPIs

- Total Procurement Spend
- Target Spend
- Spend Variance
- Purchase Price Variance
- Supplier Spend
- On-Time Delivery Rate
- Late Delivery Count
- Freight Cost
- Average Transit Time
- Rejection Rate
- Supplier Risk Score
- Carrier SLA Performance

---

## 💡 Key Business Questions

The SQL analysis answers 11 major business questions covering procurement, supplier management, logistics, cost, quality, contract compliance, and delivery performance.

The detailed questions are available in:

```text
Documentation/Business_Question.txt
```

---

## 🚀 How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/Venket-7/Supply-Chain-Management-and-Logistics-Analysis.git
```

### 2. Open the SQL Project

Open MySQL Workbench and execute:

```text
SQL/Supply_Chain_Analysis.sql
```

### 3. Open the Dashboard

Open:

```text
Dashboard/Supply_chain_analysis.pbix
```

### 4. Review the Dataset

The cleaned Excel workbook is available under:

```text
Dataset/Supply_Chain_Procurement_Cleaned.xlsx
```

---

## 📈 Project Workflow

```text
Excel Dataset
     ↓
Data Cleaning
     ↓
MySQL Database
     ↓
SQL Business Analysis
     ↓
Power BI Dashboard
     ↓
Business Insights
```

---

## 📁 Documentation

Project documentation includes:

- Business Questions
- Dashboard Overview
- Business Insights

These documents explain the analytical objectives and dashboard focus.

---

## 👨‍💻 Author

**Venket Ramana R S**

