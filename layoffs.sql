-- Data cleaning

SELECT * 
FROM layoffs;

/*
	1.Remove duplicates.
    2.Standardize Data.
    3.Null values or blank values.
    4.Remove unneccessary coloumns.
    
*/

-- creating a table same as layoffs and naming it as layoff_staagging:

CREATE TABLE Layoff_stagging like layoffs;

-- checking the table structure:

SELECT  * 
FROM layoff_staging;

-- Inserting all data from layoffs table to layoff_stagging table previous we only created same structue now we are copying the data:

INSERT INTO layoff_staging
SELECT *
FROM layoffs;

-- Creating a new column (row_num) using over function in order to find the duplicate values:

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoff_staging;


-- using cte function to  clearly write a qurey to find the duplicate value:
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

--  cross-checking the values in the table to confirm that previous query correctly filtered the duplicate values:

SELECT *
FROM layoff_staging
WHERE company = "&Open";


-- try to create new table layoff_stagging2 same as layoff_staging:

CREATE TABLE layoff_stagging2 like layoff_staging;

SELECT * FROM layoff_stagging2;
SELECT* FROM layoff_staging;

-- deleteing the table because we cannot add the row_num column in the new table because the row_num is created using query command so it can not be copied into new table:

DROP TABLE
layoff_stagging2;

-- creating new table layoff_staging2 and now manually adding the row_num column name with datatype :

CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoff_staging2;
/*
inserting all values from the layoff_staging  table to layoff_staging2 table but here first table has 9 columns but second one have 10 column,
so we are using ROW_NUMBER function with the help over function to fill the value in the column:
*/

INSERT INTO layoff_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM layoff_staging;

SELECT *
FROM layoff_staging2
WHERE row_num >1;

-- safety off
SET SQL_SAFE_UPDATES = 0;

-- Deletimg the duplicate values in the table:

DELETE 
FROM layoff_staging2
WHERE row_num >1;


-- safety on
SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM layoff_staging2;

SELECT row_num,count(*)
from layoff_staging2 group by row_num;

-- Standardizing data
-- removing empty spaces in the company column using trim function

SELECT company, trim(company)
FROM layoff_staging2;

SET SQL_SAFE_UPDATES = 0;
-- updating the company column by using set function

UPDATE layoff_staging2
SET company = TRIM(company);

SELECT * FROM layoff_staging2;
-- CHECKING FOR Unique industry name.
SELECT DISTINCT industry FROM layoff_staging2;

-- found out some industry are same but have different name like one place it is given full name and other where it is given half name

SELECT * FROM layoff_staging2 where industry like 'crypto%';

-- we found out crypto has filled with full name so changing all to same name.

UPDATE layoff_staging2
SET industry = 'crypto'
WHERE industry like 'crypto%';

SELECT * FROM layoff_staging2 where industry like 'crypto%';

-- Now checking all otther columns to find duplicate names

SELECT DISTINCT location FROM layoff_staging2 ORDER BY 1;

SELECT DISTINCT country FROM layoff_staging2;

-- we found duplicates in country

SELECT distinct country, trim(TRAILING '.' FROM country) FROM layoff_staging2;

-- UPDATE THE COUNTRY WTH THE help of trim function trailing means remove at the end "."

UPDATE layoff_staging2 SET COUNTRY = TRIM(TRAILING '.' FROM country) WHERE country like 'United States%';

SELECT * FROM layoff_staging2;
SELECT DISTINCT country from layoff_staging2;

-- changing the datatype of date because as of now it is text.

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoff_staging2;

UPDATE layoff_staging2 SET `date` = str_to_date(`date`,'%m/%d/%Y');

SELECT * FROM layoff_staging2;

-- now changing the colum datatype using alter table function

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- LOOKING FOR NULL AND BLANK CELLS.

SELECT * FROM layoff_staging2 WHERE total_laid_off is NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoff_staging2 WHERE industry IS NULL OR industry = '';

-- filling the values in the null and blank

SELECT * FROM layoff_staging2 t1 
JOIN layoff_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- CHANGING BLANK VALUES INTO NULL VALUES

UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

SELECT * FROM layoff_staging2 WHERE industry ='';
SELECT * FROM layoff_staging2 WHERE industry IS NULL;

-- UPDATING NULL VALUE IN INDUSTRY COLUMN

UPDATE layoff_staging2 t1 
JOIN layoff_staging2 t2 
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND
t2.industry IS NOT NULL;

SELECT * FROM layoff_staging2;

SELECT * FROM layoff_staging2 WHERE industry is NULL;

SELECT* FROM layoff_staging2 WHERE company ='Airbnb';

-- removing the columns and rows.

SELECT * FROM layoff_staging2 WHERE total_laid_off is null and percentage_laid_off is null;

DELETE
FROM layoff_staging2 WHERE total_laid_off is null and percentage_laid_off is null;

SELECT * FROM layoff_staging2;

-- deleting the row_num column

ALTER TABLE layoff_staging2 DROP COLUMN row_num;







