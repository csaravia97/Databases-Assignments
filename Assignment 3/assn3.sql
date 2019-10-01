\pset footer off
\echo '\n'

\echo '\n 1.  We want to spend some advertising money - where should we spend it?\n'
		SELECT B.referrer AS top_referrers 
		FROM transactions A 
			INNER JOIN buyers B 
				ON A.cust_id = B.cust_id 
		GROUP BY referrer 
		ORDER BY COUNT(*) 
		DESC LIMIT 3;

\echo '\n2.  Who of our customers has not bought a boat?\n'
		 SELECT A.*
		 FROM buyers A 
		 	LEFT JOIN transactions B 
		 		ON A.cust_id = B.cust_id 
		 WHERE B.trans_id IS NULL
		 ORDER BY A.lname;

\echo '\n3.  Which boats have not sold?\n'
		SELECT A.* 
		 FROM boats A 
		 	LEFT JOIN transactions B 
		 		ON A.prod_id = B.prod_id 
		 WHERE B.trans_id IS NULL;

\echo '\n4.  What boat did Alan Weston buy?\n'
		SELECT C.*
		FROM buyers A
			INNER JOIN transactions B
			ON A.cust_id = B.cust_id
			INNER JOIN boats C
			ON B.prod_id = C.prod_id
		WHERE A.fname = 'Alan'
		AND A.lname = 'Weston';

\echo '\n5.Who are our VIP customers?\n'
	WITH mult_trans AS (
		SELECT cust_id
		FROM transactions
		GROUP BY cust_id
		HAVING COUNT(*) > 1
	)

	SELECT A.*
	FROM buyers A
		INNER JOIN mult_trans B
		ON A.cust_id = B.cust_id
	ORDER BY A.lname;





