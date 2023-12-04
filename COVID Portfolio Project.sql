SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

----Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths (Shows likelihood of dying if you contract covid in Portugal)
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Portugal' and continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'Portugal' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking with countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(ROUND((total_cases/population)*100,2)) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking with continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Looking with countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers by date
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, ROUND((SUM(CAST(new_deaths as int))/SUM(New_Cases)),4)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Global numbers
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, ROUND((SUM(CAST(new_deaths as int))/SUM(New_Cases)),4)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinations) AS 
(SELECT cd.continent, 
	   cd.location, 
	   cd.date, 
	   cd.population, 
	   cv.new_vaccinations, 
	   SUM(CAST(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER  BY cd.location, cd.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL)

-- Looking at Total Population vs Vaccinations 
SELECT *, ROUND((TotalVaccinations/Population),4) * 100 AS PercentPopulationVaccinated
FROM PopvsVac
ORDER BY Location ASC, Date ASC

-- Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric)

INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, 
	   cd.location, 
	   cd.date, 
	   cd.population, 
	   cv.new_vaccinations, 
	   SUM(CAST(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER  BY cd.location, cd.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

-- Looking at Total Population vs Vaccinations 
SELECT *, CAST( (ROUND((TotalVaccinations/Population),4) * 100) as float) AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated
ORDER BY Location ASC, Date ASC

-- Creating View to store data for later visualizations

CREATE VIEW ViewPercentPopulationVaccinated AS
SELECT cd.continent, 
	   cd.location, 
	   cd.date, 
	   cd.population, 
	   cv.new_vaccinations, 
	   SUM(CAST(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER  BY cd.location, cd.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM ViewPercentPopulationVaccinated