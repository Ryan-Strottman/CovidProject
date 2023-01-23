Select *
FROM Covidproject.dbo.CovidDeaths
where continent is not null
order by 3,4

Select *
FROM Covidproject.dbo.CovidVaccinations
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
FROM Covidproject.dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows chance of dying if contracting covid in your country

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Covidproject.dbo.CovidDeaths
Where location like '%united states%'
order by 1,2

--Total cases vs Population
--% of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Covid_Percentage
FROM Covidproject.dbo.CovidDeaths
Where location like '%united states%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM Covidproject.dbo.CovidDeaths
Group by population, location
order by Percent_Population_Infected desc


--Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Covidproject.dbo.CovidDeaths
where continent is not null
Group by location
order by Total_Death_Count desc

--Breakdown by continent with highet death rate

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Covidproject.dbo.CovidDeaths
where continent is not null
Group by continent
order by Total_Death_Count desc

--Global numbers by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as Death_Percentage -- total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Covidproject.dbo.CovidDeaths
--Where location like '%united states%'
where continent is not null
Group by date
order by 1,2

--Global number totals

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as Death_Percentage -- total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Covidproject.dbo.CovidDeaths
--Where location like '%united states%'
where continent is not null
--Group by date
order by 1,2

--Joined coviddeaths and covidvax
-- Rolling Vax Count

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CAST(vax.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vax_Count
FROM Covidproject.dbo.CovidDeaths dea
JOIN Covidproject.dbo.CovidVaccinations vax
	On dea.location = vax.location 
	and dea.date = vax.date
WHERE dea.continent is not null
Order by 2,3




--Using CTE

With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vax_Count) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(int,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vax_Count
FROM Covidproject.dbo.CovidDeaths dea
JOIN Covidproject.dbo.CovidVaccinations vax
	On dea.location = vax.location 
	and dea.date = vax.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT * , (Rolling_Vax_Count/Population)*100 as Rolling_Vax_Percentage
FROM PopvsVax



--Temp Table

Drop Table if exists #PercentPopulationVaccinated --add to make alterations 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vax_Count numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(int,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vax_Count
FROM Covidproject.dbo.CovidDeaths dea
JOIN Covidproject.dbo.CovidVaccinations vax
	On dea.location = vax.location 
	and dea.date = vax.date
WHERE dea.continent is not null
--Order by 2,3

SELECT * , (Rolling_Vax_Count/Population)*100 as Rolling_Vax_Percentage
FROM #PercentPopulationVaccinated


--View Creation to store data for later visualizations

Create View PercentPopVax as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(int,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vax_Count
FROM Covidproject.dbo.CovidDeaths dea
JOIN Covidproject.dbo.CovidVaccinations vax
	On dea.location = vax.location 
	and dea.date = vax.date
WHERE dea.continent is not null
--Order by 2,3
