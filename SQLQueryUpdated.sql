select *
from PortfolioProjects..CovidVaccinations
order by 3,4

select *
from CovidDeaths
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths

select location, date, total_cases, population, (total_cases/population) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
order by 1,2


--Total cases vs Population shows what % of population got Covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at countries with Highest Infection Rate compared  to Population

select location, population, MAX(total_cases) as HighestInfentionCount, Max((total_cases/population) * 100) as PercentagePopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc



--Showing countries with the Highest Death Count per Population

select location, Max(Total_deaths) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc



--Lets break things down by Continent


select continent, Max(Total_deaths) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing the continents with the Highest Death Count per Population

select continent, Max(Total_deaths) as HighestDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by HighestDeathCount desc


--GLOBAL NUMBERS

select date, SUM(new_cases), SUM(CAST(new_deaths as int)) 
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
--where continent is not null
where new_cases <> 0
group by date
order by 1,2


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
--where continent is not null
where new_cases <> 0
--group by date
order by 1,2



--Looking at Total Population vs Vaccinations

select *
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


select dea.continent, dea.date, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location)
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
where vac.new_vaccinations is not null
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
where vac.new_vaccinations is not null
order by 2,3


alter table CovidVaccinations
alter column new_vaccinations float



--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
where vac.new_vaccinations is not null
--order by 2,3
)
Select * 
From PopvsVac



--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
where vac.new_vaccinations is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


 
 --Creating View to store data for  later visualizations

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--where vac.new_vaccinations is not null
--order by 2,3


select *
from PercentPopulationVaccinated