-- =====================================
-- Task 1 Create Database and Table
-- =====================================

CREATE DATABASE churn_db;
USE churn_db;

CREATE TABLE customer_churn (
    customerID VARCHAR(20),
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(30),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(30),
    OnlineBackup VARCHAR(30),
    DeviceProtection VARCHAR(30),
    TechSupport VARCHAR(30),
    StreamingTV VARCHAR(30),
    StreamingMovies VARCHAR(30),
    Contract VARCHAR(30),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    Churn VARCHAR(5)
);

-- =====================================
-- Import Data 
-- =====================================
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Telco_Customer_Churn.csv'
INTO TABLE customer_churn
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
-- =====================================
-- Check Data 
-- =====================================
SELECT COUNT(*) FROM customer_churn;
-- =====================================
-- SQL Analysis Task 1: KPI Dashboard 
-- =====================================
CREATE TABLE executive_kpi as 
SELECT
    COUNT(DISTINCT customerID) AS Total_Customers,

    SUM(CASE
        WHEN Churn = 'Yes' THEN 1
        ELSE 0
    END) AS Churned_Customers,

    SUM(CASE
        WHEN Churn = 'No' THEN 1
        ELSE 0
    END) AS Retained_Customers,

    ROUND(
        SUM(CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END) * 100.0
        / COUNT(DISTINCT customerID),
        2
    ) AS Overall_Churn_Rate,

    ROUND(SUM(MonthlyCharges), 2) AS Total_Monthly_Revenue,

    ROUND(
        SUM(CASE
            WHEN Churn = 'Yes' THEN MonthlyCharges
            ELSE 0
        END),
        2
    ) AS Monthly_Revenue_Lost

FROM customer_churn;

-- =====================================
-- Task 2: Customer Segmentation: 
-- churn By Contract
-- =====================================
CREATE TABLE Churn_By_Contract as
SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY Contract
ORDER BY churn_rate DESC;
-- =====================================
-- Churn By Internet Service 
-- =====================================
  CREATE TABLE Churn_By_Internet_Service as
  SELECT
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY InternetService
ORDER BY churn_rate DESC;
-- =====================================
-- Payment Method 
-- =====================================
 CREATE TABLE Churn_By_Payment_Method as
 SELECT
   PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY PaymentMethod
ORDER BY churn_rate DESC;

-- =====================================
-- Senior Citizen Status
-- =====================================
 CREATE TABLE Churn_By_Senior_Citizen as
 SELECT
   SeniorCitizen,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY SeniorCitizen
ORDER BY churn_rate DESC;

-- =====================================
-- Task 3 Tenure and Customer Lifecycle Analysis
-- =====================================
  SELECT
	LifeCycle,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate,
    Round(Avg(MonthlyCharges),2) as average_monthly_charges 
    From (
			Select
           Churn,
			MonthlyCharges,
            CASE
				When tenure BETWEEN 0 AND 12
                Then 'New Customers'
                When tenure BETWEEN 13 AND 24
                Then 'Early Stage Customers'
                When tenure BETWEEN 25 AND 48
                Then 'Established Customers'
                When tenure BETWEEN 49 AND 72
                Then 'Loyal Customers'
                ELSE 'Error'
			End As LifeCycle
		From customer_churn
	)t
GROUP BY LifeCycle
ORDER BY
    CASE LifeCycle
        WHEN 'New Customers' THEN 1
        WHEN 'Early Stage Customers' THEN 2
        WHEN 'Established Customers' THEN 3
        WHEN 'Loyal Customers' THEN 4
        ELSE 5
    END;
    
-- =====================================
-- Create View customer_churn_enriched
-- =====================================    
CREATE VIEW customer_churn_enriched AS
SELECT
    *,
    CASE
        WHEN tenure <= 12 THEN 'New Customers'
        WHEN tenure <= 24 THEN 'Early Stage Customers'
        WHEN tenure <= 48 THEN 'Established Customers'
        ELSE 'Loyal Customers'
    END AS LifeCycle
FROM customer_churn;


-- =====================================
-- Task 4 Service Feature Analysis
-- Churn By Online Security
-- =====================================
SELECT
    OnlineSecurity,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY OnlineSecurity
ORDER BY churn_rate DESC;

-- =====================================
-- Churn By TechSupport
-- =====================================
SELECT
    TechSupport,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY TechSupport
ORDER BY churn_rate DESC;

-- =====================================
-- Churn By OnlineBackup
-- =====================================
    SELECT
    OnlineBackup,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY OnlineBackup
ORDER BY churn_rate DESC;

-- =====================================
-- Churn By DeviceProtection
-- =====================================
    SELECT
   DeviceProtection,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY DeviceProtection
ORDER BY churn_rate DESC;

-- =====================================
-- Churn By StreamingTV
-- =====================================
SELECT
   StreamingTV,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY StreamingTV
ORDER BY churn_rate DESC;

-- =====================================
-- Churn By StreamingMovies
-- =====================================
SELECT
   StreamingMovies,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY StreamingMovies
ORDER BY churn_rate DESC;

-- =====================================
-- Top 3 Churn Risk Factors
-- 1. Customers without Online Security had significantly higher churn rates.
-- 2. Customers without Tech Support experienced substantially higher churn.
-- 3. Customers without Device Protection were more likely to leave the company

-- Top 3 Retention Factors 
-- 1.Customers with Online Security showed stronger retention behavior.
-- 2.Customers with Tech Support had one of the lowest churn rates among service groups.
-- 3.Customers with Device Protection were more likely to remain customers.
-- =====================================

-- =====================================
-- Task 5 Revenue Impact by LifeCycle
-- =====================================

SELECT
    LifeCycle,

    ROUND(SUM(MonthlyCharges),2) AS total_monthly_revenue,

    ROUND(
        SUM(
            CASE
                WHEN Churn = 'Yes'
                THEN MonthlyCharges
                ELSE 0
            END
        ),
        2
    ) AS revenue_lost,

    ROUND(
        SUM(
            CASE
                WHEN Churn = 'Yes'
                THEN MonthlyCharges
                ELSE 0
            END
        ) * 100.0
        / SUM(MonthlyCharges),
        2
    ) AS revenue_loss_rate

FROM customer_churn_enriched
GROUP BY LifeCycle
ORDER BY revenue_loss_rate DESC;

