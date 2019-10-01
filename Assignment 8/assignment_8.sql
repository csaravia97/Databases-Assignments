-- DROP TABLE IF EXISTS company_performance;

-- CREATE TABLE company_performance (
-- 	id INTEGER NOT NULL,
-- 	industrial_risk CHAR (1) NOT NULL,
-- 	mgmt_risk CHAR (1) NOT NULL, 
-- 	fin_flexibility CHAR (1) NOT NULL,
-- 	credibility CHAR (1) NOT NULL,
-- 	competiveness CHAR (1) NOT NULL,
-- 	op_risk CHAR (1) NOT NULL,
-- 	class VARCHAR (2) NOT NULL
-- );

-- \COPY company_performance FROM './ids.csv' WITH (FORMAT csv);

-- Calculate risk scores
CREATE TEMP TABLE risk_scores AS
SELECT id,class,((CASE WHEN industrial_risk = 'N' THEN 1 ELSE 0 END) +
				(CASE WHEN mgmt_risk = 'N' THEN 1 ELSE 0 END) +
				(CASE WHEN fin_flexibility = 'N' THEN 1 ELSE 0 END) +
				(CASE WHEN credibility = 'N' THEN 1 ELSE 0 END) +
				(CASE WHEN competiveness = 'N' THEN 1 ELSE 0 END) +
				(CASE WHEN op_risk = 'N' THEN 1 ELSE 0 END)) AS risk_score
FROM company_performance
ORDER BY risk_score DESC;

-- Classify each company 
CREATE TEMP TABLE classifications AS
SELECT *, (CASE WHEN risk_score <= 2 THEN 'Low'
				WHEN risk_score < 4 THEN 'Medium'
				WHEN risk_score < 5 THEN 'Medium-High'
				ELSE 'High'
				END) AS classifications
FROM risk_scores;

-- #1
SELECT classifications, COUNT(classifications) 
FROM classifications
WHERE class = 'B' 
GROUP BY classifications
ORDER BY count;

-- #2 
SELECT classifications, COUNT(classifications) 
FROM classifications
WHERE class = 'NB' 
GROUP BY classifications
ORDER BY count;

-- #3
SELECT id, classifications 
FROM classifications
WHERE classifications <> 'Low' AND class <> 'B';