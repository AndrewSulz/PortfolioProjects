-- Inspecting Data
SELECT * FROM dbo.sales_data_sample

-----------------------------------------------------------------------------------------------------------------------------------

-- Checking unique values
SELECT DISTINCT status FROM dbo.sales_data_sample 
SELECT DISTINCT year_id FROM dbo.sales_data_sample 
SELECT DISTINCT PRODUCTLINE FROM dbo.sales_data_sample
SELECT DISTINCT COUNTRY FROM dbo.sales_data_sample
SELECT DISTINCT DEALSIZE FROM dbo.sales_data_sample 
SELECT DISTINCT TERRITORY FROM dbo.sales_data_sample 

-- Data is from 2003 - 2005
-- Only operated for the first 5 months of 2005
SELECT DISTINCT MONTH_ID FROM dbo.sales_data_sample
WHERE YEAR_ID = 2005

-----------------------------------------------------------------------------------------------------------------------------------

-- Analysis
-- Let's start by grouping sales by productline

-- Break down revenue by Productline
SELECT PRODUCTLINE, sum(sales) Revenue
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

-- Break down revenue by Year
SELECT YEAR_ID, sum(sales) Revenue
FROM dbo.sales_data_sample
GROUP BY YEAR_ID
ORDER BY 2 DESC

-- Break down revenue by Deal size
SELECT DEALSIZE, sum(sales) Revenue
FROM dbo.sales_data_sample
GROUP BY DEALSIZE
ORDER BY 2 DESC

-----------------------------------------------------------------------------------------------------------------------------------

-- What was the best month for sales in a specific year? How much was earned in that month?
SELECT MONTH_ID, SUM(SALES) Revenue, COUNT(ORDERNUMBER) Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2004 -- Change year to see the rest
GROUP BY MONTH_ID
ORDER BY 2 DESC

-- November seems to be the best month, what product do they sell in November, most likely will be classic cars
SELECT MONTH_ID, PRODUCTLINE, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2003 and MONTH_ID = 11 -- Change year to see the rest
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC

-----------------------------------------------------------------------------------------------------------------------------------

-- RFM Analysis (Recency-Frequency-Monetary)
-- Recency - last order date
-- Frequency - count of total orders
-- Monetary value - total spend
DROP TABLE IF EXISTS #rfm -- Drop a local temp table called rfm if it already exists
; WITH rfm AS -- Create a CTE to hold my buckets that will distinguish customers by RFM
(
  SELECT
    CUSTOMERNAME,
    SUM(sales) MonetaryValue,
    AVG(sales) AvgMonetaryValue,
    COUNT(ORDERNUMBER) Frequency,
    MAX(ORDERDATE) last_order_date,
    (SELECT MAX(ORDERDATE) last_order_date FROM dbo.sales_data_sample) max_order_date,
    DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM dbo.sales_data_sample)) Recency -- Showing how many days has it been since the customers last order compared to the most recent order in the data
  FROM dbo.sales_data_sample
  GROUP BY CUSTOMERNAME
),
rfm_calc AS -- Create CTE rfm_calc to hold our RFM buckets with given values 1-4. 1 means the customer is in the bottom 25 percentile. 4 means the customer is in the top 25 percentile
(
  SELECT r.*,
    NTILE(4) OVER (ORDER BY Recency DESC) rfm_recency, -- A value of 4 represents a very recent purchase
    NTILE(4) OVER (ORDER BY Frequency) rfm_frequency, -- A value of 4 represents a large frequency of purchases
    NTILE(4) OVER (ORDER BY MonetaryValue) rfm_monetary -- A value of 4 represents a larger purchase
  FROM rfm r
)
SELECT 
  c.*, rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell, -- Adding up all RFM values 3 being the worst possible customer and 12 being the best
  CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + CAST(rfm_monetary AS VARCHAR) rfm_cell_string -- To see values of RFM in one column (This is a string)
INTO #rfm -- Putting all of the data from the above query into a local temp table
FROM rfm_calc c

SELECT CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
  CASE
    WHEN rfm_cell_string in (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost customers' -- Lost customers
    WHEN rfm_cell_string in (133, 134, 143, 244, 334, 344) THEN 'slipping away, cannot lose' -- (Big spenders who haven't purchased lately) Slipping away
    WHEN rfm_cell_string in (311, 411, 331) THEN 'new customers'
    WHEN rfm_cell_string in (222, 223, 233, 322) THEN 'potential churners'
    WHEN rfm_cell_string in (323, 333, 321, 422, 332, 432) THEN 'active' -- (Customers who buy often & recently, but at low price points)
    WHEN rfm_cell_string in (433, 434, 443, 444) THEN 'loyal'
  END rfm_segment
FROM #rfm



-----------------------------------------------------------------------------------------------------------------------------------

-- What products are most often sold together?
-- SELECT * FROM dbo.sales_data_sample WHERE ORDERNUMBER = 10411
SELECT DISTINCT ORDERNUMBER, STUFF( -- Using the stuff function to remove the leading comma from the XML Path and converts it to a string

  (SELECT ',' + PRODUCTCODE
  FROM dbo.sales_data_sample p
  WHERE ORDERNUMBER IN
    (
      SELECT ORDERNUMBER
      FROM (
        SELECT ORDERNUMBER, COUNT(*) rn
        FROM dbo.sales_data_sample
        WHERE [STATUS] = 'Shipped'
        GROUP BY ORDERNUMBER
      ) m
      WHERE rn = 3 -- Change this number to see if multiple products are commonly sold together.
    )
    AND p.ORDERNUMBER = s.ORDERNUMBER
    FOR XML PATH (''))
    
    , 1, 1, '') ProductCodes
FROM dbo.sales_data_sample s
ORDER BY 2 DESC