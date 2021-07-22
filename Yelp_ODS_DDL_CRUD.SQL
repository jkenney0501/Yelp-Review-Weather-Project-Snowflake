/*********************************************************************************
Now that JSON and CSV files have been extracted, the JSON files in the stage area
need to be formatted into a columnar table. This will happen in the ODS schema
that is created first.

Additionally, the Operationl Data Store (or data mart) 
is where we begin to transform ad normalize. The table will remain for now
but cardinality will be specififed in accordance with the ODS ERD. Later when 
we move to the data warehouse, the STAR schema will come into pay with 
DIM and a FACT table for the yelp reviews and weather anlaysis.

Last Update: 7/18/2021
**********************************************************************************/

--to create tables and perform ETL from JSON staging files
CREATE SCHEMA "YELP"."ODS";

USE SCHEMA ODS;

--******** business table
create or replace table business (
"business_id" varchar(200),
"address" varchar(200),
"attributes" object,
"categories" varchar(500),
"city" varchar(200),
"hours" varchar(500),
"is_open" number,
"latitude" varchar(50),
"longitude" varchar(50),
"name" varchar(100),
"postal_code" varchar(100),
"review_count" number,
"stars" number,
"state" varchar(5)
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

select * from business;

-- add the PK to the business table
ALTER TABLE BUSINESS ADD PRIMARY KEY ("business_id");

-- add the FK to the business table



--*********CREATE check in table for ODS
create or replace table check_in(
    "business_id" varchar(200),
    "date" string
);


--insert the data from the check_in stage JSON
insert into check_in 
select 
checkinsjson:business_id::varchar(200),
checkinsjson:'date'::string
from yelp.stage.check_in;       

select * from check_in;

-- add the PK to the check_in table
ALTER TABLE check_in ADD PRIMARY KEY ("business_id");



--********* covid table to capture closed restaraunts
create or replace table covid(
    "business_id" varchar(200),
    "Covid Banner" string,
    "Grubhub enabled" string,
    "Request a Quote Enabled" string,
    "Temporary Closed Until" string,
    "Virtual Services Offered" string,
    "delivery or takeout" string,
    "highlights" string
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

select * from covid;

-- add the PK to the covid table
ALTER TABLE covid ADD PRIMARY KEY ("business_id");



--******* review table
create or replace table review(
    "review_id" varchar(200),
    "user_id" varchar(200),
    "business_id" varchar(200),
    "date" date,
    "stars" number,
    "cool" number,
    "funny" number,
    "useful" number,
    "text" text
);

--insert the data from the stage JSON
insert into review 
select 
reviewsjson:review_id::varchar(200),
reviewsjson:user_id::varchar(200),
reviewsjson:business_id::varchar(200),
reviewsjson:"date"::date,
reviewsjson:"stars"::number,
reviewsjson:"cool"::number,
reviewsjson:"funny"::number,
reviewsjson:"useful"::number,
reviewsjson:"text"::text
from yelp.stage.review; 

select * from review;

-- add the PK to the review table MAKE REVIEW ID THE PK!!
ALTER TABLE review ADD PRIMARY KEY ("review_id");




--******* tips table
create or replace table tips(
    "business_id" varchar(200),
    "user_id" varchar(200),
    "compliment_count" number,
    "date" date,
    "text" text
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

select * from tips;

-- add the PK to the review table MAKE REVIEW ID THE PK!!
ALTER TABLE tips ADD PRIMARY KEY ("business_id");




--******* user table
create or replace table user(
    "user_id" varchar(200),
    "name" varchar(100),
    "yelping_since" string,
    "average_stars" double,
    "compliment_cool" number,
    "compliment_cute"number,
    "compliment_funny"number,
    "compliment_hot"number,
    "compliment_list"number,
    "compliment_more"number,
    "compliment_note"number,
    "compliment_photos"number,
    "compliment_plain"number,
    "compliment_profile"number,
    "compliment_writer"number,
    "cool"number,
    "elite"varchar(20),
    "fans"number,
    "friends" string,
    "funny" number,
    "review_count" number,
    "useful" number
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

select * from user limit 10;

--ADD PK to user table
ALTER TABLE user ADD PRIMARY KEY ("user_id");




--****** Temperature Table ODS
/*
select TO_CHAR(TO_DATE(date, 'YYYYMMDD'), 'YYYY-MM-DD')
from stage.temperature;
*/
--TEMPERATURE TABLE
create or replace table temperature(
    "date" string,
    "min" float,
    "max" float,
    "normal_min" float,
    "normal_max" float
);

insert into temperature
select 
TO_CHAR(TO_DATE(date, 'YYYYMMDD'), 'YYYY-MM-DD') as "date",
min,
max,
normal_min,
normal_max
from stage.temperature;


select * from temperature limit 10;

-- add the PK to the temperature table 
ALTER TABLE temperature ADD PRIMARY KEY ("date");


--****** Precipitation Table to ODS
create or replace table precipitation(
    "date" string,
    "precipipitation" string,
    "precipitation_normal" float
);

insert into precipitation
select 
TO_CHAR(TO_DATE(date, 'YYYYMMDD'), 'YYYY-MM-DD') as "date",
precipitation,
precipitation_normal
from stage.precipitation;


select * from precipitation limit 10;

-- There are values in rows where precipitation is not recorded and = "T".
-- clean precipitation col by replacng the "T" value with the normal precipitation level_value
UPDATE precipitation
SET "precipititation" = "precipitation_normal"
where "precipititation" = 'T';

-- add primary key to precipitation table
ALTER TABLE precipitation ADD PRIMARY KEY ("date");


--change precipitation to decimal when creating in DW