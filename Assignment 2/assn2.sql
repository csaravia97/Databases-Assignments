--  Is this database in Normal Form?

	-- This database is in Normal Form.


-- If so, which one is it in?  1NF, 2NF, 3NF? If not, what is preventing it from being normalized?  Can it be normalized? 
	-- It is in 3NF because each row in each table is unique and contains only a single value, therefore it is at least 1NF. 
	-- We know it's 2NF because 2 of the tables contain only one primary and table 3, which has a composite key, has no partial
	-- dependencies since you need both parts of the key to determine the other two columns. Finally, we know it's 3NF since it 
	-- contains no transitive dependencies. 



\pset footer off
-- 1.  What are the top ten countries by economic activity (Gross National Product - ‘gnp’).
		SELECT name,gnp 
		FROM country 
		ORDER BY gnp DESC 
		LIMIT 10;

-- 2.  What are the top ten countries by GNP per capita? (watch out for division by zero here !)
		SELECT name, (gnp/population) AS GNP_per_capita 
		FROM country
		WHERE population <> 0
		ORDER BY GNP_per_capita DESC
		LIMIT 10; 

-- 3.  What are the ten most densely populated countries, and ten least densely populated countries? 
		SELECT name, (population/surfacearea) AS population_density
		FROM country 
		WHERE surfacearea <> 0
		ORDER BY population_density DESC
		LIMIT 10;
		

		SELECT name, (population/surfacearea) AS population_density
		FROM country 
		WHERE surfacearea <> 0
		ORDER BY population_density ASC
		LIMIT 10;

-- 4. What different forms of government are represented in this data? (‘DISTINCT’ keyword should help here.)
		SELECT DISTINCT governmentform 
		FROM country;

	-- Which forms of government are most frequent? (distinct, count, group by order by)
		SELECT governmentform, COUNT(*)
		FROM country
		GROUP BY governmentform
		ORDER BY COUNT(*) DESC
		LIMIT 10;
-- 5.  Which countries have the highest life expectancy?  (watch for NULLs). 
		SELECT name, lifeexpectancy 
		FROM country 
		WHERE lifeexpectancy IS NOT NULL
		ORDER BY lifeexpectancy DESC
		LIMIT 10;

-- 6.  What are the top ten countries by total population, and what is the official language spoken there? (basic inner join) 
		SELECT A.name, A.population,  B."language"
		FROM country A
			INNER JOIN countrylanguage B
			ON A.code = B.countrycode
			WHERE  B.isofficial
			ORDER BY A.population DESC 
			LIMIT 10;

-- 7.  What are the top ten most populated cities – along with which country they are in, and what continent they are on?  (basic inner join)
		SELECT A.name AS city_name,A.population AS city_population, B.name AS country_name, B.continent
		FROM city A 
			INNER JOIN country B
			ON A.countrycode = B.code
			ORDER BY A.population DESC
			LIMIT 10;

-- 8.  What is the official language of the top ten cities you found in Question #7? (three-way inner join). 
		SELECT A.name AS city_name,A.population AS city_population, C."language", B.name AS country_name, B.continent
		FROM city A 
			INNER JOIN country B
			ON A.countrycode = B.code
			INNER JOIN countrylanguage C
			ON B.code = C.countrycode
			WHERE C.isofficial
			ORDER BY A.population DESC
			LIMIT 10;

-- 9.  Which of the cities from Question #7 are capitals of their country? (requires a join and a subquery). 
		SELECT A.name AS city_name 
		FROM city A 
			INNER JOIN country B 
			ON A.id = B.capital
			WHERE A.name IN (
				SELECT A.name AS city_name
				FROM city A 
					INNER JOIN country B
					ON A.countrycode = B.code
					ORDER BY A.population DESC
					LIMIT 10);

-- 10. For the cities found in Question#7, what perentage of the country’s population lives in the capital city?  (watch your int’s vs floats !). 
		SELECT A.name AS city, B.name AS country, (A.population::FLOAT/B.population::FLOAT)*100 AS percent_pop_in_capital 
		FROM city A INNER JOIN country B ON A.countrycode = B.code
		WHERE A.name IN(
		SELECT A.name AS city_name 
		FROM city A 
			INNER JOIN country B 
			ON A.id = B.capital
			WHERE B.name IN (
					SELECT B.name AS city_name
					FROM city A 
					INNER JOIN country B
					ON A.countrycode = B.code
					ORDER BY A.population DESC
					LIMIT 10
				))
		ORDER BY percent_pop_in_capital DESC;


