Select * From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4
--Select * From PortfolioProject..CovidVaccinations
--order by 3,4

Select location,date,total_cases,total_deaths,population 
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--People Affected
--Showes likehood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,
CONVERT(Decimal(15,3),total_deaths)/CONVERT(Decimal(15,3),total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%sates%'
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Showes what percentage of population got covid
Select location,date,total_cases,population,
(total_cases/population) *100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%united states
order by 1,2

--Looking at countries highest infection rate compared to population
--Which is country is highly infected 
Select location,population,Max(total_cases) as HighestInfectionCount,
MAX((total_cases/population)) *100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%united states%'
Group by location,population
order by PercentagePopulationInfected desc


--Showing Countries with highest death count per population
--total_deaths is nvarchar that why it showed different value, Converted into int
Select location,Max(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 
--Showing the contintents with highest death counts
Select continent,Max(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers  -- sum of new_cases add up to total_case
Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%sates%'
Where continent is not null
Group By date
order by 1,2

-- Global Numbers  
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%sates%'
Where continent is not null
order by 1,2

--Joining 2 tables 
Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 

-- Looking at Total Poplulation vs Vaccinations
--What is the total amount of people in the world that being Vaccinated 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3

-- Looking at Total Poplulation vs Vaccinations
--What is the total amount of people in the world that being Vaccinated 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3    


--USE CTE

With populationVsvaccination(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3    
)
Select * , (RollingPeopleVaccinated/population)*100
From populationVsvaccination

--TEMP TABEL
Drop Table if exists ##PrecentPopulationVaccinated
Create table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PrecentPopulationVaccinated

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3    

Select * , (RollingPeopleVaccinated/population)*100
From #PrecentPopulationVaccinated


---Creating View to store data for Visualization 
Create View PrecentPopulationVaccinated1 as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

Select *  
From  PrecentPopulationVaccinated1




