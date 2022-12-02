select *
from portfolio-project001.Covid_Data.CovidDeaths
Where continent is not null 
order by 3,4

Select *
from portfolio-project001.Covid_Data.CovidVaccinations
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

select Location, date, total_cases, new_cases, total_deaths, population
from portfolio-project001.Covid_Data.CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio-project001.Covid_Data.CovidDeaths
Where location like '%states%'
 and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From  portfolio-project001.Covid_Data.CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From   portfolio-project001.Covid_Data.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From   portfolio-project001.Covid_Data.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From   portfolio-project001.Covid_Data.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From   portfolio-project001.Covid_Data.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolio-project001.Covid_Data.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at total population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,( RollingPeopleVaccinated/population)*100
FROM portfolio-project001.Covid_Data.CovidDeaths dea
JOIN portfolio-project001.Covid_Data.CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio-project001.Covid_Data.CovidDeaths dea
Join portfolio-project001.Covid_Data.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table Percent_Population_Vaccinated
(
  Continent nvarchar (255),
  Location nvarchar (255),
  Date numeric,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolio-project001.Covid_Data.CovidDeaths dea
Join portfolio-project001.Covid_Data.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CO(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio-project001.CovidDeaths dea
Join portfolio-project001.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
