
DROP TABLE IF EXISTS PercentPopulationVaccinated;


/* Initially exploring CovidDeaths data table */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at the Total Cases vs Total Deaths. The ratio/percentage.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage 
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Showing the likelihood of dying if you contract Covid-19 in the US.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage 
FROM coviddeaths
WHERE location like '%states%' 
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Let's us know the percentage of the population that have gotten Covid.
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS ContractedCovid
FROM coviddeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Finding out which country has the highest percentage infection rate (highest contractedcovid).
-- Looking at Countries with Highest Infection Rate compared to Population.
SELECT location, max(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS 
	PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Show countries with Highest Death Count per Population
SELECT location, max(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's break things down by continent.
SELECT continent, max(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Statistics
SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as
	DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date -- important for entire SELECT statement; otherwise you won't have anything to SUM if all are individual.
ORDER BY 1,2;

-- Global Death Ratio (excluding grouping by date which leads to the grand ratio since nothing to sum on).
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as
	DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



/* Joining With CovidVaccinations */

-- Setting up a guide table.
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Looking at New Vaccinations Per Day.
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,sum(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100 doesn't work due to just being created.
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



-- Using A CTE to arrive at Total Population / Total Vaccinations Per Country.
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,sum(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / population) * 100 
FROM PopVsVac;


-- Using A TEMP TABLE to arrive at Total Population / Total Vaccinations Per Country.
CREATE temporary table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,sum(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN  covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
SELECT *, (RollingPeopleVaccinated / population) * 100 
FROM PercentPopulationVaccinated;
