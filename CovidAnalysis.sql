SELECT*
FROM CovidDeathsMain
WHERE continent is not NULL
ORDER BY 3,4

-- SELECT *
-- FROM CovidDeathsMain
-- order by 3,4
-- Select Data that was are going to be using

SELECT location, total_cases, new_cases, total_deaths, population
FROM CovidDeathsMain
ORDER BY 1,2

-- looking at the Total Cases vs Total Deaths
-- shows the likely-hood of dying if you tracked covid in your country
SELECT location, date, total_cases,total_deaths, 
(CAST(total_deaths AS FLOAT)/total_cases)*100 AS DeathPercentage
FROM CovidDeathsMain
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got CovidDeathsMain

SELECT location, date, total_cases,population, 
(CAST(total_cases AS FLOAT)/population)*100 AS PercentPopulationInfected
FROM CovidDeathsMain
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infections Rate Compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, 
Max((CAST(total_cases AS FLOAT)/population)*100) AS PercentPopulationInfected
FROM CovidDeathsMain
--WHERE location LIKE '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- LET'S BREAK THINGS DOWN BYU CONTINENT

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeathsMain
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing countries with the Highess Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeathsMain
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS by DATE

SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, 
SUM(cast(new_deaths as FLOAT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeathsMain
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

-- GLOBAL NUMBERS TOTAL

SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, 
SUM(cast(new_deaths as FLOAT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeathsMain
WHERE continent is not NULL
ORDER BY 1,2

-- Joining Tables based on Locationa and Date

SELECT *
FROM CovidDeathsMain dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY  dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeathsMain dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeathsMain dea
join CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INTEGER))
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidDeathsMain dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *,
       (RollingPeopleVaccinated * 100.0 / population) AS PercentVaccinated
FROM PercentPopulationVaccinated
ORDER BY location, date;

--creating view to store data for later visualizations

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS INTEGER))
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM CovidDeathsMain dea
JOIN CovidVaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
