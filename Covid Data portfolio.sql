-- Covid 19 Data Exploration 
-- Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


-- Cleaning Covid deaths table

UPDATE covid.deaths
Set population = 1218333
WHERE location = 'Northern Cyprus'

UPDATE covid.deaths
Set population = 0
WHERE location = 'International'

ALTER TABLE covid.deaths
MODIFY population BIGINT

UPDATE covid.deaths
Set total_deaths = 0
WHERE total_deaths = 'NULL'

ALTER TABLE covid.deaths
MODIFY total_deaths BIGINT

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



-- Total Deaths vs Total People Fully Vaccinated
-- Using Partition by to rolling coivd deaths and covid vaccinations

SELECT deaths.location, deaths.date, people_fully_vaccinated, new_deaths,
SUM(new_deaths) OVER (Partition by deaths.location ORDER BY deaths.date) AS RollingDeaths,
MAX(people_fully_vaccinated) OVER (Partition by deaths.location ORDER BY deaths.date) AS 'RollingPeopleFullyVaccinated'
FROM covid.deaths
JOIN covid.vacs
ON deaths.location = vacs.location
and deaths.date = vacs.date
-- WHERE deaths.location LIKE 'United States'
WHERE deaths.continent IS NOT NULL && deaths.continent NOT LIKE 'NULL'



-- Full Vaccination% by Population for each country
-- Showing rolling vaccination percentage

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, people_fully_vaccinated,
MAX(people_fully_vaccinated) OVER (Partition by deaths.location ORDER BY deaths.date) AS 'RollingPeopleFullyVaccinated',
(MAX(people_fully_vaccinated) OVER (Partition by deaths.location ORDER BY deaths.date)/deaths.population)*100 AS 'RollingVaccinated%'
FROM covid.deaths
JOIN covid.vacs
ON deaths.location = vacs.location
and deaths.date = vacs.date
-- WHERE deaths.location LIKE 'United States'
WHERE deaths.continent IS NOT NULL && deaths.continent NOT LIKE 'NULL'
ORDER BY 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists PopulationVacPercentage
CREATE TABLE PopulationVacPercentage( 
continent VARCHAR(50) ,
location VARCHAR(50) ,
date DATETIME ,
population BIGINT ,
people_fully_vaccinated INT,
RollingPeopleVaccinated INT
)

INSERT INTO PopulationVacPercentage
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, people_fully_vaccinated,
MAX(people_fully_vaccinated) OVER (Partition by deaths.location ORDER BY deaths.date) AS 'RollingPeopleFullyVaccinated'
-- (MAX(people_fully_vaccinated) OVER (Partition by deaths.location ORDER BY deaths.date)/deaths.population)*100 AS 'RollingVaccinated%'
FROM covid.deaths
JOIN covid.vacs
ON deaths.location = vacs.location
and deaths.date = vacs.date
-- WHERE deaths.location LIKE 'United States'
WHERE deaths.continent IS NOT NULL && deaths.continent NOT LIKE 'NULL'
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM  PopulationVacPercentage 
-- WHERE location LIKE 'United States'


-- USING Temp Table to show relationship between Population, Covid Deaths, and People Fully Vaccinated

SELECT deaths.location, PopulationVacPercentage.date, PopulationVacPercentage.population,PopulationVacPercentage.people_fully_vaccinated, PopulationVacPercentage.RollingPeopleVaccinated, 
(RollingPeopleVaccinated/PopulationVacPercentage.population)*100 AS 'RollingVaccinated%', new_deaths, 
SUM(new_deaths) OVER (Partition by deaths.location ORDER BY deaths.date) AS RollingDeaths,
(SUM(new_deaths) OVER (Partition by deaths.location ORDER BY deaths.date)/PopulationVacPercentage.population)*100 AS 'RollingDeath%'
FROM PopulationVacPercentage
JOIN covid.deaths
ON deaths.date = PopulationVacPercentage.date
and deaths.location = PopulationVacPercentage.location
-- WHERE deaths.location LIKE 'United States'



-- Creating views for Tableau Dashboard

-- Death count per continent

SELECT continent, sum(new_deaths) AS 'Total Deaths' 
FROM covid.deaths
WHERE continent NOT LIKE 'NULL'
GROUP BY continent


-- Total Fully vaccinated count per country

SELECT location, MAX(RollingPeopleVaccinated) AS 'People Fully Vaccinated' 
FROM PopulationVacPercentage 
GROUP BY location


-- Population vaccinated for top 10 most populated countries

SELECT location, population, MAX(RollingPeopleVaccinated/population)*100  AS '% Vaccinated'
FROM  PopulationVacPercentage 
GROUP BY location
ORDER BY population DESC
Limit 10

-- Covid mortality rate per country

SELECT location, population, MAX(total_deaths) AS TotalDeaths, SUM(new_cases) AS 'Total Infected', 
(MAX(total_deaths)/SUM(new_cases))*100 AS 'Mortality Rate'
FROM covid.deaths
GROUP BY location, 'Mortality Rate'
ORDER BY 'Mortality Rate'

 


