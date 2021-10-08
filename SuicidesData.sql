-- Suicide Data Exploration (Incomplete)




-- Cleaning DATA

SELECT suicides_no, 
CASE 
WHEN suicides_no IS NULL THEN 0
ELSE suicides_no
END
FROM suicides


UPDATE suicides
SET suicides_no = CASE 
WHEN suicides_no IS NULL THEN 0
ELSE suicides_no
END


-- Select Data that we are going to be starting with

SELECT * FROM suicides



-- Counties with the most suicides 
-- Top 10 countries

SELECT country, sum(suicides_no)
FROM suicides
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10



-- Comparing Suicide v Populations
-- Countries with the highest suicide rate

SELECT country, sum(suicides_no), population, sum(suicides_no)/population*100 AS 'Suicide Rate'
FROM suicides
GROUP BY 1 
ORDER BY 4 DESC
LIMIT 10



-- Year with the most suicides
-- Top 10 

SELECT year, sum(suicides_no)
FROM suicides
GROUP BY 1 
ORDER BY 2 DESC



-- Yearly Suicides per country 
-- Using Partition By to gather Rolling Yearly Suicides

SELECT country, year, suicides_no, 
sum(suicides_no) OVER (PARTITION BY country ORDER BY year) AS 'RollingYearlySuicides'
FROM suicides
WHERE country LIKE 'United States%'
GROUP BY 1, 2



-- Age group with the most amount of suicides

SELECT age, sum(suicides_no)
FROM suicides
GROUP BY 1 
ORDER BY 2 DESC



-- Age group with the most amount of suicides per country
-- Using Partition

SELECT country, age, suicides_no, 
sum(suicides_no) OVER (PARTITION BY country ORDER BY age) AS 'SuicidesbyCountry'
FROM suicides
-- WHERE country LIKE 'United States%'
GROUP BY 1, 2



-- Yearly Suicide Rates per age group

Select year, age, sum(suicides_no), population, 
sum(suicides_no) OVER (PARTITION BY age ORDER BY Year)/population*100 AS 'RateperAge'
FROM suicides
-- WHERE country LIKE 'United States%'
GROUP BY 2, 1




