--SELECT * FROM protfolioprojects..covidevaccinations
--ORDER BY 3,4

SELECT * FROM protfolioprojects..coviddeaths
where continent is not null
ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM protfolioprojects..coviddeaths
ORDER BY 1,2


-- Total cases vs Total deaths


SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercent
FROM protfolioprojects..coviddeaths
WHERE location like '%india%'
ORDER BY 1,2


-- total cases vs population
-- population got covid

SELECT location,date,total_cases, population, (total_cases/population)*100 as percentageofpopulation
FROM protfolioprojects..coviddeaths
--WHERE location like '%india%'
ORDER BY 1,2



-- higest infection compare to population

SELECT location,MAX(total_cases) AS higestinfectioncount, population, 
MAX(total_cases/population)*100 as percentinfection
FROM protfolioprojects..coviddeaths
--WHERE location like '%india%'
GROUP BY location,population
ORDER BY percentinfection DESC

--countries with higest death count per population

SELECT location,MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM protfolioprojects..coviddeaths
--WHERE location like '%india%'
where continent is not null
GROUP BY location 
ORDER BY totaldeathcount DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM protfolioprojects..coviddeaths
--WHERE location like '%india%'
where continent is not null
GROUP BY continent
ORDER BY totaldeathcount DESC

--gobal num

SELECT SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercent
FROM protfolioprojects..coviddeaths
where continent is not null
GROUP BY date
ORDER BY 1,2


-- looking total population vs vaccination


SELECT da.continent, da.location,da.date, da.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by da.location ORDER BY
da.location, da.date) as rollingpeoplvaccination
FROM protfolioprojects..coviddeaths da
join protfolioprojects..covidevaccinations vac
 on da.location = vac.location
 and da.date = vac.date
 where da.continent is not null
 ORDER BY 2,3



 -- cte  
 WITH popvsvac (continent, location, date, population,new_vaccinations,
 rollingpeoplvaccination)
 as (
SELECT da.continent, da.location,da.date, da.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by da.location ORDER BY
da.location, da.date) as rollingpeoplvaccination
FROM protfolioprojects..coviddeaths da
join protfolioprojects..covidevaccinations vac
 on da.location = vac.location
 and da.date = vac.date
 where da.continent is not null
 --ORDER BY 2,3
)


SELECT *, (rollingpeoplvaccination/population)*100 FROM popvsvac

-- tmp table

DROP TABLE if exists #perctnagepopulationvaccinated
CREATE Table #perctnagepopulationvaccinated

(

continent NVARCHAR(255),
location nvarchar(255),
DATE DATETIME,
Population numeric,
New_vaccinations numeric,
rollingpeoplvaccination numeric


)


INSERT INTO #perctnagepopulationvaccinated

SELECT da.continent, da.location,da.date, da.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by da.location ORDER BY
da.location, da.date) as rollingpeoplvaccination
FROM protfolioprojects..coviddeaths da
join protfolioprojects..covidevaccinations vac
 on da.location = vac.location
 and da.date = vac.date
 where da.continent is not null
 --ORDER BY 2,3

 SELECT *, (rollingpeoplvaccination/population)*100 FROM 
 #perctnagepopulationvaccinated


 create view perctnagepopulationvaccinated as 
 SELECT da.continent, da.location,da.date, da.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by da.location ORDER BY
da.location, da.date) as rollingpeoplvaccination
FROM protfolioprojects..coviddeaths da
join protfolioprojects..covidevaccinations vac
 on da.location = vac.location
 and da.date = vac.date
 where da.continent is not null
 --ORDER BY 2,3

 SELECT * FROM perctnagepopulationvaccinated 