-- Data exploration project
-- Inspect the tables which include Covid related information on Austria, Italy, Sapin and UK 
SELECT * 
FROM portfolioproject.covidd_deaths_f
ORDER BY 3 , 4;

SELECT * 
FROM portfolioproject.covidd_vaccination_f
ORDER BY 3 , 4;

-- Select data that we are going to be using 
SELECT Location, date, total_cases,new_cases,total_deaths,population
FROM portfolioproject.covidd_deaths_f
ORDER BY 1;

-- Looking at the total cases vs total death 
-- Shows the mortality rate if infected with Covid
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject.covidd_deaths_f
ORDER BY 1;

-- Looking at the total cases vs total death only in Italy and Austria just out of curiosity
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject.covidd_deaths_f
WHERE Location IN ("Austria","Italy")
ORDER BY 1;

-- Looking at the total cases vs population 
-- Shows the percentage of population who got COVID 
SELECT Location, date,population, total_cases, (total_cases/population)*100 as InfectedRate
FROM portfolioproject.covidd_deaths_f
ORDER BY 1;

-- Find country with highest infection rate
SELECT Location, population, MAX(total_cases) as Highest_infection_count, MAX(total_cases/population)*100 as Percent_population_infected
FROM portfolioproject.covidd_deaths_f
GROUP  BY location
ORDER BY 4 DESC;

-- Showing country with highest death count. Also change datatype of total_deaths as currently it's assigned as varchar 
SELECT location, MAX(CAST(total_deaths AS signed)) as total_death_count
FROM portfolioproject.covidd_deaths_f
GROUP BY location
ORDER BY 2 DESC;

-- Total numbers of 4 countries 
SELECT  SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as signed)) as total_new_deaths , SUM(cast(new_deaths as signed))/SUM(new_cases) *100 as Tota_death_percentage
FROM portfolioproject.covidd_deaths_f as dea
ORDER BY 1 desc;

-- join the 2 tables
SELECT dea.location,dea.date,dea.population,vac.new_vaccinations
FROM covidd_deaths_f as dea
JOIN covidd_vaccination_f as vac
     ON dea.location = vac.location
     AND dea.date = vac.date;

-- Looking at total population vs Vaccination. Add column for cumulative new vaccination
SELECT dea.location,CAST(dea.date as date) as dates, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations,signed)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as cumulative_vaccine
FROM covidd_deaths_f as dea
JOIN covidd_vaccination_f as vac
     ON dea.location = vac.location
     AND dea.date = vac.date;
     
-- Find cumulative vaccinated number for each country
SELECT dea.location,CAST(dea.date as date) as dates, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations,signed)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as cumulative_vaccine
FROM covidd_deaths_f as dea
JOIN covidd_vaccination_f as vac
     ON dea.location = vac.location
     AND dea.date = vac.date;


-- USE CTE to find the total vaccinations per country 
with popvsvac (Location,population,new_vaccinations,cumulative_vaccine)
as
(
SELECT dea.location, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations,signed)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as cumulative_vaccine
FROM covidd_deaths_f as dea
JOIN covidd_vaccination_f as vac
     ON dea.location = vac.location
     AND dea.date = vac.date
     )
SELECT location,population, MAX(cumulative_vaccine) as total_vaccinated,MAX(cumulative_vaccine)/population as Percent_people_vaccinated
FROM popvsvac
GROUP BY location;

-- creating view to store data for later visualization
CREATE VIEW Cumulative_People_Vaccinated AS 
SELECT dea.location, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations,signed)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as cumulative_vaccine
FROM covidd_deaths_f as dea
JOIN covidd_vaccination_f as vac
     ON dea.location = vac.location
     AND dea.date = vac.date