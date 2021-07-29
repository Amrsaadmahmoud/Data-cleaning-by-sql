/*
Cleaning Data in SQL Queries
*/

select * 
from data_cleaning..NashvilleHousing;

-- Standardize Date Format

--test
select SaleDate,CONVERT(date,SaleDate)
from NashvilleHousing;
--code
alter table NashvilleHousing
alter column SaleDate Date;
--test
select SaleDate
from NashvilleHousing;
------------------------------------------------------------------------------------------------
-- Populate Property Address data

--test
select * 
from data_cleaning..NashvilleHousing
where PropertyAddress is null
order by ParceliD;

--test
select a.ParceliD,a.PropertyAddress,b.ParceliD,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParceliD=b.ParceliD
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

--code
update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParceliD=b.ParceliD
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

---------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City)

--test
select PropertyAddress
from NashvilleHousing;

--code
select 
PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitcity Nvarchar(255);

update NashvilleHousing
set PropertySplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));


---------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City,state)

--test
select OwnerAddress
from NashvilleHousing;

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing; 

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



------------------------------------------------------------------------------------------------
------ Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant)
from NashvilleHousing;


select SoldAsVacant,
case when SoldAsVacant='N' then 'No'
when SoldAsVacant='Y' then 'Yes'
else SoldAsVacant
end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='N' then 'No'
when SoldAsVacant='Y' then 'Yes'
else SoldAsVacant
end;


---------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing

------------------------------------------------------------------------------------
-- Delete Unused Columns






ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





