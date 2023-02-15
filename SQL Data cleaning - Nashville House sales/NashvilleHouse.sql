

-- Cleaning data in SQL queries 
-- Select all the columns for inspection 

SELECT *
FROM SQLproject.dbo.Nashville_house

-- Standardize the date format 

-- The below is to change datatype and give a new column
SELECT SaleDate , convert(date,SaleDate)
FROM SQLproject.dbo.Nashville_house

--either of two ways to change the data type of the column. 
-- #1 we can use Cast( ) as well instead of CONVERT( ) 
UPDATE SQLproject.dbo.Nashville_house
SET SaleDate = CONVERT(date,SaleDate);

-- #2 
ALTER TABLE Nashville_house
ALTER COLUMN SaleDate Date

----------------------------------------------------------------------------------------------------
 
 -- Property address has NULL value. Find ways to populate the missing values 
 -- Let's check the table with NULL values 
 SELECT *
 FROM SQLproject.dbo.Nashville_house
 WHERE PropertyAddress IS NULL 

 -- Same parcelIDs in multiple rows have address and NULL values in other. 
 -- We will self join to compare first between the two tables and then use existing address to fill up the NULL values according to the parcelIDs

 SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
 FROM SQLproject.dbo.Nashville_house as a 
 JOIN SQLproject.dbo.Nashville_house as b 
      ON a.ParcelID = b.ParcelID
	  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

update a 
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
 FROM SQLproject.dbo.Nashville_house as a 
 JOIN SQLproject.dbo.Nashville_house as b 
      ON a.ParcelID = b.ParcelID
	  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 


-------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State) 

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM SQLproject.dbo.Nashville_house

ALTER TABLE SQLproject.dbo.Nashville_house
ADD PropertySplitAddress nvarchar(255)

UPDATE SQLproject.dbo.Nashville_house
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_house
ADD PropertySplitCity nvarchar(255)

UPDATE SQLproject.dbo.Nashville_house
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))

-- check  the table again and see the 2 columns added at the end 

SELECT *
FROM SQLproject.dbo.Nashville_house


-- Split the OwnerAddress using PARSENAME( ) 
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM SQLproject.dbo.Nashville_house

-- Add new columns and assign values 

ALTER TABLE SQLproject.dbo.Nashville_house
ADD OwnerSplitAddress nvarchar(255)

UPDATE SQLproject.dbo.Nashville_house
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE SQLproject.dbo.Nashville_house
ADD OwnerSplitCity nvarchar(255)

UPDATE SQLproject.dbo.Nashville_house
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE SQLproject.dbo.Nashville_house
ADD OwnerSplitState nvarchar(255)

UPDATE SQLproject.dbo.Nashville_house
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM SQLproject.dbo.Nashville_house

--------------------------------------------------------------------------------------------

-- Change 0 and 1 to yes and no in "Sold as vacant" field. 

SELECT DISTINCT (SoldAsVacant), COUNT(Soldasvacant)
FROM SQLproject.dbo.Nashville_house
group by SoldAsVacant

-- Change the data type in column "Sold as vacant" from bit to nvarchar

ALTER TABLE SQLproject.dbo.Nashville_house
ALTER COLUMN Soldasvacant nvarchar(255)

-- change the value from 0/1 to yes/no

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 0 THEN 'No'
     WHEN SoldAsVacant = 1 THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM SQLproject.dbo.Nashville_house

UPDATE SQLproject.dbo.Nashville_house
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'No'
     WHEN SoldAsVacant = 1 THEN 'Yes'
	 ELSE SoldAsVacant
	 END


--------------------------------------------------------------------------------------------------------

-- create a temporary table from where we will remove duplicates

WITH RowNumCTE AS (
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				   UniqueID) ROW_NUM

FROM SQLproject.dbo.Nashville_house)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY PropertyAddress

-- remove duplicates from the temp table

WITH RowNumCTE AS (
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				   UniqueID) ROW_NUM

FROM SQLproject.dbo.Nashville_house)

DELETE
FROM RowNumCTE
WHERE row_num > 1 
-- ORDER BY PropertyAddress

-------------------------------------------------------------------------------------------------------
-- delete unused column

SELECT *
FROM SQLproject.dbo.Nashville_house

ALTER TABLE SQLproject.dbo.Nashville_house
DROP COLUMN TaxDistrict, LegalReference