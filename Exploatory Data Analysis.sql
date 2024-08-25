-- Exploratory Data Analysis

SELECT *
FROM layoffs_stagging2;

-- maximum laid_off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_stagging2;

-- percentage_laid_off
SELECT *
FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- company vs total_laid_off
SELECT company, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;

-- Date range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_stagging2;

-- Industries  VS total_laid_off
SELECT industry, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;

-- country vs total_laid_off
SELECT country, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY country
ORDER BY 2 DESC;

-- Yearly total_laid_off
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- company 'stage' vs total_laid
SELECT stage, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY stage
ORDER BY 2 DESC;

-- company vs percentage_laid_off
SELECT company, SUM(percentage_laid_off)
FROM layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;  -- * not very insightful I thnik

-- total_laid_off per month

SELECT SUBSTRING(`date`, 1,7) AS 'MONTH', SUM(total_laid_off)
FROM layoffs_stagging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- monthly rolling total_laid_off
WITH Rolling_total AS 
(
SELECT SUBSTRING(`date`, 1,7) AS 'MONTH', SUM(total_laid_off) AS total_off
FROM layoffs_stagging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, 
SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;

-- company yearly laid_off
SELECT company, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Ranking according to the highest laid_off company per year
WITH Company_yearly_laid_off (company, years, total_laid_off) AS
(

SELECT company, YEAR(`DATE`), SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY company, YEAR(`date`)
),
Company_Yearly_Rank AS
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Laid_off_rank
FROM Company_yearly_laid_off
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Yearly_Rank
WHERE Laid_off_rank <= 5; -- showing the first 5 highest laid_off per company per year

-- Industry laid_off ranking
SELECT industry, SUM(total_laid_off),
DENSE_RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS industry_rank
FROM layoffs_stagging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;

-- Findings
-- The period of laid_off understudy is from March 11th 2020 to March 6th 2023
-- Amazon has the highest laid_off of 18,150, followed by Google (12,000) and Meta(11,000)
-- Industries with the highest laid_off are Consumers, Retails and Transportation
-- United States has the highest laid_off (256559) followred by India (35993). Poland has the least (25)
-- According to the amalysis, Year 2022 recorded the highest laid_off (160,661). However, year 2023 laid_off could be more than 
-- year 2022 because it has recorded 125677 just for the first haof of the year which the data covered.
