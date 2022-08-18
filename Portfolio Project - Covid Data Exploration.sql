SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
order by 1, 2;

-- Looking at the Total Cases vs Total Deaths
-- Show the likelihood of death by covid
SELECT location
	,date
	,total_cases
	,total_deaths
	,(total_deaths / total_cases) * 100
FROM portfolioproject.coviddeaths
-- where location = 'Vietnam'
order by 1, 2;

-- Show the percentage of getting covid
SELECT location
	,date
	,population
	,total_cases
	,(total_cases / population) * 100
FROM portfolioproject.coviddeaths
-- where location = 'Vietnam'
order by 1, 2;

-- Looking at countries with highest infection rate compared to population
SELECT location
	,population
	,max(cast(total_cases as signed)) as HighestInfectionCount
	,max(cast(total_cases as signed) / cast(population as signed)) * 100 as PopulationInfectedRate
FROM portfolioproject.coviddeaths
where continent != ""
group by location, population
order by 4 desc;

-- Showing countries with highest death count per population
SELECT location
	,max(cast(total_deaths as signed)) as TotalDeathCount
FROM portfolioproject.coviddeaths
where continent != ""
group by location
order by 2 desc;

-- Showing countries with highest number of case count
SELECT location
	,max(cast(total_cases as signed)) as TotalCasesCount
	,max(cast(total_deaths as signed)) as TotalDeathCount
FROM portfolioproject.coviddeaths
where continent != ""
group by location
order by 3 desc;

-- Showing continents with highest death count
SELECT continent
	,max(cast(total_deaths as signed)) as TotalDeathCount
FROM portfolioproject.coviddeaths
where continent != ""
and location not in ('Upper middle income', 'High income', 'Low income', 'Lower middle income')
group by continent
order by 2 desc;

-- Showing continents with highest death count per
SELECT continent
	,max(cast(total_deaths as signed)) as TotalDeathCount
FROM portfolioproject.coviddeaths
where continent != ""
group by continent
order by 2 desc;

-- Showing the daily new cases, new deaths and death percentage
SELECT date
	,sum(cast(new_cases as signed)) as NewCases
	,sum(cast(new_deaths as signed)) as NewDeaths
	,sum(cast(new_deaths as signed)) / sum(cast(new_cases as signed)) * 100 as DeathPercentage
FROM portfolioproject.coviddeaths
where continent != ""
and location not in ('Upper middle income', 'High income', 'Low income', 'Lower middle income')
group by date
order by 1;

-- Showing the total cases, total deaths and total death percentage
SELECT sum(cast(new_cases as signed)) as NewCases
	,sum(cast(new_deaths as signed)) as NewDeaths
	,sum(cast(new_deaths as signed)) / sum(cast(new_cases as signed)) * 100 as DeathPercentage
FROM portfolioproject.coviddeaths
where continent != ""
and location not in ('Upper middle income', 'High income', 'Low income', 'Lower middle income');

-- Looking at total vaccinations vs total population by countries
select dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccincations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent != ""
order by 2, 3;

-- Looking at daily new vaccinations vs total population by countries
select dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccincations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent != ""
order by 2, 3;

-- Looking at accumulated vaccinations daily vs total population by countries
with popvsvac as
(select dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
    ,sum(convert(vac.new_vaccinations, signed)) over (partition by location order by dea.date) as RollingVaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccincations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent != "")
select *
	,RollingVaccinations / cast(p.population as signed) as VacPerPopulation
from popvsvac p
order by p.location;

-- Create view to store data for visualization
Create view VaccinatedPopulationPercent as
select dea.continent
	,dea.location
    ,dea.date
    ,dea.population
    ,vac.new_vaccinations
    ,sum(cast(vac.new_vaccinations as signed)) over (partition by location order by dea.date) as RollingVaccinations
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccincations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent != "";