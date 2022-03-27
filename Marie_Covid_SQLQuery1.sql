select*
From PortfolioProject..['Covid_Deaths]
Where continent is not null
Order by 3,4



select*
From PortfolioProject..['Covid_Vaccinations]
Order by 3,4


select Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..['Covid_Deaths]
Order by 1,2

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100
as DeathPerc
From PortfolioProject..['Covid_Deaths]
Where continent is not null
--where location like '%states%'
Order by 1,2



select Location, date, Population, total_cases,(total_cases/population)*100
as DeathPerPop
From PortfolioProject..['Covid_Deaths]
Where continent is not null
--where location like '%states%'
Order by 1,2

select Location, date, Population, max(total_cases) as TopInfectionCount,
max((total_cases/population))*100 as
PercInfPop
Where continent is not null
From PortfolioProject..['Covid_Deaths]
group by Location, Population, date
order by PercInfPop desc


select Location, max(cast(total_deaths as int)) as DeathCount
From PortfolioProject..['Covid_Deaths]
Where continent is not null
group by Location
order by DeathCount desc

----Continent

select continent, max(cast(total_deaths as int)) as DeathCount
From PortfolioProject..['Covid_Deaths]
Where continent is not null
group by continent
order by DeathCount desc

-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPerc
From PortfolioProject..['Covid_Deaths]
Where continent is not null
--where location like '%states%'
--Group by date
Order by 1,2


--total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from PortfolioProject..['Covid_Deaths] dea
join PortfolioProject..['Covid_Vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)
as CumVacpop
--, (CumVacpop/population)*100
from PortfolioProject..['Covid_Deaths] dea
join PortfolioProject..['Covid_Vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3

--CTE

With VacvsPop (continent, location, date, population, New_vaccinations, CumVacpop)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)
as CumVacpop
--, (CumVacpop/population)*100
from PortfolioProject..['Covid_Deaths] dea
join PortfolioProject..['Covid_Vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select*,(CumVacpop/population)*100
From VacvsPop

---Table
Drop Table if exists #PercPopVac
Create Table #PercPopVac
(
continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumVacpop numeric)


Insert into #PercPopVac
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)
as CumVacpop
--, (CumVacpop/population)*100
from PortfolioProject..['Covid_Deaths] dea
join PortfolioProject..['Covid_Vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select*,(CumVacpop/population)*100
From #PercPopVac

---create a view for visualization

Create View PercPopVac as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date)
as CumVacpop
--, (CumVacpop/population)*100
from PortfolioProject..['Covid_Deaths] dea
join PortfolioProject..['Covid_Vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercPopVac
