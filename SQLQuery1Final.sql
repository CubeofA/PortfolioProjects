
--Look at the Covid Deaths Dataset
SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Look at the Covid Vaccination Dataset
SELECT *
FROM PortfolioProject1..CovidVaccines
ORDER BY 3,4

--SELECT Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths in Philippines
SELECT location, date, total_cases, total_deaths, 
	 (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%Philippines%'
ORDER BY location, date

--Looking at Total Cases vs Population in Philippines
--Shows what percentage of population got COVID
SELECT location, date, population, total_cases, 
	 (cast(total_cases as float)/cast(population as float))*100 as Percent_Population_Infected
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%Philippines%'
ORDER BY DeathPercentage DESC

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS Highest_InfectionCount, 
	MAX((cast(total_cases as float)/cast(population as float))*100) AS Max_Population_Infected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_Population_Infected DESC

-- Showing Countries with Highest Death Count Per Population
SELECT location, population, MAX(total_cases) AS Highest_InfectionCount, 
	MAX((cast(total_cases as float)/cast(population as float))*100) AS Max_Population_Infected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_Population_Infected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--Let's break things down by Continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--Showing Continents with the HIGHEST Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--Global Numbers
SELECT  SUM(CAST(new_cases AS int)) AS SumNewCases, SUM(CAST(new_deaths AS int)) AS SumNewDeaths,
	(SUM(CAST(new_deaths AS float))/NULLIF(SUM(CAST(new_cases AS float)),0)) AS Death_Percentage
--total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date 
--ORDER BY date



-- Join 2 Tables
SELECT *
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccines AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date

-- Looking at Total Population VS. Vaccinations
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccines AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL
ORDER BY death.location, death.date

--Using CTE

With POPvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccines AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL
--ORDER BY death.location, death.date 
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM POPvsVac


--Temp Table
CREATE TABLE #PercentPopulationVaccinated
	( continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	RollingPeopleVaccinated numeric )

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccines AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL
--ORDER BY death.location, death.date 

SELECT *, (RollingPeopleVaccinated/population) *100
FROM #PercentPopulationVaccinated

--What if erasing 'WHERE death.continent IS NOT NULL' in the table?
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	( continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	RollingPeopleVaccinated numeric )

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccines AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
-- WHERE death.continent IS NOT NULL
--ORDER BY death.location, death.date 

SELECT *, (RollingPeopleVaccinated/population) *100
FROM #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
	SUM(CAST(vaxx.new_vaccinations AS float)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccines AS vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS NOT NULL

SELECT  *
FROM PercentPopulationVaccinated

