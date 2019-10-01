BEGIN;

DROP TABLE IF EXISTS boats CASCADE;

DROP TABLE IF EXISTS buyers CASCADE;

DROP TABLE IF EXISTS transactions;

CREATE TABLE boats(
	prod_id integer NOT NULL,
	brand text NOT NULL,
	category text, 
	cost numeric(10,2) NOT NULL,
	price numeric(10,2)
);

CREATE TABLE buyers(
	cust_id integer NOT NULL,
	fname text NOT NULL,
	lname text NOT NULL,
	city text NOT NULL,
	state character(2) NOT NULL,
	referrer text
);

CREATE TABLE transactions(
	trans_id integer NOT NULL,
	cust_id integer NOT NULL,
	prod_id integer NOT NULL,
	qty integer NOT NULL,
	price numeric(10,2) NOT NULL
);

INSERT INTO boats VALUES
(1217,'Criss Craft','sporty',20000,25000.0),
(1117,'Bayliner','runabout',41000,45100.0),
(1317,'Mastercraft','ski',67000,83750.0),
(1417,'Boston Whaler','fishing',48000,55200.0),
(1517,'Carver','cabin cruser',50000,62500.0),
(1617,'Bayliner','runabout',33000,69300.0),
(1717,'Kawasaki','sporty',51000,61200.0),
(1817,'Kawasaki','runabout',33000,40260.0),
(1917,'Zodiac','inflatable',17000,22100.0),
(3017,'Egg Harbor',NULL,60000,126000.0);

INSERT INTO buyers VALUES
(1121,'Jane','Doe','Boston','MA','craigslist'),
(1221,'Fred','Smith','Hartford','CT','facebook'),
(1321,'John','Jones','New Haven','CT','google'),
(1421,'Alan','Weston','Stony Brook','NY','craigslist'),
(1521,'James','Smith','Darien','CT','boatjournal'),
(1621,'Adam','East','Fort Lee','NJ','mariner'),
(1721,'Mary','Jones','New Haven','CT','facebook'),
(1821,'Tonya','James','Stamford','CT','boatbuyer'),
(1921,'Elaine','Edwards','New Rochelle','NY','boatbuyer'),
(2021,'Alan','Easton','White Plains','NY','craigslist'),
(2121,'James','John','Ringwood','NJ','google'),
(2221,'Ronald','Jones','Hackensack','NJ','craigslist'),
(2321,'Freida','Alan','Stratford','CT','boatbuyer'),
(2421,'Thelma','James','Paterson','NJ','facebook'),
(2521,'Louise','John','Paramus','NJ','boatbuyer'),
(2621,'Brad','Johnson','Fort Lee','NJ','google'),
(2721,'Thomas','Jameson','Fairfield','CT','craigslist'),
(2821,'Robert','Newbury','Astoria','NY','boatjournal'),
(2921,'Edward','Oldbury','Brooklyn','NY','mariner'),
(3021,'Juan','Reyes','Brooklyn','NY','facebook'),
(3121,'Alberto','Delacruz','New York','NY','google'),
(3221,'Margarita','Jones','White Plains','NY','boatbuyer'),
(3321,'Penelope','Smith','Maspeth','NY','facebook');

INSERT INTO transactions VALUES
(1124, 3121, 3017, 1, 126000.0),
(1127, 1221, 1617, 1, 69300.0),
(1130, 1821, 1317, 1, 83750.0),
(1133, 1321, 1117, 1, 45100.0),
(1136, 2521, 1717, 1, 61200.0),
(1139, 2721, 1317, 1, 83750.0),
(1142, 2621, 1417, 1, 55200.0),
(1145, 1121, 1917, 1, 22100.0),
(1148, 1821, 1817, 1, 40260.0),
(1151, 2821, 3017, 1, 126000.0),
(1154, 1621, 1917, 1, 22100.0),
(1157, 3121, 1717, 1, 61200.0),
(1160, 2321, 1517, 1, 62500.0),
(1163, 3321, 1317, 1, 83750.0),
(1166, 1721, 1917, 1, 22100.0),
(1169, 2421, 1817, 1, 40260.0),
(1172, 2921, 1417, 1, 55200.0),
(1175, 2321, 3017, 1, 126000.0),
(1178, 1221, 1317, 1, 83750.0),
(1181, 1121, 1817, 1, 40260.0),
(1184, 1321, 3017, 1, 126000.0),
(1187, 1421, 1517, 1, 62500.0),
(1190, 3321, 1517, 1, 62500.0);

ALTER TABLE only boats
	ADD CONSTRAINT boats_pkey PRIMARY KEY (prod_id);

ALTER TABLE only buyers
	ADD CONSTRAINT buyers_pkey PRIMARY KEY (cust_id);

ALTER TABLE only transactions
	ADD CONSTRAINT transactions_pkey PRIMARY KEY (trans_id),
	ADD CONSTRAINT transactions_fkey1 FOREIGN KEY (cust_id) REFERENCES buyers(cust_id),
	ADD CONSTRAINT transactions_fkey2 FOREIGN KEY (prod_id) REFERENCES boats(prod_id);
	
COMMIT;