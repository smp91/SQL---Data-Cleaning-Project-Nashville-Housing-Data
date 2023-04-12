
# SQL - Data Cleaning Project - Nashville Housing Data 

Cleaning Nashville Housing Data using MS SQL

- Constructed a database utilizing Microsoft SQL Server Management Studio that consists of one Excel file.


#### Technical Summary of Project Accomplishments:
- Standardized the Date format in the SaleDate column using ALTER TABLE statement
- Used JOIN statement to join the NashvilleHousing table with itself to identify missing PropertyAddress data. 
- Populated missing PropertyAddress data by copying addresses from other rows with the same ParcelID using SELECT, JOIN, and UPDATE statements
- Removed duplicates in the NashvilleHousing table using ROW_NUMBER and CTE (Common Table Expressions) with DELETE statement
- Split the PropertyAddress and OwnerAddress columns into separate columns (Address, City, State) using SUBSTRING and PARSENAME functions and added new columns to the table using ALTER TABLE statement
- Changed 'Y' and 'N' values in the SoldAsVacant column to 'Yes' and 'No' using CASE statement and UPDATE statement
