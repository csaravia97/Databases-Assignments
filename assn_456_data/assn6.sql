-- #1
-- Backed up the database I used for assignments 4 and 5 in a SQL file called backup.sql
-- pg_dump -U postgres -d assn456 > backup.sql

--#2
DROP VIEW IF EXISTS summary_info;
CREATE VIEW summary_info AS
	SELECT b.* FROM investments a INNER JOIN prices b ON a.symbol = b.symbol 
	ORDER BY DATE DESC 
	LIMIT 10; 

SELECT * FROM summary_info;

--#3
-- psql -U postgres -tAF, -f assn6.sql > investments.csv 


--#4
-- company		closing price(2017)		percent return 
---------------------------------------------------------

-- 1. INTU			$157.78					37.67%
-- 2. KLAC			$105.07					33.54%
-- 3. FDX			$249.54					34.02%
-- 4. CTAS			$155.83					34.85%	
-- 5. HOLX			 $42.75		 			 6.58%
-- 6. BDX			$214.06					29.30%
-- 7. SJM			$124.24					-2.98%
-- 8. SYY		 	 $60.73		 			 9.68%		
-- 9. DIS			$107.51		 			 3.16%
-- 10.DHI			 $51.07					108.62%	