SELECT *
FROM PortfolioProject3..Airbnb_Data

--------------------------------------------------------------------------------------------------------------------------------------------

-- Check if there are duplicate Unique IDs
SELECT COUNT(id) id_count
FROM PortfolioProject3..Airbnb_Data

SELECT COUNT(DISTINCT(id)) unique_id_count
FROM PortfolioProject3..Airbnb_Data

--------------------------------------------------------------------------------------------------------------------------------------------

-- 102,599 IDs however there are 102,058 Unique IDs
-- Need to find the duplicates
SELECT id, COUNT(*)
FROM PortfolioProject3..Airbnb_Data
GROUP BY id
HAVING COUNT(*) > 1

-- View all duplicate info to double check they are actually duplicates
-- All are definitely duplicates
SELECT a.*
FROM PortfolioProject3..Airbnb_Data a
JOIN (SELECT id, COUNT(*) count_col
FROM PortfolioProject3..Airbnb_Data
GROUP BY id
HAVING COUNT(*) > 1 ) b
ON a.id = b.id
ORDER BY id

-- Delete Duplicate Rows
DELETE x
FROM (
  SELECT *, rn=ROW_NUMBER() OVER (PARTITION BY id ORDER BY id)
  FROM PortfolioProject3..Airbnb_Data
) x
WHERE rn > 1

--------------------------------------------------------------------------------------------------------------------------------------------

-- 431 rows have a negative availability_365 value
-- availability_365 column is meant to show how many days from today you will be able to book the airbnb
-- For simplicity I will remove all rows with negative values 
DELETE FROM PortfolioProject3..Airbnb_Data
WHERE availability_365 < 0

--------------------------------------------------------------------------------------------------------------------------------------------

-- The license column only has 2 rows with values
-- This column will not be useful for analysis
-- Drop the license column
ALTER TABLE PortfolioProject3..Airbnb_Data
DROP COLUMN 
  license

--------------------------------------------------------------------------------------------------------------------------------------------

-- The review_per_month column has a value of NULL if there are no reviews
-- Change NULLS in the review_per_month column to 0 to reflect the actual number of reviews for later analysis
UPDATE PortfolioProject3..Airbnb_Data
SET reviews_per_month = 0
WHERE reviews_per_month IS NULL

-- Updated 15,736 values from NULL to 0 in the review_per_month column

--------------------------------------------------------------------------------------------------------------------------------------------

-- host_identity_verified should only have values of 'unconfirmed' or 'verified'
-- For simplicity I will assume if the value is NULL the correct value should be 'unconfirmed'
-- Update all NULL values in the host_idetity_verified column to 'unconfirmed'
SELECT DISTINCT(host_identity_verified)
FROM PortfolioProject3..Airbnb_Data

UPDATE PortfolioProject3..Airbnb_Data
SET host_identity_verified = 'unconfirmed'
WHERE host_identity_verified IS NULL

-- Updated 287 values

--------------------------------------------------------------------------------------------------------------------------------------------

-- The neighbourhood_group column has some values as 'brookln' and 'manhatan'
-- Update the neighbourhood_group column to reflect 'brookln' as 'Brooklyn' and 'manhatan' as 'Manhattan'
UPDATE PortfolioProject3..Airbnb_Data
SET neighbourhood_group = 'Brooklyn'
WHERE neighbourhood_group = 'brookln'

UPDATE PortfolioProject3..Airbnb_Data
SET neighbourhood_group = 'Manhattan'
WHERE neighbourhood_group = 'manhatan'

--------------------------------------------------------------------------------------------------------------------------------------------

-- Update the NULL values in the neighbourhood_group column to the correct borough
SELECT neighbourhood_group, neighbourhood
FROM PortfolioProject3..Airbnb_Data
WHERE neighbourhood_group IS NULL


UPDATE a
SET neighbourhood_group = 
    CASE
        WHEN a.neighbourhood_group IS NULL THEN b.neighbourhood_group
        ELSE a.neighbourhood_group
    END
FROM PortfolioProject3..Airbnb_Data a
INNER JOIN PortfolioProject3..Airbnb_Data b
ON a.neighbourhood = b.neighbourhood
WHERE a.neighbourhood_group IS NULL

--------------------------------------------------------------------------------------------------------------------------------------------