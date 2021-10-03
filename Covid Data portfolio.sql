
-- Cleaning Covid deaths table

UPDATE covid.deaths
Set population = 1218333
WHERE location = 'Northern Cyprus'

UPDATE covid.deaths
Set population = 0
WHERE location = 'International'

ALTER TABLE covid.deaths
MODIFY population BIGINT

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population  
FROM covid.deaths
WHERE location LIKE '%states%'


-- Total Cases vs Total Deaths
-- Shows the moving mortality rate by day if you contract covid in your country

SELECT location, date, (total_deaths/total_cases)*100 AS CovidDeathRate
FROM covid.deaths
ORDER BY location, date



-- Total US Cases vs Population
-- Shows daily percentage of the population is infected with Covid in the US

SELECT location, date, population, (total_cases/population)*100 AS PercentageofInfection
FROM covid.deaths
WHERE location LIKE '%states%'
ORDER BY location, date



-- Countries with Highest Infection Rate compared to Population

SELECT location, date, population, MAX(total_cases) AS CurrentInfectionCount, MAX(total_cases/population)*100 AS PercentageofInfection
FROM covid.deaths
GROUP BY location, population
ORDER BY PercentageofInfection DESC



-- Countries with Highest Death Percentage per Population

SELECT location, population, MAX(total_deaths/population)*100 AS DeathPercentage
FROM covid.deaths
WHERE continent IS NOT NULL && continent NOT LIKE 'NULL'
GROUP BY location
ORDER BY DeathPercentage DESC



-- Countries with Highest Death Count per Population

SELECT location, population, SUM(new_deaths) AS TotalDeathCount
FROM covid.deaths
-- WHERE continent IS NOT NULL && continent NOT LIKE 'NULL'
GROUP BY location, population
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, SUM(new_deaths) AS TotalDeaths
FROM covid.deaths
WHERE continent IS NOT NULL && continent NOT LIKE 'NULL'
GROUP BY continent
ORDER BY TotalDeaths DESC




-- GLOBAL NUMBERS by total cases, total deaths, and Covid Mortality Rate

SELECT continent, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS CovidDeathRate 
FROM covid.deaths
WHERE continent IS NOT NULL && continent NOT LIKE 'NULL'
GROUP BY continent
ORDER BY CovidDeathRate desc




-- Joining Deaths and Vaccination tables

-- Cleaning data 

UPDATE covid.vacs
Set people_vaccinated = 0
-- WHERE people_vaccinated = 'NULL'
WHERE people_vaccinated = NULL

ALTER TABLE covid.vacs
MODIFY people_vaccinated BIGINT

UPDATE covid.vacs
Set people_fully_vaccinated = 0
-- WHERE people_vaccinated = 'NULL'
WHERE people_vaccinated = NULL

ALTER TABLE covid.vacs
MODIFY people_fully_vaccinated BIGINT

ALTER TABLE covid.vacs
MODIFY people_fully_vaccinated BIGINT






-- Total Full and Partial Vaccinations by Population for each country


SELECT deaths.location, deaths.Population, MAX(people_vaccinated) AS 'At Least PartiallyVaccinated',  MAX(people_fully_vaccinated) AS FullyVaccinated, (MAX(people_fully_vaccinated)/deaths.Population)*100 AS 'Full Vaccination%'
FROM covid.deaths
JOIN covid.vacs
ON deaths.location = vacs.location
and deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL && deaths.continent NOT LIKE 'NULL'
GROUP BY deaths.location
ORDER BY deaths.population DESC
LIMIT 5


-- Creating views
-- Death count per continent
-- vaccinated count per country
-- vac% for top 10 most populated country
-- mortality rate per country




