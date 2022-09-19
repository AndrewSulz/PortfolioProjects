-- SELECT *
-- FROM PortfolioProject1..CovidVaccinations
-- ORDER BY 3, 4

SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3, 4

-- Adding Column to Table
ALTER TABLE
  PortfolioProject1..CovidDeaths
ADD
  populations INT

-- Copying data from population column and converting it from a nvarchar(50) to an int and storing it in our new column
UPDATE
  PortfolioProject1..CovidDeaths
SET
  populations = TRY_CONVERT(int, population)

-- Dropping the old population column
ALTER TABLE
  PortfolioProject1..CovidDeaths
DROP COLUMN
  population

-- Renaming the new populations column to population
USE
  PortfolioProject1
GO
EXEC sp_rename 'CovidDeaths.populations', 'population', 'COLUMN'
GO

SELECT
  population
FROM
  PortfolioProject1..CovidDeaths

-- Select Data that we are going to be using
SELECT
  location, date, total_cases, new_cases, total_deaths, population
FROM 
  PortfolioProject1..CovidDeaths
ORDER BY
  1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT
  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM 
  PortfolioProject1..CovidDeaths
WHERE
  location like '%States%'
ORDER BY
  1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid
SELECT
  location, date, population, total_cases, (CAST(total_cases AS FLOAT)/population)*100 as CovidPercentage
FROM 
  PortfolioProject1..CovidDeaths
WHERE
  location like '%States%'
ORDER BY
  1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT
  location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float)/population)*100 as CovidPercentage
FROM 
  PortfolioProject1..CovidDeaths
GROUP BY
  location, population
ORDER BY
  CovidPercentage DESC

-- Looking at Countries with the Highest Death Rate compared to Population
SELECT
  location, population, MAX(total_deaths) AS HighestDeathCount, MAX((CAST(total_deaths AS float)/population))*100 as DeathPercentage
FROM 
  PortfolioProject1..CovidDeaths
WHERE 
  continent IS NOT NULL
GROUP BY
  location, population
ORDER BY
  DeathPercentage DESC

-- Looking at Countries with the Highest Death Count
SELECT
  location, MAX(total_deaths) AS HighestDeathCount
FROM 
  PortfolioProject1..CovidDeaths
WHERE 
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  HighestDeathCount DESC

-- Looking at Continents Highest Death Count
SELECT
  location, MAX(total_deaths) AS HighestDeathCount
FROM 
  PortfolioProject1..CovidDeaths
WHERE 
  continent IS NULL
GROUP BY
  location
ORDER BY
  HighestDeathCount DESC

-- Global Numbers
SELECT
  date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS float))/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage
FROM 
  PortfolioProject1..CovidDeaths
WHERE 
  continent IS NULL
GROUP BY
  date
ORDER BY
  1, 2

-- Total Cases and Death Percentage for the World
SELECT
  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS float))/NULLIF(SUM(new_cases), 0)*100 AS DeathPercentage
FROM 
  PortfolioProject1..CovidDeaths
WHERE 
  continent IS NOT NULL
ORDER BY
  1, 2

-- Looking at Total Population vs Vaccinations
SELECT
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
  PortfolioProject1..CovidDeaths dea
JOIN
  PortfolioProject1..CovidVaccinations vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  2, 3

-- Use CTE
-- See Total Vaccinations Rise by day by country
WITH PopvsVac AS
(
  SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
  FROM 
    PortfolioProject1..CovidDeaths dea
  JOIN 
    PortfolioProject1..CovidVaccinations vac
  ON 
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS TotalVaccinations
FROM PopvsVac

-- Create Temp Table
CREATE TABLE
  PortfolioProject1..PercentPopulationVaccinated
  (
    continent nvarchar(50),
    location nvarchar(50),
    date DATETIME,
    population INT,
    new_vaccinations INT,
    RollingPeopleVaccinated INT
  )

-- Inserting Information into our Table
INSERT INTO 
  PortfolioProject1..PercentPopulationVaccinated
SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM 
  PortfolioProject1..CovidDeaths dea
JOIN 
  PortfolioProject1..CovidVaccinations vac
ON 
  dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL

-- Showing Increase in Vaccinations by day for the United States
SELECT 
  *, (CAST(RollingPeopleVaccinated AS float)/population)*100 AS TotalVaccinated
FROM 
  PortfolioProject1..PercentPopulationVaccinated
WHERE 
  location = 'United States'
  AND new_vaccinations IS NOT NULL
ORDER BY 2,3

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM 
  PortfolioProject1..CovidDeaths dea
JOIN 
  PortfolioProject1..CovidVaccinations vac
ON 
  dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL

SELECT *
FROM PortfolioProject1..PercentPopulationVaccinatedView