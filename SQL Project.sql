

Select *
From PortfolioProject..covid_deaths$
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..covid_vaccinations$
--Order by 3,4


-- Select Data to be used


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths$
order by 1,2


-- Total Cases vs Total Deaths
-- Shows overall deathrate by country and date
Select location, date, total_cases, total_deaths, (cast(total_deaths as numeric)/ cast(total_cases as numeric))*100 as DeathPercentage
From PortfolioProject..covid_deaths$
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population that contracted COVID-19

Select location, date, population, total_cases, (total_cases/population)*100 as ContractedPercentage
From PortfolioProject..covid_deaths$
--Where location like '%states%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths$
Group by location,population
order by PercentPopulationInfected desc


-- Showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is not null
Group by location
order by TotalDeathCount desc



-- Break down by continent


Select location, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..covid_deaths$
Where continent is not null
Group by date
Order by 1,2


--Overall total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..covid_deaths$
Where continent is not null
Order by 1,2


-- Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2,3


-- Practice CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinations/population)*100
From PopvsVac


-- Temp Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date =vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinations/population)*100
From #PercentPopulationVaccinated



--Creating View to store for future viz


USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated