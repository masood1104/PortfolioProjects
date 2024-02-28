-- select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from ProjectPortfolio..CovidDeaths
order by 1,2

-- looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,
CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like '%states%'
order by 1,2


-- total Cases vs Population
--shows what percentage of population got COVID

select location,date,total_cases,population,
CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population)))*100 as PerecentPopulationInfected 
from ProjectPortfolio..CovidDeaths
where location like '%states%'
order by 1,2


--Countries with highest infection rates compared to populations

select location,population, max(total_cases) as HighestInfectionCount,
max(CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population))))*100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

--showing countries with the highest Death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null 
group by location
order by totalDeathCount desc

-- Breaking thing down by the contients


--Continent with the highest death count

select continent , max(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null 
group by continent
order by totalDeathCount desc


-- Global numbers
select 
sum(cast(new_cases as int)) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(nullif(new_deaths,0))/sum(nullif(new_cases,0))*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- total Population vs Vaccinations while using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea 
join ProjectPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE 
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea 
join ProjectPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea 
join ProjectPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated