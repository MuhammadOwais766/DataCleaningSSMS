SELECT * FROM PortfolioProject..NashvilleHousing

--STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT (Date, SaleDate) FROM PortfolioProject..NashvilleHousing
UPDATE PortfolioProject..NashvilleHousing SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing Add SaleDateConverted Date

UPDATE NashvilleHousing SET SaleDateConverted = CONVERT (Date, SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS

SELECT PropertyAddress FROM PortfolioProject..NashvilleHousing  ORDER BY ParcelID--WHERE PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] WHERE a.PropertyAddress IS NULL


UPDATE a SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] WHERE a.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------------------------------

-- SEPARATE ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT PropertyAddress FROM PortfolioProject..NashvilleHousing  --ORDER BY ParcelID WHERE PropertyAddress IS NULL

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing Add PropertySplitAddress Nvarchar(255)
UPDATE NashvilleHousing SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing Add PropertySplitCity Nvarchar(255)
UPDATE NashvilleHousing SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * FROM PortfolioProject..NashvilleHousing


--OWNER ADDRESS CHANGES

SELECT OwnerAddress FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing Add OwnerSplitAddress Nvarchar(255)
UPDATE NashvilleHousing SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing Add OwnerSplitCity Nvarchar(255)
UPDATE NashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing Add OwnerSplitState Nvarchar(255)
UPDATE NashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------

--CHANGE 'Y' AND 'N' TO 'Yes' AND 'No' IN "SoldAsVacant" COLUMN

SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2


SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


----------------------------------------------------------------------------------------------------------------------------------------------

--REMOVING DUPLICATES
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing  --ORDER BY ParcelID
)
SELECT * FROM RowNumCTE WHERE row_num > 1 ORDER BY PropertyAddress


----------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE/DELETE UNUSED COLUMNS

SELECT * FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO











