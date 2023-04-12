-- Data Cleaning Project - Nashville Housing  

SELECT * FROM NashvilleHousing


-------------------------------------------------------------------------------------
-- Standardizing the Date Format in the SaleDate column

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE


-------------------------------------------------------------------------------------
-- Populate Property Address Data
-- The task is to populate the PropertyAddress Data that are missing by filling in missing addresses for each unique ParcelID. The strategy is to copy the address from another row with the same ParcelID

--looking into the row that don't have a unique ParcelID
SELECT * FROM NashvilleHousing
WHERE ParcelID NOT IN
(SELECT ParcelID FROM NashvilleHousing
GROUP BY ParcelID
HAVING COUNT(*) = 1)

-- looking into the null values and replacement value
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
ORDER BY a.ParcelID

-- updating the table to fill in the null values
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------
-- Breaking out the PropertyAddress and OwnerAddress column into Individual Columns (Address, City, State) using two different methods: SUBSTRING, PARSNAME

-- spliting the PropertyAddress column into two Columns (Address,City) using SUBSTRING 
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing

-- adding two new columns as Address and City to the table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

-- adding values to the new two columns
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- spliting the OwnerAddress column into three Columns (Address,City,State) using PARSNAME
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) AS State
FROM NashvilleHousing

-- adding three new columns as Address, City and State to the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

-- adding values to the new three columns
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-------------------------------------------------------------------------------------
-- Changing 'Y' and 'N' to 'Yes' and 'No' in "SoldAsVacant" Column

-- counting the number of 'Y', 'YES', 'N' and 'NO' in the column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

-- changing the 'Y' with 'Yes' and 'N' with 'No'
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

-- Updating the column based of the Case statement
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END


-------------------------------------------------------------------------------------
-- Remove Duplicates

-- first try to find the duplicates using ROW_NUMBER function
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM NashvilleHousing

-- in this case DENSE_RANK() function would give the same result
SELECT *, 
DENSE_RANK() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM NashvilleHousing

-- only selecting all the duplicate rows (rows that have row_num > 1 are duplicate). In order to select duplicate rows based on the new row_num column we have to use CTE

WITH RowNumCTE AS 
(SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- deleting the duplicate rows based on the previous query
WITH RowNumCTE AS 
(SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-------------------------------------------------------------------------------------
-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-------------------------------------------------------------------------------------
SELECT * 
FROM NashvilleHousing


