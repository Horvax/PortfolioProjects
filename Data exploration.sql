SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%russia'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (cast(total_cases as float)/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%russia'
order by 1,2


-- looking at countries with highest infection rate compared to population

SELECT Location, (MAX(cast(total_cases as float))) as HighestInfectionRate, population, (MAX(cast(total_cases as float))/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%russia'
Group by Location, population
order by InfectionPercentage desc


-- Showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%finland'
Group by Location
order by TotalDeathCount desc


--Showing the continents with the highest death count per population

--SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
----Where location like '%finland'
--Group by continent
--order by TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
--Where location like '%finland'
Group by location
order by TotalDeathCount desc



--  GLOBAL NUMBERS

Select date, SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Merging two tables together


select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.location and dea.date = vac.date


-- Looking at Total Population vs Vaccinations cumulated der date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac
--Where location = 'albania'
Order by 2,3



-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
