-- =====================================================
-- Banking Fraud Analytics - Business SQL Queries
-- Author: Prajwal Phalke
-- =====================================================

-- =====================================================
-- Q1. Total Transactions
-- Business Question:
-- How many transactions were processed in 2025?
-- =====================================================

SELECT COUNT(*) AS total_transactions
FROM bank_transactions;


-- =====================================================
-- Q2. Total Revenue
-- Business Question:
-- What is the total transaction revenue?
-- =====================================================

SELECT ROUND(SUM(amount), 2) AS total_revenue
FROM bank_transactions;


-- =====================================================
-- Q3. Fraud Rate
-- Business Question:
-- What percentage of transactions are fraudulent?
-- =====================================================

SELECT
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate
FROM bank_transactions;

-- =====================================================
-- Q4. Revenue by Merchant Category
-- Which business category generates the highest revenue?
-- =====================================================

SELECT
    merchant_category,
    ROUND(SUM(amount),2) AS revenue,
    COUNT(*) AS transactions
FROM bank_transactions
GROUP BY merchant_category
ORDER BY revenue DESC;

-- =====================================================
-- Q5. Revenue by City
-- Which cities contribute the most transaction revenue?
-- =====================================================

SELECT
    city,
    ROUND(SUM(amount),2) AS revenue,
    COUNT(*) AS transactions
FROM bank_transactions
GROUP BY city
ORDER BY revenue DESC;

-- =====================================================
-- Q6. Fraud Rate by Payment Method
-- Which payment method is riskiest?
-- =====================================================

SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_cases,
    ROUND(100.0 * SUM(is_fraud)/COUNT(*),2) AS fraud_rate
FROM bank_transactions
GROUP BY payment_method
ORDER BY fraud_rate DESC;

-- =====================================================
-- Q7. Top 10 Highest Spending Customers
-- Window Function: RANK()
-- =====================================================

WITH customer_spending AS (

    SELECT
        customer_id,
        city,
        SUM(amount) AS total_spent

    FROM bank_transactions
    GROUP BY customer_id, city

)

SELECT
    RANK() OVER(ORDER BY total_spent DESC) AS spending_rank,
    customer_id,
    city,
    ROUND(total_spent,2) AS total_spent

FROM customer_spending
LIMIT 10;


-- =====================================================
-- Q8. Highest Spending Customer in Every City
-- =====================================================

WITH customer_city AS (

    SELECT
        customer_id,
        city,
        SUM(amount) AS total_spent

    FROM bank_transactions
    GROUP BY customer_id, city

),

ranked AS (

    SELECT *,
           RANK() OVER(
               PARTITION BY city
               ORDER BY total_spent DESC
           ) AS rnk

    FROM customer_city

)

SELECT
    city,
    customer_id,
    ROUND(total_spent,2) AS total_spent

FROM ranked
WHERE rnk = 1
ORDER BY total_spent DESC;

-- =====================================================
-- Q9. Transaction Value Segmentation
-- Business Question:
-- How are transactions distributed by value?
-- =====================================================

SELECT
    CASE
        WHEN amount < 50 THEN 'Low Value'
        WHEN amount BETWEEN 50 AND 200 THEN 'Medium Value'
        ELSE 'High Value'
    END AS transaction_segment,

    COUNT(*) AS transactions,
    ROUND(SUM(amount),2) AS revenue,
    ROUND(AVG(amount),2) AS avg_amount

FROM bank_transactions

GROUP BY transaction_segment

ORDER BY revenue DESC;


-- =====================================================
-- Q10. Fraud Rate by Transaction Value
-- =====================================================

SELECT
    CASE
        WHEN amount < 50 THEN 'Low Value'
        WHEN amount BETWEEN 50 AND 200 THEN 'Medium Value'
        ELSE 'High Value'
    END AS transaction_segment,

    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_cases,

    ROUND(
        100.0 * SUM(is_fraud) / COUNT(*),
        2
    ) AS fraud_rate

FROM bank_transactions

GROUP BY transaction_segment

ORDER BY fraud_rate DESC;


-- =====================================================
-- Q11. Merchant Categories with Revenue Above €10M
-- Business Question:
-- Which merchant categories generated more than €10M?
-- =====================================================

SELECT
    merchant_category,
    COUNT(*) AS transactions,
    ROUND(SUM(amount),2) AS revenue

FROM bank_transactions

GROUP BY merchant_category

HAVING SUM(amount) > 10000000

ORDER BY revenue DESC;


-- =====================================================
-- Q12. High Activity Cities
-- =====================================================

SELECT
    city,
    COUNT(*) AS transactions,
    ROUND(SUM(amount),2) AS revenue

FROM bank_transactions

GROUP BY city

HAVING COUNT(*) > 100000

ORDER BY transactions DESC;


-- =====================================================
-- Q13. Monthly Revenue Trend
-- =====================================================

SELECT
    month,
    month_name,
    COUNT(*) AS transactions,
    ROUND(SUM(amount),2) AS revenue

FROM bank_transactions

GROUP BY month, month_name

ORDER BY month;


-- =====================================================
-- Q14. Weekday Revenue Analysis
-- =====================================================

SELECT
    weekday,
    COUNT(*) AS transactions,
    ROUND(SUM(amount),2) AS revenue,
    ROUND(AVG(amount),2) AS avg_transaction

FROM bank_transactions

GROUP BY weekday

ORDER BY revenue DESC;


-- =====================================================
-- Q15. Peak Transaction Hours
-- =====================================================

SELECT
    hour,
    COUNT(*) AS transactions,
    ROUND(SUM(amount),2) AS revenue

FROM bank_transactions

GROUP BY hour

ORDER BY hour;


-- =====================================================
-- Q16. Cumulative Monthly Revenue
-- Window Function: SUM() OVER()
-- =====================================================

WITH monthly_revenue AS (

    SELECT
        month,
        month_name,
        SUM(amount) AS revenue

    FROM bank_transactions

    GROUP BY month, month_name

)

SELECT
    month,
    month_name,
    ROUND(revenue,2) AS monthly_revenue,

    ROUND(
        SUM(revenue) OVER(
            ORDER BY month
        ),
        2
    ) AS cumulative_revenue

FROM monthly_revenue

ORDER BY month;

-- =====================================================
-- Q17. Top 5 Merchants in Each Category
-- Window Function: DENSE_RANK()
-- =====================================================

WITH merchant_sales AS (

    SELECT
        merchant_category,
        merchant_name,
        SUM(amount) AS revenue

    FROM bank_transactions
    GROUP BY merchant_category, merchant_name

),

ranked AS (

    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY merchant_category
               ORDER BY revenue DESC
           ) AS merchant_rank

    FROM merchant_sales

)

SELECT
    merchant_category,
    merchant_rank,
    merchant_name,
    ROUND(revenue,2) AS revenue

FROM ranked
WHERE merchant_rank <= 5

ORDER BY merchant_category, merchant_rank;


-- =====================================================
-- Q18. Customers Spending Above City Average
-- Subquery
-- =====================================================

WITH customer_total AS (

    SELECT
        customer_id,
        city,
        SUM(amount) AS total_spent

    FROM bank_transactions
    GROUP BY customer_id, city

)

SELECT
    customer_id,
    city,
    ROUND(total_spent,2) AS total_spent

FROM customer_total c

WHERE total_spent >

(
    SELECT AVG(total_spent)

    FROM customer_total
    WHERE city = c.city
)

ORDER BY total_spent DESC
LIMIT 20;

-- =====================================================
-- Q19. Fraud Risk Classification by Hour
-- CASE + GROUP BY
-- =====================================================

SELECT

    hour,

    COUNT(*) AS total_transactions,

    SUM(is_fraud) AS fraud_cases,

    ROUND(
        100.0 * SUM(is_fraud)/COUNT(*),
        2
    ) AS fraud_rate,

    CASE

        WHEN ROUND(
            100.0 * SUM(is_fraud)/COUNT(*),
            2
        ) >= 8 THEN 'High Risk'

        WHEN ROUND(
            100.0 * SUM(is_fraud)/COUNT(*),
            2
        ) >= 5 THEN 'Medium Risk'

        ELSE 'Low Risk'

    END AS risk_level

FROM bank_transactions

GROUP BY hour

ORDER BY fraud_rate DESC;

-- =====================================================
-- Q20. Executive KPI Summary
-- =====================================================

SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT merchant_id) AS total_merchants,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_transaction,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate
FROM bank_transactions;