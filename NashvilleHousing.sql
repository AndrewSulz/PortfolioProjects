/*

Cleaning Data with SQL Queries

*/

---------------------------------------------------------------------------------------------------------------------------------------

-- View Data in Table
SELECT *
FROM PortfolioProject2..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------

-- Populate the Property Address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

---------------------------------------------------------------------------------------------------------------------------------------

-- Change Owner Address
SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------------------------

-- Change 'Y' and 'N' to 'Yes' and 'No' Respectively
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject2..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END

---------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Deleting data from my database in this example however I am aware that deleting data is not common practice in reality

SELECT *,
ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                UniqueID
) AS row_num   
INTO PortfolioProject2.dbo.NashvilleHousingv2         
FROM PortfolioProject2.dbo.NashvilleHousing


DELETE
FROM PortfolioProject2..NashvilleHousingv2
WHERE row_num>1
--ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------

-- Drop Unused Columns
SELECT *
FROM PortfolioProject2..NashvilleHousingv2

ALTER TABLE PortfolioProject2..NashvilleHousingv2
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------