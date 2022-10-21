-- Cleaning Data

-- Total records 541,909
SELECT * FROM dbo.Online_Retail

---------------------------------------------------------------------------------------------------------------------------------------------------

-- 135,080 records do not have a CustomerID
-- 406,829 records have a CustomerID
; WITH online_retail AS
(
  SELECT [InvoiceNo],
        [StockCode],
        [Description],
        [Quantity],
        [InvoiceDate],
        [UnitPrice],
        [CustomerID],
        [Country]
  FROM dbo.Online_Retail
  WHERE CustomerID IS NOT NULL
), quantity_unit_price AS (

  -- 397,884 records with quantity and unit price
  SELECT *
  FROM online_retail
  WHERE Quantity > 0 and UnitPrice > 0
), dup_check AS -- Create cte dup_check
(

  -- Dupicate Check
  SELECT *, ROW_NUMBER() over (PARTITION BY InvoiceNo, StockCode, Quantity ORDER BY InvoiceDate) dup_flag -- Identifying duplicates and any dup_flag > 1 is a duplicate
  FROM quantity_unit_price
)
-- 392,669 Clean Data
-- 5,215 Duplicate records
SELECT *
INTO #online_retail_main -- Create a local temp table called #online_retail_main to store our clean data
FROM dup_check
WHERE dup_flag = 1

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Our temp table to use for analysis as it contains our clean data
SELECT * FROM #online_retail_main

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Different types of cohorts include Time-based, Size-based, and Segment-based
-- Begin Time-based Cohort Analysis
-- Unique Identifier (CustomerID)
-- Intital Start Date (First Invoice Date)
-- Revenue Data
SELECT CUSTOMERID,
       MIN(InvoiceDate) first_purchase_date,
       DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) Cohort_Date
INTO #cohort -- Create temp table for the above query
FROM #online_retail_main
GROUP BY CustomerID

SELECT *
FROM #cohort

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Create the cohort index
-- Index represents the number of months that have passed since their first purchase
SELECT
  mmm.*,
  cohort_index = year_diff * 12 + month_diff + 1
INTO #cohort_retention
FROM
  (
  SELECT
    mm.*,
    year_diff = invoice_year - cohort_year,
    month_diff = invoice_month - cohort_month
  FROM
    (
    SELECT
      m.*,
      c.Cohort_Date,
      YEAR(m.InvoiceDate) invoice_year,
      MONTH(m.InvoiceDate) invoice_month,
      YEAR(c.Cohort_Date) cohort_year,
      MONTH(c.Cohort_Date) cohort_month
    FROM #online_retail_main m
    LEFT JOIN #cohort c
      ON m.CustomerID = c.CustomerID
    )mm
  )mmm

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Use below query and export as a csv file for Tableau
-- SELECT * FROM #cohort_retention

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Pivot data to see the cohort table
SELECT *
INTO #cohort_pivot -- Create temp table to store our pivot table
FROM
(
  SELECT DISTINCT
    CustomerID,
    Cohort_Date,
    cohort_index
  FROM #cohort_retention
)tbl
PIVOT(
  COUNT(CustomerID)
  FOR Cohort_Index IN(
    [1],
    [2],
    [3],
    [4],
    [5],
    [6],
    [7],
    [8],
    [9],
    [10],
    [11],
    [12],
    [13]
  )
)AS pivot_table


-- Below is to check how many cohort_indexes there are
/*
SELECT DISTINCT
  cohort_index
FROM #cohort_retention
*/

-- Break out cohort by number of customers
SELECT *
FROM #cohort_pivot
ORDER BY Cohort_Date

-- Break out cohort by percentages
SELECT
  Cohort_Date,
  1.0 * [1]/[1] * 100,
  1.0 * [2]/[1] * 100,
  1.0 * [3]/[1] * 100,
  1.0 * [4]/[1] * 100,
  1.0 * [5]/[1] * 100,
  1.0 * [6]/[1] * 100,
  1.0 * [7]/[1] * 100,
  1.0 * [8]/[1] * 100,
  1.0 * [9]/[1] * 100,
  1.0 * [10]/[1] * 100,
  1.0 * [11]/[1] * 100,
  1.0 * [12]/[1] * 100,
  1.0 * [13]/[1] * 100
FROM #cohort_pivot
ORDER BY Cohort_Date