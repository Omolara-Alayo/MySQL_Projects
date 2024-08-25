-- MySQL Data Cleaning PROJECT

SELECT *
FROM layoffs;

-- Creating a duplicate table to work with as a Staging table/working data

CREATE TABLE layoffs_stagging
LIKE layoffs;

SELECT *
FROM layoffs_stagging;
 -- then insert the data
 
INSERT layoffs_stagging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_stagging;

-- Task 1: Removing Duplicate from the data

-- Identifying duplicate

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- * Checking**
SELECT *
FROM layoffs_stagging
WHERE company = 'Casper';  -- *duplicates do exist

-- Since there are no row numbers in the table, then a table that has these extra rows will be created to remove the duplicates and also
-- deletion or update of rows cannot be done one a cte
  
CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_stagging2;

INSERT INTO layoffs_stagging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging;

SELECT *
FROM layoffs_stagging2
WHERE row_num >1;

DELETE -- deleting the duplicate records
FROM layoffs_stagging2
WHERE row_num >1;

SELECT * -- rechecking 
FROM layoffs_stagging2
WHERE row_num >1; -- Done!

-- Task 2: Standardizing data
-- Checking 'company'
SELECT company, TRIM(company)
FROM layoffs_stagging2;

UPDATE layoffs_stagging2
SET company = TRIM(company);

-- checkin 'industry'
SELECT DISTINCT industry
FROM layoffs_stagging2
ORDER BY 1;
-- Cryto industries appear to have some inconsistences in names
SELECT *
FROM layoffs_stagging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_stagging2
SET industry  = 'Crypto'
WHERE industry LIKE 'Crypto%'; -- updated all to Crypto!
 
SELECT DISTINCT industry -- checking...
FROM layoffs_stagging2; -- Now consistent!

-- checking 'location'
SELECT DISTINCT location
FROM layoffs_stagging2
ORDER BY 1;  -- location appears unique/good

-- checking country
SELECT DISTINCT country
FROM layoffs_stagging2
ORDER BY 1;  -- Not all unique

	-- update country - United States
SELECT *
FROM layoffs_stagging2
WHERE country = "United States."
ORDER BY 1;  -- 4 records with 'United States.'

UPDATE layoffs_stagging2
SET country = 'United States'
WHERE country LIKE 'United States%'; -- Country United States now unique!

-- OR
-- UPDATE layoffs_stagging2
-- SET country = TRIM(TRAILING '.' FROM country)
-- WHERE country LIKE 'United States%';

SELECT DISTINCT country -- rechecking...
FROM layoffs_stagging2
ORDER BY 1; -- Done!

-- checking the 'date' and update to date format

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_stagging2;

UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); -- all tset to date format

SELECT `date`  -- checking...
FROM layoffs_stagging2;-- done!

-- now, change the date column to date datatype (initally a text)
ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE; -- done!

SELECT * 
FROM layoffs_stagging2;

-- So far, company, industry, country, and date columns have been cleaned/standardized. 
-- The 'stage' column will be done later and 'location' column appears fine.

-- 3. Removing the NULL values
-- Columns 'total_laid_off', 'percentage_laid_off' and 'fund_raised_millions' have a conspicious NULL values

-- Starting with 'total_laif_off'
SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL; -- quite a lot, about 730 rows

SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; -- About 361 rows

-- *'industry' also has null, values
SELECT *
FROM layoffs_stagging2
WHERE industry IS NULL
OR industry = ''; -- 4 ROWS
    
    -- checking...
SELECT *
FROM layoffs_stagging2
WHERE company = 'Airbnb';

-- Since companies of the same name belong to the same industry, we can imput the ones that have missing 'indutry' name with similar 
-- 'industry' name form the group

    -- First, update the table to fill NULL for blanks
UPDATE layoffs_stagging2
SET industry  = null
WHERE industry  = '';

   -- Creatting a JOIN
SELECT t1.industry, t2.industry
FROM layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company  = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

     -- Now imput/set the, to be the same industry
     
UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company  = t2.company
SET t1.industry  = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

	-- checking...
SELECT *
FROM layoffs_stagging2
WHERE company = 'Airbnb'; --  done!
 
SELECT *
FROM layoffs_stagging2
WHERE industry IS NULL; -- 1 record with missing indsutry. No other entry with the company name to impute its industry. Hence, fine :)

SELECT *
FROM layoffs_stagging2
WHERE company LIKE 'Bally%'; -- just only this company

-- The NULL values in the 'percentage_laid_off' may not be populated because of the absence of company size
-- Also, NULL values in the fund_raised_million can not be populated using the available data, perhaps sourcing the net but thats outside the scope of this task.
-- Therefore, NULL values have been handled.

-- 4. Removing unwanted columns or rows

	-- There are quite a number of rows where total_laid_off anf the percentage_laid_off are NULL, hence can be removed
SELECT *
FROM layoffs_stagging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; -- About 361 rows

DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; -- deleted!

   -- Also, 'row_num' column should be dropped
ALTER TABLE layoffs_stagging2
DROP COLUMN row_num; -- dropped!

SELECT *
FROM layoffs_stagging2; -- CLEANED DATA!





















