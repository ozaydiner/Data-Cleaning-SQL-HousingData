
-- Cleaning Data in SQL

SELECT *
FROM dbo.NashvilleHousing


-- Standardize date format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-- Populate Property Address data


Select *
From dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID



-- Joining the same table on itself to differantiate between parcelID and UniqueID so that UniqueID will never repeat but parcelID can
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking (bad :P) out Adress into individual Columns (Address, City, State)


SELECT PropertyAddress
FROM dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
from dbo.NashvilleHousing

-- We created 2 new columns at the end

SELECT OwnerAddress
from dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

SELECT * 
from dbo.NashvilleHousing


--Change Y and N to Yes and No in "sold as vacant" field

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates
--We need to partition our data

WITH RowNumCTE AS(

SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID
  ) row_num


FROM dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress

-- Delete  Unused columns

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN TaxDistrict