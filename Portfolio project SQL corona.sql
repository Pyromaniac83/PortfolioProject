
-- TOTAL CASES VS Total Deaths

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 death_percentage
FROM PortfolioProject..deaths
WHERE location = 'Egypt' AND continent IS NOT NULL
ORDER BY 1,2

-- Highest infection rates
SELECT Location,Population,MAX(total_cases) AS HighestInfetionCount, MAX((total_cases/population)*100) AS max_percentage
FROM PortfolioProject..deaths
WHERE continent IS NOT NULL
GROUP BY Location,Population
ORDER BY 4 DESC

-- Total deaths
SELECT location,MAX(cast(total_deaths as int)) death_rate
FROM PortfolioProject..deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- CONTINENT analysis
-- CONTINENT deaths
SELECT LOCATION, MAX(cast(total_deaths as int)) death_per_continent
FROM PortfolioProject.dbo.deaths
WHERE CONTINENT IS NULL
GROUP BY location 
ORDER BY 2 DESC

--GLOBAL daily Numbers
SELECT date, SUM(new_cases) new_cases, SUM(CAST(new_deaths as INT)) new_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 DeathPercentage
FROM PortfolioProject..deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 2 DESC
--
-- Vaccinated people vs population

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS INT)) OVER ( PARTITION BY dea.location ORDER BY dea.location, dea.date) total_vaccinations_over_time
FROM PortfolioProject..vaccines vacc
JOIN PortfolioProject..deaths dea
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- CTE to calculate running percentage of vaccinated people vs total population

WITH VaccPop (continent, location, data,Population, newVacc, totVacc) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS INT)) OVER ( PARTITION BY dea.location ORDER BY dea.location, dea.date) total_vaccinations_over_time
FROM PortfolioProject..vaccines vacc
JOIN PortfolioProject..deaths dea
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (totVacc/Population)*100
FROM VaccPop
ORDER BY 1 DESC
