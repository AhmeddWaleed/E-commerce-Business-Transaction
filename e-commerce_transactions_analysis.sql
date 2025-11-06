SELECT *
FROM "e-commerce_transaction";


-- creating a copy of the dataset

CREATE TABLE "transaction_copy" AS
SELECT * FROM "e-commerce_transaction";

SELECT *
FROM "transaction_copy";


-- Checking if there are any duplicates

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY "TransactionNum","Date",
"ProductNum","ProductName","Price",
"Quantity","CustomerNum","Country" 
 ORDER BY "TransactionNum"
) AS rn
FROM "transaction_copy"
)
DELETE FROM "transaction_copy"
WHERE "TransactionNum" IN (
    SELECT "TransactionNum"
    FROM duplicate_cte
    WHERE rn > 1
);


-- Checking if there are any nulls

SELECT *
FROM "transaction_copy"
WHERE "TransactionNum" IS NULL
OR "Date" IS NULL
OR "ProductNum" IS NULL
OR "ProductName" IS NULL
OR "Price" IS NULL
OR "Quantity" IS NULL
OR "CustomerNum" IS NULL
OR "Country"  IS NULL;


-- Checking if there are any blanks

SELECT *
FROM "transaction_copy"
WHERE "TransactionNum" = ''
OR "ProductNum"  = ''
OR "ProductName"  = ''
OR "CustomerNum"  = ''
OR "Country"   = '';


-- Deleting rows where price or quantity is negative

SELECT *
FROM "transaction_copy"
WHERE "Price" < 0;

SELECT *
FROM "transaction_copy"
WHERE "Quantity" < 0;

DELETE
FROM "transaction_copy"
WHERE "Quantity" < 0;


-- Analyzing the data


-- [1] Creating Total Revenue column and adding it to the dataset copy

ALTER TABLE "transaction_copy"
ADD COLUMN Revenue DECIMAL(15, 2) ;

UPDATE "transaction_copy"
SET Revenue = ("Price" * "Quantity");


-- [2] Total Revenue and Total Quantity by Products

SELECT
    "ProductNum",
    "ProductName",
    SUM("revenue") AS totalrevenue,
    SUM("Quantity")  AS totalquantity
FROM "transaction_copy"
GROUP BY "ProductNum" , "ProductName" 
ORDER BY totalrevenue DESC ;


-- [3] Sales Over Time (Monthly Trend)

SELECT 
    TO_CHAR("Date", 'YYYY-MM') AS month,
    SUM("revenue") AS totalsales
FROM "transaction_copy"
GROUP BY month
ORDER BY month;


-- [4] Total Revenue and Count of Transactions by Country

SELECT
    "Country",
     COUNT(DISTINCT"TransactionNum") AS transactions_count ,
     SUM("revenue") AS totalrevenue
FROM "transaction_copy"
GROUP BY "Country"
ORDER BY totalrevenue DESC ;


-- [5] Total Revenue and Total Quantity of Products by Country

SELECT
    "Country",
    SUM("Quantity") AS totalquantity,
	SUM("revenue") AS totalrevenue
FROM "transaction_copy"
GROUP BY "Country"
ORDER BY totalrevenue DESC;


-- [6] Count of Customers in each Country

SELECT
    "Country",
    COUNT(DISTINCT"CustomerNum") AS customer_count
FROM "transaction_copy"
GROUP BY "Country"
ORDER BY customer_count DESC ;


-- [7] Top Customers by Spend

SELECT 
    "CustomerNum",
    SUM("revenue") AS totalspent
FROM "transaction_copy"
GROUP BY "CustomerNum"
ORDER BY totalspent DESC
LIMIT 10;


-- [8] Customer Purchase Frequency

SELECT 
    "CustomerNum",
    COUNT(DISTINCT "TransactionNum") AS transactions_count
FROM "transaction_copy"
GROUP BY "CustomerNum"
ORDER BY transactions_count DESC
LIMIT 10;


-- [9] Total Spend and Total Quantity by Customer

SELECT 
    "CustomerNum",
	 SUM("Quantity") AS totalquantity,
	 SUM("revenue") AS totalspent
FROM "transaction_copy"
GROUP BY "CustomerNum"
ORDER BY totalspent DESC;


-- [10] Count of Transactions by Month

SELECT 
    TO_CHAR("Date", 'YYYY-MM') AS month,
    COUNT(DISTINCT"TransactionNum") AS transactions_count
FROM "transaction_copy"
GROUP BY month
ORDER BY month;


-- [11] Total Revenue and Total Quantity by Transactions

SELECT 
    "TransactionNum",
    SUM("Quantity") AS totalquantity,
	SUM("revenue") AS totalrevenue
FROM "transaction_copy"
GROUP BY "TransactionNum"
ORDER BY totalrevenue DESC;


