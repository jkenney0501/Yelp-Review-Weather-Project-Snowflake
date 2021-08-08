/*********************************************************************************
Now that JSON and CSV files have been extracted, the JSON files in the stage area
need to be formatted into a columnar table. This will happen in the ODS schema
that is created first.

Additionally, the Operationl Data Store (or data mart) 
is where we begin to transform ad normalize. The table will remain for now
but cardinality will be specififed in accordance with the ODS ERD. Later when 
we move to the data warehouse, the STAR schema will come into pay with 
DIM and a FACT table for the yelp reviews and weather anlaysis.

Note: SOME 3nf principles are applied here but not entirely.
What is applied is for some adherence to 3nf and primarily practice
but given this data set will not be updated and is a one time analysis,
many tables are not broken down to 3nf for this reaon alone. Also, UPDATE
ON DELETE/CASCADING is not applied to foreign keys due to this reason as well.

Snowflake trial is limited to 30 days anf the objective the analysis in additon
to a little practice for JSON/staging and creating a data warehouse 
for analysis inaddition to some manual ELT/ETL.

Last Update: 8/8/2021
**********************************************************************************/

--to create tables and perform ETL from JSON staging files
CREATE SCHEMA "YELP"."ODS";

USE SCHEMA ODS;

--******** business table
create or replace table business (
business_id varchar(200),
address varchar(200),
attributes object,
categories varchar(500),
city varchar(200),
hours varchar(500),
is_open number,
latitude varchar(50),
longitude varchar(50),
name varchar(100),
postal_code varchar(100),
review_count number,
stars number,
state varchar(5)
);

insert into business
select 
usersjson:business_id::varchar(200),
usersjson:address::varchar(200),
usersjson:attributes::object,
usersjson:categories::varchar(500),
usersjson:city::varchar(200),
usersjson:hours::varchar(500),
usersjson:is_open::float,
usersjson:latitude::varchar(50),
usersjson:longitude::varchar(50),
usersjson:name::string,
usersjson:postal_code::varchar(100),
usersjson:review_count::number,
usersjson:stars::number,
usersjson:state::varchar(5)
from yelp.stage.business;

select * 
from business
limit 20;

-- add the PK to the business table
ALTER TABLE BUSINESS ADD PRIMARY KEY (business_id);

-- add the FK to the business table



--*********CREATE check in table for ODS
create or replace table check_in(
    business_id varchar(200),
    date string
);


--insert the data from the check_in stage JSON
insert into check_in 
select 
checkinsjson:business_id::varchar(200),
checkinsjson:date::string
from yelp.stage.check_in;       

select * 
from check_in
limit 20;

-- add the PK to the check_in table
ALTER TABLE check_in ADD PRIMARY KEY (business_id);



--********* covid table to capture closed restaraunts
create or replace table covid(
    business_id varchar(200),
    Covid_Banner string,
    Grubhub_enabled string,
    Request_a_Quote_Enabled string,
    Temporary_Closed_Until string,
    Virtual_Services_Offered string,
    delivery_or_takeout string,
    highlights string
);

--insert the data from the covid stage JSON
insert into covid 
select 
covidjson:business_id::varchar(200),
covidjson:"Covid Banner"::string,
covidjson:"Grubhub enabled"::string,
covidjson:"Request a Quote Enabled"::string,
covidjson:"Temporary Closed Until"::string,
covidjson:"Virtual Services Offered"::string,
covidjson:"delivery or takeout"::string,
covidjson:"highlights"::string
from yelp.stage.covid; 

select * 
from covid
limit 20;

-- add the PK to the covid table
ALTER TABLE covid ADD PRIMARY KEY (business_id);



--******* review table
create or replace table review(
    review_id varchar(200),
    user_id varchar(200),
    business_id varchar(200),
    date VARCHAR(10),
    stars number,
    cool number,
    funny number,
    useful number,
    text text
);

--insert the data from the stage JSON
insert into review 
select 
reviewsjson:review_id::varchar(200),
reviewsjson:user_id::varchar(200),
reviewsjson:business_id::varchar(200),
reviewsjson:"date"::VARCHAR(10),
reviewsjson:"stars"::number,
reviewsjson:"cool"::number,
reviewsjson:"funny"::number,
reviewsjson:"useful"::number,
reviewsjson:"text"::text
from yelp.stage.review; 

select * 
from review
limit 20;

-- add the PK to the review table MAKE REVIEW ID THE PK!!
ALTER TABLE review ADD PRIMARY KEY (review_id);




--******* tips table
create or replace table tips(
    business_id varchar(200),
    user_id varchar(200),
    compliment_count number,
    date date,
    text text
);



--insert the data from the stage JSON
insert into tips 
select 
tipsjson:business_id::varchar(200),
tipsjson:user_id::varchar(200),
tipsjson:compliment_count::number,
tipsjson:"date"::date,
tipsjson:"text"::text
from yelp.stage.tips; 

select * 
from tips
limit 20;

-- add the PK to the review table MAKE REVIEW ID THE PK!!
ALTER TABLE tips ADD PRIMARY KEY (business_id);




--******* user table
create or replace table user(
    user_id varchar(200),
    name varchar(100),
    yelping_since string,
    average_stars double,
    compliment_cool number,
    compliment_cute number,
    compliment_funny number,
    compliment_hot number,
    compliment_list number,
    compliment_more number,
    compliment_note number,
    compliment_photos number,
    compliment_plain number,
    compliment_profile number,
    compliment_writer number,
    cool number,
    elite varchar(20),
    fans number,
    friends string,
    funny number,
    review_count number,
    useful number
);

--insert the data from the stage JSON
insert into user 
select 
usersjson:user_id::varchar(200),
usersjson:name::varchar(100),
usersjson:yelping_since::string,
usersjson:average_stars::double,
usersjson:compliment_cool::number,
usersjson:compliment_cute::number,
usersjson:compliment_funny::number,
usersjson:compliment_hot::number,
usersjson:compliment_list::number,
usersjson:compliment_more::number,
usersjson:compliment_note::number,
usersjson:compliment_photos::number,
usersjson:compliment_plain::number,
usersjson:compliment_profile::number,
usersjson:compliment_writer::number,
usersjson:cool::number,
usersjson:elite::varchar(20),
usersjson:fans::number,
usersjson:friends::string,
usersjson:funny::number,
usersjson:review_count::number,
usersjson:useful::number
from yelp.stage.user; 

select * 
from user 
limit 10;

--ADD PK to user table
ALTER TABLE user ADD PRIMARY KEY (user_id);




--****** Temperature Table ODS
/*
select TO_CHAR(TO_DATE(date, 'YYYYMMDD'), 'YYYY-MM-DD')
from stage.temperature;
*/
--TEMPERATURE TABLE
create or replace table temperature(
    date_temp string,
    min_temp float,
    max_temp float,
    normal_min float,
    normal_max float
);

insert into temperature
select 
TO_CHAR(TO_DATE(date, 'YYYYMMDD'), 'YYYY-MM-DD') as date_temp,
min,
max,
normal_min,
normal_max
from stage.temperature;


select * from temperature limit 10;

-- add the PK to the temperature table 
ALTER TABLE temperature ADD PRIMARY KEY (date_temp);


--****** Precipitation Table to ODS
create or replace table precipitation(
    date_precip string,
    precipitation float,
    precipitation_normal float
);

-- There are values in rows where precipitation is not recorded and = "T".
-- These values are removed as they are not relevant to the analysis due to the date.
insert into precipitation
select 
TO_CHAR(TO_DATE(date, 'YYYYMMDD'), 'YYYY-MM-DD') as date_precip,
precipitation,
precipitation_normal
from stage.precipitation
where precipitation != 'T';


select * from precipitation limit 10;

-- add primary key to precipitation table
ALTER TABLE precipitation ADD PRIMARY KEY (date_precip);


--change precipitation to decimal when creating in DW



/**********************************************************
Normalize (only a few) tables in ODS Schema

Tables are broken down to save disk space and make it easy
to create a FACT/DIM STAR schema in the data warehouse.

Tables are created in sequence due to the order for which
constraints are added.

***********************************************************/
-- CREATE STATE (LOCATION) TABLE
-- creating state (location), city and address tables to normalize
create or replace table location (
    state VARCHAR(5)
);

insert into location
select distinct
state
from business;

-- replicate the table and create a sequence to add the auto inc PK
CREATE or replace TABLE bus_location LIKE location;

ALTER TABLE bus_location ADD COLUMN location_id int primary key IDENTITY(1,1);

-- creates a sequence to auto incrment as additonal states are added
create or replace sequence busseq1 start = 1 increment = 1;

INSERT INTO bus_location
SELECT state, busseq1.NEXTVAL FROM location;

-- CHECK RESULTS
SELECT * 
FROM BUS_LOCATION
LIMIT 100;

-- now drop the orignal location table
drop table location;

-- ***** go back to business table and alter it to drop the state name, add loc_id
-- drop the actual columns last!
alter table business
add column location_id INT;

ALTER TABLE business ADD FOREIGN KEY (location_id) REFERENCES bus_location(location_id);

-- update business table with FK values from bus_location
update business
set business.location_id = bus_location.location_id
from bus_location
where business.state = bus_location.state;

-- MA example
select * 
from business 
where location_id = 11;

--delete from  business
--where location_id is not null;


/* CREATE CITY TABLE */
--****** Create city table with cols city_id, address_id, city *****
create or replace table city1(
    city VARCHAR(200),
)

insert into city1
select distinct city from business;

Select * from city1 limit 100;

-- replicate the table and create a sequence to add the auto inc PK
CREATE or replace TABLE city LIKE city1;

ALTER TABLE city ADD COLUMN city_id int primary key IDENTITY(1,1);

create or replace sequence cityseq start = 1 increment = 1;

INSERT INTO city
SELECT city, cityseq.NEXTVAL FROM city1;

-- CHECK RESULTS
SELECT * 
FROM city
LIMIT 100;

-- add the fk to the business table
-- ***** go back to business table and alter it to drop the city, add city_id
-- drop the actual columns last!
alter table business
add column city_id INT;

ALTER TABLE business ADD FOREIGN KEY (city_id) REFERENCES city(city_id);

-- update business table with FK values from bus_location
update business
set business.city_id = city.city_id
from city
where business.city = city.city;

-- check values to validate the match
select city, city_id
from business 
--where city_id = 1;
where city in ('Austn', 'Salem', 'Vancouver', 'Winter Springs');

/******************************************************************
Create zip code table
*******************************************************************/
create or replace table zip_code1(
    postal_code VARCHAR(100)
);

INSERT INTO zip_code1
select distinct
postal_code
from business;

-- replicate the table and create a sequence to add the auto inc PK
CREATE or replace TABLE zip_code LIKE zip_code1;

ALTER TABLE zip_code ADD COLUMN zip_id int primary key IDENTITY(1,1);

create or replace sequence zipseq start = 1 increment = 1;

INSERT INTO zip_code
SELECT postal_code, zipseq.NEXTVAL FROM zip_code1;

-- CHECK RESULTS
SELECT * 
FROM zip_code
LIMIT 100;

-- now update bus table with FK col and values
-- ***** go back to business table and alter it to drop the postal_code, add zip_id
-- drop the actual columns last!
alter table business
add column zip_id INT;

ALTER TABLE business ADD FOREIGN KEY (zip_id) REFERENCES zip_code(zip_id);

-- update business table with FK values from bus_location
update business
set business.zip_id = zip_code.zip_id
from zip_code
where business.postal_code = zip_code.postal_code;

--check zips data
select * from business where state = 'MA' AND CITY = 'Boston'; 


