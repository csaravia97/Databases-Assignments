\pset footer off

CREATE TEMP TABLE awesome_fundamentals AS 
	SELECT 
		a.*
	FROM fundamentals a
		INNER JOIN high_performers b
			ON a.symbol = b.symbol
	ORDER BY a.symbol;

-- Networth Query growth year-over-year

CREATE TEMP TABLE net_worth_growth_table AS 
	SELECT 
		symbol,
		year,
		((totalassets - totalliabilities)::NUMERIC/LEAD (totalassets - totalliabilities) OVER (
			PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS net_worth_growth
	FROM awesome_fundamentals;

-- Not much companies that have 50% growth from the 50 companies I choose
\echo '\n Companies with more than 50% net worth growth \n'
 SELECT
	symbol,
	COUNT(symbol)
FROM net_worth_growth_table
WHERE net_worth_growth > .5
GROUP BY symbol;


-- Net Income Growth 

CREATE TEMP TABLE net_income_growth_table AS
	SELECT 
		symbol,
		year,
		(netincome::NUMERIC/LEAD (netincome) OVER (
			PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS net_income_growth
	FROM awesome_fundamentals;

-- Possible factor, seems to be a common factor from the awesome companies I chose
\echo '\n Companies with more than 2% net income growth \n'
 SELECT
	symbol,
	COUNT(symbol)
FROM net_income_growth_table
WHERE net_income_growth > .02
GROUP BY symbol;


-- Net Revenue Growth 

CREATE TEMP TABLE net_revenue_growth_table AS
	SELECT 
		symbol,
		year,
		(totalrevenue::NUMERIC/LEAD(totalrevenue) OVER (
			PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS net_revenue_growth
		FROM awesome_fundamentals;

-- Possible factors seems like a similarity between this companies have about 0-50% net revenue growth
\echo '\n Companies with 0-50% net revenue growth\n'
SELECT
	symbol,
	COUNT(symbol)
FROM  net_revenue_growth_table
WHERE  net_revenue_growth BETWEEN 0 AND .5
GROUP BY symbol;


-- EPS Growth

CREATE TEMP TABLE eps_growth_table AS 
	SELECT 
		symbol,
		year,
		(earningpershare::NUMERIC/LEAD(earningpershare) OVER (
			PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS eps_growth
	FROM awesome_fundamentals;

-- Possible factor
\echo '\nCompanies with more than 15% eps growth\n'
 SELECT
	symbol,
	COUNT(symbol)
FROM eps_growth_table
WHERE eps_growth > .15
GROUP BY symbol;

-- Price-to-earnings ratio

CREATE TEMP TABLE price_to_earning_ratio_table AS
	SELECT
		a.symbol,
		a.yearending,
		a.earningpershare,
		b.close,
		(b.close/a.earningpershare)::NUMERIC(10,2) AS price_to_earning_ratio
	FROM awesome_fundamentals a
		INNER JOIN prices b
			ON a.yearending = b.date AND a.symbol = b.symbol
	ORDER BY a.symbol;

-- returnd about 20 companies lower than the other ones
\echo '\nCompanies with more than 19 avg pe ration\n'
SELECT
	symbol, 
	AVG(price_to_earning_ratio) AS avg_pe_ratio
FROM price_to_earning_ratio_table
GROUP BY symbol
HAVING AVG(price_to_earning_ratio) > 19
ORDER BY symbol;


-- Liquid Asset vs Liabilities Ratio 

CREATE TEMP TABLE liabilities_to_assets_ratio_table AS
	SELECT
		symbol,
		year,
		(totalliabilities::NUMERIC/cashandcashequiv) AS liabilities_to_assets_ratio
	FROM awesome_fundamentals;

\echo '\nCompanies with more than 2 liabilities_to_assets_ratio\n'
SELECT
	symbol, 
	AVG(liabilities_to_assets_ratio)::NUMERIC(10,2) AS avg_liabilities_to_assets_ratio
FROM liabilities_to_assets_ratio_table
GROUP BY symbol
HAVING AVG(liabilities_to_assets_ratio) > 2
ORDER BY symbol;


-- Factors chosen net_income_growth, net_revenue_growth, and eps_growth since these factors 
-- returned the most companies after the above queries

CREATE TEMP TABLE potential_candidates AS 
	SELECT
		symbol,
		(netincome::NUMERIC/LEAD (netincome) OVER (
				PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS net_income_growth,
		(totalrevenue::NUMERIC/LEAD(totalrevenue) OVER (
				PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS net_revenue_growth,
		(earningpershare::NUMERIC/LEAD(earningpershare) OVER (
				PARTITION BY symbol ORDER BY year DESC))::NUMERIC(10,2) - 1 AS eps_growth
	FROM fundamentals
	WHERE year BETWEEN 2015 AND 2016
	ORDER BY symbol;

\echo '\nPotential Candidates\n'
SELECT 
	symbol,
	company,
	sector
FROM securities
WHERE symbol IN (SELECT
	symbol
FROM potential_candidates
WHERE net_income_growth > .02 AND net_revenue_growth BETWEEN 0 AND .5 AND eps_growth > .15
GROUP BY symbol)
ORDER BY sector;


-- Query to get the top two companies in the health care sector
\echo '\nPicked Companies in the health care sector\n'
SELECT
	a.symbol
FROM potential_candidates a
	INNER JOIN securities b
		ON a.symbol = b.symbol
WHERE net_income_growth > .02 AND net_revenue_growth BETWEEN .06 AND .5 AND eps_growth > .2 AND b.sector = 'Health Care';


-- Query to get the top two companies in the Industrial sector
\echo '\nPicked Companies in the Industrials sector\n'
SELECT
	a.symbol
FROM potential_candidates a
	INNER JOIN securities b
		ON a.symbol = b.symbol
WHERE net_income_growth > .02 AND net_revenue_growth BETWEEN 0 AND .5 AND eps_growth > .3 AND b.sector = 'Industrials';


-- Query to get the top two companies in the IT sector
\echo '\nPicked Companies in the IT sector\n'
SELECT
	a.symbol
FROM potential_candidates a
	INNER JOIN securities b
		ON a.symbol = b.symbol
WHERE net_income_growth > .05 AND net_revenue_growth BETWEEN .1 AND .5 AND eps_growth > .38 AND b.sector = 'Information Technology';

-- 10 Companies I chose are

/* 
	1.  DIS
	2. 	DHI
	3.	SJM
	4.	SYY

	I choose the top four companies based on the factors I have above and also since the first 2 companies 
	are the only ones in Consumer Discretionary and the last two companies are from  Consumer Staples.
	
	5.	BDX
	6.	MCK

	I chose these companies based on the modified query I have to get rid of some of the other sectors in Health Care
	by chaning net revenue growth and eps growth.

	7.	FDX
	8.	CTAS

	I chose these companies based on the modifed query I had which increase the eps growth to 30% in the Industrial Sector
	
	9.	INTU
	10.	LRCX

	Same idea I had above, In order to get only have 2 company in the IT industry sector, I gradually incrase eps growth
	net revenue growth and net income growth until I only have 2 company.

*/