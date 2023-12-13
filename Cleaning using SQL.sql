SElECT *
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------
-- Date Formatting
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = SaleDateConverted

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--ALTER TABLE NashvilleHousing
--DROP COLUMN SaleDate

-------------------------------------------------------------------------------------
--CHECKING NULL ADDRESSES
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL -- 29 null value

-- NOTICE THAT a house might be sold twice from two different owners, hence getting a missing value from another transaction
-- would be ideal to populate NULL addresses for that house based on ParcelID
--------------------------
--POPULATING Addressess
SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress AS adress, ISNULL(a.PropertyAddress, b.PropertyAddress) final_address
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL  --29 affected rows
--------------------------------------------------------------------------------------------
--Address breakdown so that address, city, and the state are each in a different column
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

------

SELECT PARSENAME(REPLACE(PropertyAddress, ',','.'),2),
PARSENAME(REPLACE(PropertyAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousing

--ALTER TABLE NashvilleHousing
--ADD PropAddress nvarchar(255)
--ALTER TABLE NashvilleHousing
--ADD PropCity nvarchar(255)
--UPDATE NashvilleHousing
--SET PropAddress = PARSENAME(REPLACE(PropertyAddress, ',','.'),2)
--UPDATE NashvilleHousing
--SET PropCity = PARSENAME(REPLACE(PropertyAddress, ',','.'),1)
--------------------------------------------------------------
--OwnerAddress Splitting
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3) OwnAdd,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) OwnCity,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) OwnState
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnState nvarchar(255)
UPDATE NashvilleHousing
SET OwnState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
------------------------------------------------------------------------
--Data validation in SoldAsVacant
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
Else SoldAsVacant
END

----------------------------------------------------------------------------
--Checking for Duplicates
WITH Dups AS (SELECT *,ROW_NUMBER() OVER ( 
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			LegalReference
			ORDER BY 
				UniqueID
				) row_num
FROM PortfolioProject..NashvilleHousing
) 
SELECT * 
FROM Dups 
WHERE row_num > 1


--DELETE
--FROM Dups
--WHERE row_num > 1

---------------------------------------------------------------------
--EDITED and UNUSED columns removal

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate