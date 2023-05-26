-- Checking for dupes/nulls in IDs:
SELECT COUNT(DISTINCT(Customer_ID)) as total
FROM dbo.telecom_customer_churn 

SELECT customer_id
FROM telecom_customer_churn
WHERE customer_id = 'NULL'

-- pct of customers churned + total revenue lost from churn:
SELECT Customer_Status, 
COUNT(Customer_Status) as count,
ROUND(COUNT(Customer_Status) * 100.0 / SUM(COUNT(Customer_Status)) OVER(), 1) as count_pct,
ROUND((SUM(Total_Revenue) * 100.0) / SUM(SUM(Total_Revenue)) OVER(), 1) as rev_percentage
FROM telecom_customer_churn
GROUP BY Customer_Status

-- Duration of churned customers' subscription: 
SELECT 
    CASE WHEN Tenure_in_Months <= 6 THEN '6 months'
         WHEN Tenure_in_Months <= 12 THEN '1 year'
         WHEN Tenure_in_Months <= 24 THEN '1-2 years'
         ELSE '>2 years'
    END as Tenure,
    ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) as churn_percentage
FROM dbo.telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY   
    CASE WHEN Tenure_in_Months <= 6 THEN '6 months'
         WHEN Tenure_in_Months <= 12 THEN '1 year'
         WHEN Tenure_in_Months <= 24 THEN '1-2 years'
         ELSE '>2 years'
    END
ORDER BY churn_percentage DESC

-- Average Tenure
SELECT AVG(Tenure_in_Months) as Average_Tenure
FROM telecom_customer_churn

-- the biggest percentage of churns came from:
SELECT TOP 5 City,
    COUNT(Customer_ID) as churned_customers,
    COUNT(CASE WHEN Customer_Status = 'Churned' THEN Customer_ID ELSE NULL END) * 100.0 / COUNT(Customer_ID)
    as rate_churned
FROM dbo.telecom_customer_churn
GROUP BY city 
HAVING COUNT(Customer_ID) > 30 
AND
(COUNT(CASE WHEN Customer_Status = 'Churned' THEN Customer_ID ELSE NULL END) * 100.0) / COUNT(Customer_ID) > 0
ORDER BY rate_churned DESC

-- reasons for the customers leaving and how much was lost bc of that:
SELECT TOP 5 Churn_Category,
    ROUND(SUM(Total_Revenue), 0) as churned_revenue,
    ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) as churn_percentage
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY Churn_Category
ORDER BY churn_percentage DESC

-- getting more concrete reasons:
SELECT TOP 5 Churn_Reason, 
       Churn_Category,
       ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) as churn_percentage
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY Churn_Reason, Churn_Category
ORDER BY churn_percentage DESC

-- majority said competitors; looking at competing offers:
SELECT TOP 5 Offer,
       ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) as churned_pct 
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY offer
ORDER BY churned_pct DESC

--other plausible reasons (internet):
SELECT TOP 5 Internet_Type,
        COUNT(Customer_ID) as churned,
        ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) as churned_pct
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY Internet_Type
ORDER BY churned_pct DESC

-- comparing internet to competitor:
SELECT Internet_Type,
       Churn_Category,
       ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) AS churn_percentage 
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned' AND Churn_Category = 'Competitor'
GROUP BY Internet_Type, Churn_Category
ORDER BY churn_percentage DESC

-- contract churned customers were on:
SELECT contract,
       COUNT(Customer_ID) as churned,
       ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(), 1) as churned_pct
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY contract

-- SELECT TOP 5 Gender, Age,
--        COUNT(Age) as amount
-- FROM telecom_customer_churn
-- WHERE Customer_Status = 'Churned'
-- GROUP BY gender, age
-- ORDER BY amount DESC 

-- Married or not:
SELECT COUNT(Married) AS Married_Churn,
       ROUND((COUNT(Married)) * 100.0 / SUM(COUNT(Married)) OVER(), 1) AS pct
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned' 
GROUP BY Married

--kiddos
SELECT COUNT(Number_Of_Dependents) AS dependents,
       ROUND((COUNT(Number_Of_Dependents)) * 100.0 / SUM(COUNT(Number_Of_Dependents)) OVER(), 1) as pct 
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned' 
GROUP BY Number_Of_Dependents

-- age spread
SELECT Gender,
        SUM(CASE WHEN age < 18 THEN 1 ELSE 0 END) AS [Under 18],
        SUM(CASE WHEN age BETWEEN 18 AND 20 THEN 1 ELSE 0 END) AS [18-20],
        SUM(CASE WHEN age BETWEEN 21 AND 30 THEN 1 ELSE 0 END) AS [21-30],
        SUM(CASE WHEN age BETWEEN 31 AND 40 THEN 1 ELSE 0 END) AS [31-40],
        SUM(CASE WHEN age BETWEEN 41 AND 50 THEN 1 ELSE 0 END) AS [41-50],
        SUM(CASE WHEN age BETWEEN 51 AND 60 THEN 1 ELSE 0 END) AS [51-60],
        SUM(CASE WHEN age BETWEEN 61 AND 70 THEN 1 ELSE 0 END) AS [61-70],
        SUM(CASE WHEN age > 71 THEN 1 ELSE 0 END) AS [70+]
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned'
GROUP BY Gender