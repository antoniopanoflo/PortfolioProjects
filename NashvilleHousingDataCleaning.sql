/*

Cleaning Data in SQL Queries

*/
-- ALTER TABLE Nashville_House_DataCleaning RENAME TO NashvilleHousing.

SELECT *
FROM nashvillehousing;


/* ------------------------------------------------------------------------------------------- */
-- Populate Property Address Data 
-- Each Property Address has a corresponding ParcelID. We can fill in the NULL values.
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) as NullReplacements
FROM Nashvillehousing a
JOIN Nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID -- This included to never get doubles and waste scrolling.
WHERE a.PropertyAddress IS NULL;


UPDATE nashvillehousing a
JOIN nashvillehousing b 
	ON a.ParcelID = b.ParcelID
  	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


/* ------------------------------------------------------------------------------------------- */
-- Breaking Out PropertyAddress/OwnerAddress Into Individual Columns (Address, City, State). Making use of the comma as the delimiter.

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(",", PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, length(PropertyAddress)) -- length() wasn't truly needed.
FROM Nashvillehousing;
 
-- Adding Column PropertySplitAddress
 ALTER TABLE Nashvillehousing
 ADD PropertySplitAddress varchar(255);
 UPDATE Nashvillehousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(",", PropertyAddress) -1);

-- Adding Column PropertySplitCity
 ALTER TABLE Nashvillehousing
 ADD PropertySplitCity varchar(255);
 UPDATE Nashvillehousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, length(PropertyAddress));
 

-- Adding Column OwnerSplitAddress
ALTER TABLE Nashvillehousing  
ADD OwnerSplitAddress varchar(255);
UPDATE Nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1);

-- Adding Column OwnerSplitCity
ALTER TABLE Nashvillehousing  
ADD OwnerSplitCity varchar(255);
UPDATE Nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

-- Adding Column OwnerSplitState
ALTER TABLE Nashvillehousing
ADD OwnerSplitState varchar(255);
UPDATE Nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

/* ------------------------------------------------------------------------------------------- */
-- Change Y and N to YES and NO in "Sold as Vacant" field.

-- Checking for any other possible entries.
SELECT distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2;


UPDATE Nashvillehousing
SET soldasvacant = 
CASE
    WHEN soldasvacant = 'Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END ;


/* ------------------------------------------------------------------------------------------- */
-- Remove Duplicates: 44:00

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
 	     PropertyAddress, 
	     SalePrice, 
             SaleDate, 
             LegalReference
			ORDER BY UniqueID) as row_num
FROM Nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;


WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
	     PropertyAddress, 
	     SalePrice, 
             SaleDate, 
             LegalReference
	     ORDER BY UniqueID) as row_num
FROM Nashvillehousing)
DELETE FROM Nashvillehousing USING Nashvillehousing JOIN RowNumCTE ON Nashvillehousing.UniqueID = RowNumCTE.UniqueID
WHERE RowNumCTE.row_num > 1;


/* ------------------------------------------------------------------------------------------- */
-- Remove Columns

ALTER TABLE Nashvillehousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;





