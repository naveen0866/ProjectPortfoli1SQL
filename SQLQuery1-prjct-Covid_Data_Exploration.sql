select *
from Portfolio_Project..CovidDeaths
order by 3,4

--select *
--from Portfolio_Project..CovidVaccination
--order by 3,4


--select data that we are going to be using

select location,[date], total_cases, new_cases,total_deaths,[population]
from Portfolio_Project..CovidDeaths
order by 1,2

----looking_at_totalcases---VS---TotalDeaths

select location,[date], total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as Death_Rate
from Portfolio_Project..CovidDeaths
where location = 'United States'
order by 1,2

----
--india
select location,[date], total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as Death_Rate
from Portfolio_Project..CovidDeaths
where location = 'India'
order by 1,2

--looking-at-total-cases-vspopulation
--show-the-total-population-who-got-covid
select location,[date], total_cases,[population],(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
where location = 'United States'
order by 1,2

---Looking-at-the-countries-with-highest-rate-of-infection

select location, [population],max(cast(total_cases as float)) as HighestinfectionCount,max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
Group by location, [population]
order by PercentPopulationInfected desc

---verification for highest of infections
select location, max(cast(total_cases as float)) as highest
from Portfolio_Project..CovidDeaths
where location = 'Cyprus'
Group by location

---Looking-at-the-countries-with-highest-deaths

select location,max(cast(total_deaths as float)) as TotaldeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location
order by TotaldeathCount desc

-- Let's break things IN CONTINENT
--showing the continent with highest death count

select location,max(cast(total_deaths as float)) as TotaldeathCount
from Portfolio_Project..CovidDeaths
where continent is null
Group by location
order by TotaldeathCount desc

--Breaking to the global numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/Nullif(Sum(new_cases),0)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is null 
group by date
order by 1,2


----------------------
--Looking at Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition
by dea.location order by dea.location, dea.date) as [Rolling People Vaccinated]
from Portfolio_Project..CovidDeaths as dea 
join Portfolio_Project..CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


----Use CTE
with PopVsVac(Continent, Location, Date, Population, New_Vaccinations,[Rolling People Vaccinated])
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition
by dea.location order by dea.location, dea.date) as [Rolling People Vaccinated]
from Portfolio_Project..CovidDeaths as dea 
join Portfolio_Project..CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, ([Rolling People Vaccinated]/Population)*100
from PopVsVac


----Use Temp Table

--DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition
by dea.location order by dea.location, dea.date) as [Rolling People Vaccinated]
from Portfolio_Project..CovidDeaths as dea 
join Portfolio_Project..CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, ([RollingPeopleVaccinated]/Population)*100
from #PercentPopulationVaccinated


----create view to store data for later visuization
drop view PercentPopulationVaccinated
create view 
PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition
by dea.location order by dea.location, dea.date) as [Rolling People Vaccinated]
from Portfolio_Project..CovidDeaths as dea 
join Portfolio_Project..CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
go

select *
from PercentPopulationVaccinated
