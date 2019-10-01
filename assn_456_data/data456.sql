BEGIN;

DROP TABLE IF EXISTS securities CASCADE;
DROP TABLE IF EXISTS fundamentals;
DROP TABLE IF EXISTS prices;

CREATE TABLE securities (
	symbol varchar(5) NOT NULL,
	company text NOT NULL,
	sector text NOT NULL,
	subindustry text NOT NULL,
	init_tradedate date
);

CREATE TABLE fundamentals (
	id integer NOT NULL,
	symbol varchar(5) NOT NULL,
	year_end date NOT NULL,
	cash_and_cashequiv bigint NOT NULL,
	earnings_before_tax bigint NOT NULL,
	gross_margin smallint NOT NULL,
	net_income bigint NOT NULL, 
	total_assets bigint NOT NULL,
	total_liabilities bigint NOT NULL,
	total_revenue bigint NOT NULL,
	year integer NOT NULL,
	earnings_per_share NUMERIC (5,2),
	shares_outstanding numeric
);

CREATE TABLE prices (
	date DATE NOT NULL,
	symbol varchar(5) NOT NULL,
	open numeric NOT NULL,
	close numeric NOT NULL,
	low numeric NOT NULL,
	high numeric NOT NULL,
	volume integer NOT NULL
);

\COPY securities FROM './securities.csv' WITH (FORMAT csv);
\COPY fundamentals FROM './fundamentals.csv' WITH (FORMAT csv);
\COPY prices FROM './prices.csv' WITH (FORMAT csv);

ALTER TABLE ONLY securities 
	ADD CONSTRAINT securities_pkey PRIMARY KEY (symbol);

ALTER TABLE ONLY fundamentals
	ADD CONSTRAINT fundamentals_pkey PRIMARY KEY (id);

ALTER TABLE ONLY prices
	ADD CONSTRAINT prices_pkey PRIMARY KEY (date,symbol);

ALTER TABLE ONLY fundamentals
	ADD CONSTRAINT fundamentals_symbol_fkey FOREIGN KEY (symbol) REFERENCES securities(symbol);

ALTER TABLE ONLY prices
	ADD CONSTRAINT prices_symbol_fkey FOREIGN KEY (symbol) REFERENCES securities(symbol);
COMMIT;
