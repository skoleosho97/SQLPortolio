SELECT *
FROM ProjectB.dbo.CovidDeaths

-- Total Cases vs Total Deaths (US)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPct
FROM ProjectB.dbo.CovidDeaths
WHERE Location LIKE '%States%'
ORDER BY 1,2

-- Total Cases vs Population (US)
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS CasePct
FROM ProjectB.dbo.CovidDeaths
WHERE Location LIKE '%States%'
ORDER BY 1,2

-- Infection Rate
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPct
FROM ProjectB.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY InfectedPct DESC

-- Highest Death Count
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM ProjectB.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeaths DESC

-- Global Numbers
SELECT 
	date, 
	SUM(new_cases) AS TotalCases, 
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPct
FROM ProjectB.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Vaccinations

SELECT 
	death.continent, death.location, death.date, death.population, 
	vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPplVaccinated
FROM ProjectB.dbo.CovidDeaths death
JOIN ProjectB.dbo.CovidVaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- CTE

WITH PopvsVax (Continent, Location, Date, Population, New_vaccinations, RollingPplVaccinated)
AS 
(
SELECT 
	death.continent, death.location, death.date, death.population, 
	vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPplVaccinated
FROM ProjectB.dbo.CovidDeaths death
JOIN ProjectB.dbo.CovidVaccinations vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
)
SELECT *, (RollingPplVaccinated/Population)*100
FROM PopvsVax

-- Views

USE ProjectB
GO
CREATE VIEW PopsvsVax AS
WITH PopvsVax (Continent, Location, Date, Population, New_vaccinations, RollingPplVaccinated)
AS 
(
	SELECT 
		death.continent, death.location, death.date, death.population, 
		vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPplVaccinated
	FROM ProjectB.dbo.CovidDeaths death
	JOIN ProjectB.dbo.CovidVaccinations vax
		ON death.location = vax.location
		AND death.date = vax.date
	WHERE death.continent IS NOT NULL
)
SELECT *
FROM PopvsVax

SELECT *
FROM PopsvsVax