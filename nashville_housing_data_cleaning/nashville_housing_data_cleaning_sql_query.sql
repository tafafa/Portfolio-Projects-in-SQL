-- Data Cleaning in SQL--


SELECT *
FROM nashville_housing_data;



-- 1. Remove Duplicates 


CREATE TABLE nashville_housing_data_cleaned
LIKE nashville_housing_data;

SELECT *
FROM nashville_housing_data_cleaned;

INSERT nashville_housing_data_cleaned
SELECT *
FROM nashville_housing_data;

 SELECT *,
 ROW_NUMBER() OVER( 
 PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
 FROM nashville_housing_data_cleaned;
 
 WITH duplicate_cte AS
 (
 SELECT *,
 ROW_NUMBER() OVER( 
 PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
 FROM nashville_housing_data_cleaned
 )
 SELECT *
 FROM duplicate_cte
 WHERE row_num > 1;
 
 CREATE TABLE `nashville_housing_data_cleaned2` (
  `UniqueID` int DEFAULT NULL,
  `ParcelID` text,
  `LandUse` text,
  `PropertyAddress` text,
  `SaleDate` text,
  `SalePrice` text,
  `LegalReference` text,
  `SoldAsVacant` text,
  `OwnerName` text,
  `OwnerAddress` text,
  `Acreage` text,
  `TaxDistrict` text,
  `LandValue` text,
  `BuildingValue` text,
  `TotalValue` text,
  `YearBuilt` text,
  `Bedrooms` text,
  `FullBath` text,
  `HalfBath` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT nashville_housing_data_cleaned2
SELECT *,
 ROW_NUMBER() OVER( 
 PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference) AS row_num
 FROM nashville_housing_data_cleaned;
 
 SELECT *
 FROM nashville_housing_data_cleaned2
 WHERE row_num > 1;
 
 DELETE
 FROM nashville_housing_data_cleaned2
 WHERE row_num > 1;
 
 SELECT *
 FROM nashville_housing_data_cleaned2;
 
 
 
-- 2. Null Values or blank values
 
 SELECT 
	SUM(UniqueID = '') AS UniqueID_blank,
    SUM(ParcelID = '') AS ParcelID_blank,
	SUM(LandUse = '') AS LandUse_blank,
    SUM(PropertyAddress = '') AS PropertyAddress_blank,
    SUM(SaleDate = '') AS SaleDate_blank,
    SUM(SalePrice = '') AS SalePrice_blank,
    SUM(LegalReference = '') AS LegalReference_blank,
    SUM(SoldAsVacant = '') AS SoldAsVacant_blank,
	SUM(OwnerName = '') AS OwnerName_blank,
	SUM(OwnerAddress = '') AS OwnerAddress_blank,
	SUM(Acreage = '') AS Acreage_blank,
	SUM(TaxDistrict = '') AS TaxDistrict_blank,
    SUM(LandValue = '') AS LandValue_blank,
    SUM(BuildingValue = '') AS BuildingValue_blank,
    SUM(TotalValue = '') AS TotalValue_blank,
	SUM(YearBuilt = '') AS YearBuilt_blank,
	SUM(Bedrooms = '') AS Bedrooms_blank,
	SUM(FullBath = '') AS FullBath_blank,
	SUM(HalfBath = '') AS HalfBath_blank
FROM nashville_housing_data_cleaned2;
 
SELECT 
	SUM(UniqueID IS NULL) AS UniqueID_null,
    SUM(ParcelID IS NULL) AS ParcelID_null,
	SUM(LandUse IS NULL) AS LandUse_null,
    SUM(PropertyAddress IS NULL) AS PropertyAddress_null,
    SUM(SaleDate IS NULL) AS SaleDate_null,
    SUM(SalePrice IS NULL) AS SalePrice_null,
    SUM(LegalReference IS NULL) AS LegalReference_null,
    SUM(SoldAsVacant IS NULL) AS SoldAsVacant_null,
	SUM(OwnerName IS NULL) AS OwnerName_null,
	SUM(OwnerAddress IS NULL) AS OwnerAddress_null,
	SUM(Acreage IS NULL) AS Acreage_null,
	SUM(TaxDistrict IS NULL) AS TaxDistrict_null,
    SUM(LandValue IS NULL) AS LandValue_null,
    SUM(BuildingValue IS NULL) AS BuildingValue_null,
    SUM(TotalValue IS NULL) AS TotalValue_null,
	SUM(YearBuilt IS NULL) AS YearBuilt_null,
	SUM(Bedrooms IS NULL) AS Bedrooms_null,
	SUM(FullBath IS NULL) AS FullBath_null,
	SUM(HalfBath IS NULL) AS HalfBath_null
FROM nashville_housing_data_cleaned2;

UPDATE nashville_housing_data_cleaned2
SET UniqueID = NULLIF(UniqueID, ''),
    PropertyAddress = NULLIF(PropertyAddress, ''),
    OwnerName = NULLIF(OwnerName, ''),
    OwnerAddress = NULLIF(OwnerAddress, ''),
    Acreage = NULLIF(Acreage, ''),
	TaxDistrict = NULLIF(TaxDistrict, ''),
    LandValue = NULLIF(LandValue, ''),
    BuildingValue = NULLIF(BuildingValue, ''),
    TotalValue = NULLIF(TotalValue, ''),
    YearBuilt = NULLIF(YearBuilt, ''),
    Bedrooms = NULLIF(Bedrooms, ''),
    FullBath = NULLIF(FullBath, ''),
    HalfBath = NULLIF(HalfBath, '');
    

	-- PropertyAddress--
    
SELECT *
FROM nashville_housing_data_cleaned2
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress
FROM nashville_housing_data_cleaned2 n1
JOIN nashville_housing_data_cleaned2 n2
	ON n1.ParcelID = n2.ParcelID
    AND n1.UniqueID <> n2.UniqueID
WHERE n1.PropertyAddress IS NULL;

UPDATE nashville_housing_data_cleaned2 n1
JOIN nashville_housing_data_cleaned2 n2
	ON n1.ParcelID = n2.ParcelID
    AND n1.UniqueID <> n2.UniqueID
SET n1.PropertyAddress = n2.PropertyAddress
WHERE n1.PropertyAddress IS NULL;

SELECT *
FROM nashville_housing_data_cleaned2;



-- 3. Standardize the Data

	-- SaleDate --

SELECT SaleDate
FROM nashville_housing_data_cleaned2;

SELECT SaleDate,
STR_TO_DATE(SaleDate, '%M %d, %Y')
FROM nashville_housing_data_cleaned2;

UPDATE nashville_housing_data_cleaned2
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

ALTER TABLE nashville_housing_data_cleaned2
MODIFY COLUMN SaleDate DATE;

	-- PropertyAddress --

	/* We will be breaking it into (Address, City) */

SELECT PropertyAddress
FROM nashville_housing_data_cleaned2;

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) AS Address,
TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +2, LENGTH(PropertyAddress))) AS City
FROM nashville_housing_data_cleaned2;

ALTER TABLE nashville_housing_data_cleaned2
ADD COLUMN Address VARCHAR(255) AFTER PropertyAddress;

ALTER TABLE nashville_housing_data_cleaned2
ADD COLUMN City VARCHAR(255) AFTER Address;

UPDATE nashville_housing_data_cleaned2
SET Address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ),
	City = TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +2, LENGTH(PropertyAddress)));
    
	-- OwnerAddress --
    
    /* We will be breaking it into (Owner_Address, Owner_City, Owner_State) */
    
SELECT OwnerAddress
FROM nashville_housing_data_cleaned2;

SELECT OwnerAddress,
SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1 ) AS Owner_Address,
TRIM(SUBSTRING(Owneraddress, LOCATE(',', Owneraddress) + 1, 
	LOCATE(',', Owneraddress, LOCATE(',', Owneraddress) + 1) - LOCATE(',', Owneraddress) - 1)) AS Owner_City,
TRIM(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) + 1)) AS Owner_State
FROM nashville_housing_data_cleaned2;

ALTER TABLE nashville_housing_data_cleaned2
ADD COLUMN Owner_Address VARCHAR(255) AFTER OwnerAddress;

ALTER TABLE nashville_housing_data_cleaned2
ADD COLUMN Owner_City VARCHAR(255) AFTER Owner_Address;

ALTER TABLE nashville_housing_data_cleaned2
ADD COLUMN Owner_State VARCHAR(255) AFTER Owner_City;

UPDATE nashville_housing_data_cleaned2
SET Owner_Address = SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) -1 ),
	Owner_City =	TRIM(SUBSTRING(Owneraddress, LOCATE(',', Owneraddress) + 1, 
				         LOCATE(',', Owneraddress, LOCATE(',', Owneraddress) + 1) - LOCATE(',', Owneraddress) - 1)),
	Owner_State =   TRIM(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) + 1));


	-- SoldAsVacant --
    
    /* Change Y or N to Yes or No */
    
SELECT SoldAsVacant
FROM nashville_housing_data_cleaned2;

SELECT SoldAsVacant, COUNT(*)
FROM nashville_housing_data_cleaned2
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM nashville_housing_data_cleaned2;

UPDATE nashville_housing_data_cleaned2
SET SoldAsVacant = CASE
				   WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END;

SELECT *
FROM nashville_housing_data_cleaned2;



-- 4. Remove Unused Colums or Rows

SELECT *
FROM nashville_housing_data_cleaned2;

ALTER TABLE nashville_housing_data_cleaned2
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;
