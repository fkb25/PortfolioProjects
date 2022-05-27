Select*
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4 


--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3,4 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--looking at Total Cases vs Population
--Shows what percentage got Covid

Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2

--looking at countries with Highest Infection Rate Compared to Population
Select location,  Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, Population
Order by PercentagePopulationInfected desc

--Deaths by Continent
Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
Order by TotalDeathCount desc

--Showing Countries with Highest Death Count per Population
Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc


--Showing continents with the highest death counts per population
Select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Continent
Order by TotalDeathCount desc

--Global Numbers
Select Sum(total_cases) as total_cases, Sum(cast(new_deaths as int))as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
Order by 1,2

--looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--creating View to store date for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
from PercentPopulationVaccinated