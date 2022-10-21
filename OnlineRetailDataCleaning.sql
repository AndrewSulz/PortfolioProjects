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