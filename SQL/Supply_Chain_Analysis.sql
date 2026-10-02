-- ===========================================================================================================================================
-- SUPPLY CHAIN ANALYSIS 
-- ===========================================================================================================================================

CREATE DATABASE Supply_chain;
USE Supply_chain;

SELECT * FROM procurement;
SELECT * FROM supplier_master;
SELECT * FROM supplier_risk_rating;
SELECT * FROM product_master;
SELECT * FROM warehouse_master;
SELECT * FROM buyer_master;
SELECT * FROM quantity_log;
SELECT * FROM logistics_shipments;
SELECT * FROM carrier_master;
SELECT * FROM procurement_targets;
SELECT * FROM targets_long;

SHOW TABLES;

-- ==========================================
-- Q1. Monthly spend vs target 
-- ==========================================
SELECT
    t.Year,
    t.Month,
    t.Product_Category,
    t.Target_Spend_INR AS Target_Spend,
    SUM(q.Quantity * p.Actual_Unit_Price_INR) AS Actual_Spend,
    SUM(q.Quantity * p.Actual_Unit_Price_INR) - t.Target_Spend_INR AS Variance
FROM Targets_Long t
JOIN Procurement p
    ON YEAR(p.Order_Date) = t.Year
    AND MONTH(p.Order_Date) = t.Month_Num
JOIN Product_Master pm
    ON p.Product_ID = pm.Product_ID
    AND pm.Category = t.Product_Category
JOIN Quantity_Log q
    ON p.PO_Line_ID = q.PO_Line_ID
    AND q.Quantity_Type = 'Ordered'
WHERE p.Is_Cancelled = 'No'
GROUP BY
    t.Year,
    t.Month,
    t.Month_Num,
    t.Product_Category,
    t.Target_Spend_INR
ORDER BY
    t.Year,
    t.Month_Num,
    t.Product_Category;

-- ==========================================
-- Q2. Actual price above contract price
-- ==========================================
SELECT
    p.Supplier_ID,
    sm.Supplier_Name,
    pm.Category,
    COUNT(*) AS Affected_Lines,
    ROUND(AVG(p.Actual_Unit_Price_INR - p.Contract_Unit_Price_INR), 2) AS Avg_Price_Variance,
    ROUND(SUM(q.Quantity * (p.Actual_Unit_Price_INR - p.Contract_Unit_Price_INR)), 2) AS Total_Price_Variance
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID = sm.Supplier_ID
JOIN Product_Master pm
    ON p.Product_ID = pm.Product_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID = q.PO_Line_ID
    AND q.Quantity_Type = 'Ordered'
WHERE p.Is_Cancelled = 'No'
    AND p.Actual_Unit_Price_INR > p.Contract_Unit_Price_INR
GROUP BY
    p.Supplier_ID,
    sm.Supplier_Name,
    pm.Category
ORDER BY
    Total_Price_Variance DESC;
    
-- ==========================================
-- Q3. High-spend suppliers with weak performance
-- ==========================================
SELECT
    p.Supplier_ID,
    sm.Supplier_Name,
    ROUND(SUM(q.Quantity*p.Actual_Unit_Price_INR),2) AS Total_Spend,
    r.Risk_Level,
    r.Supplier_Rating,
    r.Quality_Score,
    r.Delivery_Score
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Supplier_Risk_Rating r
    ON p.Supplier_ID=r.Supplier_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
    AND q.Quantity_Type='Ordered'
WHERE p.Is_Cancelled='No'
GROUP BY
    p.Supplier_ID,
    sm.Supplier_Name,
    r.Risk_Level,
    r.Supplier_Rating,
    r.Quality_Score,
    r.Delivery_Score
ORDER BY Total_Spend DESC;


-- ==========================================
-- Q4A. Delivery reliability by supplier
-- ==========================================
SELECT
    p.Supplier_ID,
    sm.Supplier_Name,
    COUNT(*) AS Deliveries,
    SUM(CASE WHEN l.Actual_Delivery_Date<=p.Promised_Date THEN 1 ELSE 0 END) AS On_Time,
    SUM(CASE WHEN l.Actual_Delivery_Date>p.Promised_Date THEN 1 ELSE 0 END) AS Late,
    ROUND(100*AVG(CASE WHEN l.Actual_Delivery_Date<=p.Promised_Date THEN 1 ELSE 0 END),2) AS On_Time_Rate
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Logistics_Shipments l
    ON p.PO_Line_ID=l.PO_Line_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
GROUP BY
    p.Supplier_ID,
    sm.Supplier_Name
ORDER BY On_Time_Rate ASC;

-- ==========================================
-- Q4B. Carrier on-time rate vs SLA
-- ==========================================
SELECT
    l.Carrier_ID,
    c.Carrier_Name,
    COUNT(*) AS Deliveries,
    ROUND(100*AVG(CASE WHEN l.Actual_Delivery_Date<=p.Promised_Date THEN 1 ELSE 0 END),2) AS On_Time_Rate,
    ROUND(c.SLA_On_Time_Target*100,2) AS SLA_Target
FROM Logistics_Shipments l
JOIN Procurement p
    ON l.PO_Line_ID=p.PO_Line_ID
JOIN Carrier_Master c
    ON l.Carrier_ID=c.Carrier_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
GROUP BY
    l.Carrier_ID,
    c.Carrier_Name,
    c.SLA_On_Time_Target
ORDER BY On_Time_Rate ASC;

-- ==========================================
-- Q4C. Delivery reliability by region and mode
-- ==========================================
SELECT
    w.Region,
    l.Transport_Mode,
    COUNT(*) AS Deliveries,
    SUM(CASE WHEN l.Actual_Delivery_Date<=p.Promised_Date THEN 1 ELSE 0 END) AS On_Time,
    SUM(CASE WHEN l.Actual_Delivery_Date>p.Promised_Date THEN 1 ELSE 0 END) AS Late,
    ROUND(100*AVG(CASE WHEN l.Actual_Delivery_Date<=p.Promised_Date THEN 1 ELSE 0 END),2) AS On_Time_Rate
FROM Logistics_Shipments l
JOIN Procurement p
    ON l.PO_Line_ID=p.PO_Line_ID
JOIN Warehouse_Master w
    ON l.Destination_Warehouse_ID=w.Warehouse_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
GROUP BY
    w.Region,
    l.Transport_Mode
ORDER BY On_Time_Rate ASC;

-- ==========================================
-- Q5A. Freight cost and transit time by carrier
-- ==========================================
SELECT
    l.Carrier_ID,
    c.Carrier_Name,
    COUNT(*) AS Shipments,
    ROUND(SUM(l.Freight_Cost_INR),2) AS Total_Freight,
    ROUND(AVG(l.Freight_Cost_INR),2) AS Avg_Freight,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days
FROM Logistics_Shipments l
JOIN Procurement p
    ON l.PO_Line_ID=p.PO_Line_ID
JOIN Carrier_Master c
    ON l.Carrier_ID=c.Carrier_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
GROUP BY
    l.Carrier_ID,
    c.Carrier_Name
ORDER BY Total_Freight DESC;

-- ==========================================
-- Q5B. Freight cost and transit time by mode
-- ==========================================
SELECT
    l.Transport_Mode,
    COUNT(*) AS Shipments,
    ROUND(SUM(l.Freight_Cost_INR),2) AS Total_Freight,
    ROUND(AVG(l.Freight_Cost_INR),2) AS Avg_Freight,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days
FROM Logistics_Shipments l
JOIN Procurement p
    ON l.PO_Line_ID=p.PO_Line_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
GROUP BY
    l.Transport_Mode
ORDER BY Total_Freight DESC;

-- ==========================================
-- Q6. Rejection rate by category
-- ==========================================
SELECT
    pm.Category,
    SUM(CASE WHEN q.Quantity_Type='Ordered' THEN q.Quantity ELSE 0 END) AS Ordered_Qty,
    SUM(CASE WHEN q.Quantity_Type='Received' THEN q.Quantity ELSE 0 END) AS Received_Qty,
    SUM(CASE WHEN q.Quantity_Type='Rejected' THEN q.Quantity ELSE 0 END) AS Rejected_Qty,
    ROUND(100*SUM(CASE WHEN q.Quantity_Type='Rejected' THEN q.Quantity ELSE 0 END)/NULLIF(SUM(CASE WHEN q.Quantity_Type='Received' THEN q.Quantity ELSE 0 END)+
            SUM(CASE WHEN q.Quantity_Type='Rejected' THEN q.Quantity ELSE 0 END),0),2) AS Rejection_Rate
FROM Procurement p
JOIN Product_Master pm
    ON p.Product_ID=pm.Product_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
WHERE p.Is_Cancelled='No'
GROUP BY pm.Category
ORDER BY Rejection_Rate DESC;

-- ==========================================
-- Q7. Supplier spend and spend share
-- ==========================================
SELECT
    sm.Supplier_ID,
    sm.Supplier_Name,
    ROUND(SUM(q.Quantity*p.Actual_Unit_Price_INR),2) AS Supplier_Spend,
    ROUND(100*SUM(q.Quantity*p.Actual_Unit_Price_INR)/
        (	SELECT SUM(q2.Quantity*p2.Actual_Unit_Price_INR)
            FROM Procurement p2
            JOIN Quantity_Log q2
                ON p2.PO_Line_ID=q2.PO_Line_ID
            WHERE p2.Is_Cancelled='No'
                AND q2.Quantity_Type='Ordered'),2) AS Spend_Share_Pct
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
    AND q.Quantity_Type='Ordered'
WHERE p.Is_Cancelled='No'
GROUP BY
    sm.Supplier_ID,
    sm.Supplier_Name
ORDER BY Supplier_Spend DESC;

-- ==========================================
-- Q7B. Top 10 supplier spend
-- ==========================================
SELECT
    sm.Supplier_ID,
    sm.Supplier_Name,
    ROUND(SUM(q.Quantity*p.Actual_Unit_Price_INR),2) AS Supplier_Spend
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
    AND q.Quantity_Type='Ordered'
WHERE p.Is_Cancelled='No'
GROUP BY
    sm.Supplier_ID,
    sm.Supplier_Name
ORDER BY Supplier_Spend DESC
LIMIT 10;

-- ==========================================
-- Q8. Orders outside supplier contract dates
-- ==========================================
SELECT
    p.PO_Line_ID,
    p.PO_ID,
    p.Order_Date,
    p.Supplier_ID,
    sm.Supplier_Name,
    sm.Contract_Start,
    sm.Contract_End,
    ROUND(q.Quantity*p.Actual_Unit_Price_INR,2) AS Recorded_Value,
    ROUND(p.Actual_Unit_Price_INR-p.Contract_Unit_Price_INR,2) AS Unit_Price_Variance,
    ROUND(q.Quantity*(p.Actual_Unit_Price_INR-p.Contract_Unit_Price_INR),2) AS Total_Price_Variance
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
    AND q.Quantity_Type='Ordered'
WHERE p.Is_Cancelled='No'
    AND p.Order_Date NOT BETWEEN sm.Contract_Start AND sm.Contract_End
ORDER BY p.Order_Date;

-- ==========================================
-- Q8B. Summary of outside-contract orders
-- ==========================================
SELECT
    COUNT(*) AS Outside_Contract_Lines,
    ROUND(SUM(q.Quantity*p.Actual_Unit_Price_INR),2) AS Recorded_Value,
    ROUND(SUM(q.Quantity*(p.Actual_Unit_Price_INR-p.Contract_Unit_Price_INR)),2) AS Total_Price_Variance
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
    AND q.Quantity_Type='Ordered'
WHERE p.Is_Cancelled='No'
    AND p.Order_Date NOT BETWEEN sm.Contract_Start AND sm.Contract_End;

-- ==========================================
-- Q9. Purchase orders with mixed line statuses
-- ==========================================
SELECT
    p.PO_ID,
    COUNT(*) AS Line_Count,
    ROUND(SUM(q.Quantity*p.Actual_Unit_Price_INR),2) AS Recorded_Value,
    GROUP_CONCAT(DISTINCT p.PO_Status ORDER BY p.PO_Status SEPARATOR ', ') AS Statuses
FROM Procurement p
JOIN Quantity_Log q
    ON p.PO_Line_ID=q.PO_Line_ID
    AND q.Quantity_Type='Ordered'
WHERE p.PO_Has_Mixed_Line_Status='Yes'
GROUP BY p.PO_ID
ORDER BY Recorded_Value DESC;

-- ==========================================
-- Q10A. Overall late delivery delay
-- ==========================================
SELECT
    COUNT(*) AS Late_Deliveries,
    ROUND(AVG(DATEDIFF(l.Dispatch_Date,p.Order_Date)),2) AS Avg_Pre_Dispatch_Days,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,p.Promised_Date)),2) AS Avg_Delay_Days
FROM Procurement p
JOIN Logistics_Shipments l
    ON p.PO_Line_ID=l.PO_Line_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
    AND l.Actual_Delivery_Date>p.Promised_Date;

-- ==========================================
-- Q10B. Delivery delays by supplier
-- ==========================================
SELECT
    p.Supplier_ID,
    sm.Supplier_Name,
    COUNT(*) AS Late_Deliveries,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,p.Promised_Date)),2) AS Avg_Delay_Days,
    ROUND(AVG(DATEDIFF(l.Dispatch_Date,p.Order_Date)),2) AS Avg_Pre_Dispatch_Days,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days
FROM Procurement p
JOIN Supplier_Master sm
    ON p.Supplier_ID=sm.Supplier_ID
JOIN Logistics_Shipments l
    ON p.PO_Line_ID=l.PO_Line_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
    AND l.Actual_Delivery_Date>p.Promised_Date
GROUP BY
    p.Supplier_ID,
    sm.Supplier_Name
ORDER BY Avg_Delay_Days DESC;

-- ==========================================
-- Q10C. Delivery delays by carrier
-- ==========================================
SELECT
    l.Carrier_ID,
    c.Carrier_Name,
    COUNT(*) AS Late_Deliveries,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,p.Promised_Date)),2) AS Avg_Delay_Days,
    ROUND(AVG(DATEDIFF(l.Dispatch_Date,p.Order_Date)),2) AS Avg_Pre_Dispatch_Days,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days
FROM Procurement p
JOIN Logistics_Shipments l
    ON p.PO_Line_ID=l.PO_Line_ID
JOIN Carrier_Master c
    ON l.Carrier_ID=c.Carrier_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
    AND l.Actual_Delivery_Date>p.Promised_Date
GROUP BY
    l.Carrier_ID,
    c.Carrier_Name
ORDER BY Avg_Delay_Days DESC;

-- ==========================================
-- Q10D. Delivery delays by warehouse
-- ==========================================
SELECT
    w.Warehouse_ID,
    w.Warehouse_Name,
    COUNT(*) AS Late_Deliveries,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,p.Promised_Date)),2) AS Avg_Delay_Days,
    ROUND(AVG(DATEDIFF(l.Dispatch_Date,p.Order_Date)),2) AS Avg_Pre_Dispatch_Days,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days
FROM Procurement p
JOIN Logistics_Shipments l
    ON p.PO_Line_ID=l.PO_Line_ID
JOIN Warehouse_Master w
    ON l.Destination_Warehouse_ID=w.Warehouse_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
    AND l.Actual_Delivery_Date>p.Promised_Date
GROUP BY
    w.Warehouse_ID,
    w.Warehouse_Name
ORDER BY Avg_Delay_Days DESC;

-- ==========================================
-- Q11. Cost vs delivery performance
-- ==========================================
SELECT
    l.Carrier_ID,
    c.Carrier_Name,
    l.Transport_Mode,
    COUNT(*) AS Shipments,
    ROUND(100*AVG(CASE WHEN l.Actual_Delivery_Date<=p.Promised_Date THEN 1 ELSE 0 END),2) AS On_Time_Rate,
    ROUND(AVG(l.Freight_Cost_INR),2) AS Avg_Freight,
    ROUND(AVG(DATEDIFF(l.Actual_Delivery_Date,l.Dispatch_Date)),2) AS Avg_Transit_Days
FROM Logistics_Shipments l
JOIN Procurement p
    ON l.PO_Line_ID=p.PO_Line_ID
JOIN Carrier_Master c
    ON l.Carrier_ID=c.Carrier_ID
WHERE p.Is_Cancelled='No'
    AND l.Shipment_Status='Delivered'
GROUP BY
    l.Carrier_ID,
    c.Carrier_Name,
    l.Transport_Mode
ORDER BY
    On_Time_Rate DESC,
    Avg_Freight ASC;