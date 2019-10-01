DROP TABLE IF EXISTS awesome_fundamentals;

CREATE TABLE awesome_fundamentals AS 
SELECT b.* FROM high_performers a INNER JOIN fundamentals b ON a.symbol = b.symbol; 

-- net worth growth

CREATE TEMP TABLE net_worth_growth AS
	SELECT symbol,year,(total_assets - total_liabilities) AS net_worth,
	(((total_assets - total_liabilities)::NUMERIC/(LEAD((total_assets - total_liabilities)) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS net_worth_growth 
FROM awesome_fundamentals;


-- net income growth
CREATE TEMP TABLE net_income_growth AS
	SELECT symbol,year,net_income,
	((net_income::NUMERIC/(LEAD(net_income) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS net_income_growth 
FROM awesome_fundamentals;


-- revenue growth
CREATE TEMP TABLE revenue_growth AS
	SELECT symbol,year,total_revenue,
	((total_revenue::NUMERIC/(LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS revenue_growth
FROM awesome_fundamentals;


-- earnings per share growth
CREATE TEMP TABLE earnings_per_share_growth AS
SELECT symbol,year,earnings_per_share,
	((earnings_per_share::NUMERIC/(LEAD(earnings_per_share) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS earnings_per_share_growth
FROM awesome_fundamentals;

-- low price-to-earnings ratio

CREATE TEMP TABLE price_to_earnings_ratio AS
SELECT b.symbol,a.year,b.close,a.earnings_per_share,((b.close/a.earnings_per_share)::numeric(10,2)) AS price_to_earnings_ratio
FROM awesome_fundamentals a INNER JOIN prices b ON a.year_end = b.date AND a.symbol = b.symbol; 

-- liabilities to liquid assets ratio
CREATE TEMP TABLE liabilities_to_liquid_assets_ratio AS
SELECT symbol,year,(total_liabilities::numeric/cash_and_cashequiv::numeric) AS liabilities_liquid_assets_ratio
FROM awesome_fundamentals;


-- Review factors ( 43 companies total)

SELECT symbol,AVG(net_worth_growth) FROM net_worth_growth GROUP BY symbol HAVING AVG(net_worth_growth) > .05; 	-- 23 companies share this characteristic

SELECT symbol,AVG(net_income_growth) FROM net_income_growth GROUP BY symbol HAVING AVG(net_income_growth) > .1; 	-- 27 companies

SELECT symbol,AVG(revenue_growth) FROM revenue_growth GROUP BY symbol HAVING AVG(revenue_growth) > .1; 	-- 20 companies have an average  revenue growth of about 10%, so this is 
--probably a good factor to look at when determining overall success of a company. 

SELECT symbol,AVG(earnings_per_share_growth) FROM earnings_per_share_growth GROUP BY symbol HAVING AVG(earnings_per_share_growth) > .1; 	-- 24 companies
-- have an average eps growth of greater than .1. I thought this might be a good factor to look at when determining success.

SELECT AVG(price_to_earnings_ratio) FROM price_to_earnings_ratio WHERE price_to_earnings_ratio IS NOT NULL;
SELECT stddev(price_to_earnings_ratio) FROM price_to_earnings_ratio WHERE price_to_earnings_ratio IS NOT NULL;
-- We get an average of about 38, but our standard deviation is about 150. Which shows that this particular variable has a fair amount of variance and may not be 
-- a good factor to look at when determining success.

SELECT AVG(liabilities_liquid_assets_ratio) FROM liabilities_to_liquid_assets_ratio WHERE liabilities_liquid_assets_ratio IS NOT NULL;
SELECT stddev(liabilities_liquid_assets_ratio) FROM liabilities_to_liquid_assets_ratio WHERE liabilities_liquid_assets_ratio IS NOT NULL; -- Returns 1085 standard deviation.
-- This is pretty high (when you look at the average of the actual data), which means that this probably isn't a good indicator of a company's success.

-- After taking into account the queries above I decided to pick the following three factors as they seem to be good indicators of a company's success.
-- To decide these factors I tried to get queries that returned at least half of the companies. I only wanted to take 3 of the factors because 
-- I felt taking too many would cloud my results or maybe limit my results too much. 

-- FACTORS 
-- Earnings per share growth
-- Net income growth
-- Revenue growth 

CREATE TEMP TABLE good_indicators AS 
	SELECT symbol,year, 
	((net_income::NUMERIC/(LEAD(net_income) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS net_income_growth,
	((total_revenue::NUMERIC/(LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS revenue_growth,
	((earnings_per_share::NUMERIC/(LEAD(earnings_per_share) OVER (PARTITION BY symbol ORDER BY year DESC))::NUMERIC)-1) AS earnings_per_share_growth
	FROM fundamentals
	WHERE year BETWEEN 2015 AND 2016;

SELECT symbol, AVG(net_income_growth) AS avg_net_income_growth, AVG(revenue_growth) AS avg_rev_growth, AVG(earnings_per_share_growth) AS avg_eps_growth
FROM good_indicators
GROUP BY symbol
HAVING 
	AVG(net_income_growth) > .1
	AND
	AVG(revenue_growth) > .01
	AND
	AVG(earnings_per_share_growth) > .05
ORDER BY AVG(net_income_growth);

CREATE TABLE top_companies AS 
SELECT * FROM securities WHERE symbol IN 
(SELECT symbol
FROM good_indicators
GROUP BY symbol
HAVING 
	AVG(net_income_growth) > .1
	AND
	AVG(revenue_growth) > .01
	AND
	AVG(earnings_per_share_growth) > .05)
ORDER BY sector;


/* 3. 

Top 10 companies (in no particular order)
1. INTU
2. KLAC
3. FDX
4. CTAS
5. HOLX
6. BDX
7. SJM
8. SYY
9. DIS
10.DHI

 After executing the first query I got 19 results that fit my criteria. Afterwards, I did a second query to find out which companies share the same
 sectors. In the interest of diversification I got two companies from each sector. DIS and DHI were the only 2 companies in the consumer discretionary sector
 so I just defaulted to those two. Afterwards, to pick my other companies I looked first to net_income_growth, but I also wanted to make sure that I could 
 pick companies that performed well in the other two factors as well, because these companies are more likely to succeed if they're performing well overall. */



