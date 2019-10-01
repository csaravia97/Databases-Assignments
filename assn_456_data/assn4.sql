CREATE TEMP TABLE years AS  
WITH dates AS (												
	SELECT DISTINCT date FROM prices)

SELECT *, ROW_NUMBER() OVER (PARTITION BY extract(year from date) ORDER BY date DESC) AS row_number FROM dates;


CREATE TEMP TABLE year_ends AS 
SELECT date FROM years WHERE row_number = 1; 


CREATE TEMP TABLE y_e_prices AS 
SELECT a.symbol,a.date,a.close FROM prices a INNER JOIN year_ends b ON a.date = b.date ORDER BY a.symbol,a.date;


CREATE TEMP TABLE annual_returns AS
WITH returns_with_nulls AS (
	SELECT symbol,EXTRACT(year from date) AS year,LAG(close,1) OVER (PARTITION BY symbol ORDER BY date) AS close,((close / LAG(close,1) OVER (PARTITION BY symbol ORDER BY date)) - 1) AS annual_return 
		FROM y_e_prices 
		ORDER BY annual_return DESC)

SELECT * FROM returns_with_nulls WHERE annual_return IS NOT NULL; 

-- Create a table of high performers
-- high performers are companies who had an annual return of 150% more than once. 
-- 150% was an arbitrary number, I tried a couple others but they returned too little results. 

DROP TABLE IF EXISTS high_performers;

CREATE TABLE high_performers AS
WITH consistent_performers AS(
	SELECT symbol,COUNT(*) FROM annual_returns WHERE annual_return > 0.50 GROUP BY symbol HAVING COUNT(*) > 1 ORDER BY COUNT(*))

SELECT DISTINCT symbol, year FROM annual_returns WHERE symbol IN (SELECT symbol FROM consistent_performers);
