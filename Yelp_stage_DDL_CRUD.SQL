/************************************************************************
Author: James Kenney

Date: 7/18/2021
Last Update: 7/18/2021
Objective: import CSV and JSON files to create a staging environment in 
Snowflake, create and ODS then a data warehouse for reporting & anlaysis for 
an analysis of weather on Yelp reviews for Boston, MA (CHOSEN FOR LARGE #OF REVIEWS).

This project creates datasets from Yelp Data and historical data
in Boson, MA. The objective is to investigate if weather has
any impact on Yelp Reviews. 

1. Data sets are first imported into Snowflake in a staging environment.
2. From there the data will be broken down into tables where JSON files
are transformed into tables and merged with climate CSV files to complete 
the analysis.

Data Source: YELP JSON and Covid 19 data (for closed restaraunts)

https://www.yelp.com/dataset/download

For climate data:
https://crt-climate-explorer.nemac.org/

Use staion id:  BOSTON-USW00014739

2 csv files - Under the Downloads menu-option, 
download both temperature data and precipitation data.

**************************************************************************/

CREATE DATABASE YELP;

--to pull in yelp and climate data
CREATE SCHEMA "YELP"."STAGE";


--upload JSON Files to stage for yelp data
USE DATABASE YELP;

USE SCHEMA STAGE;

--create JSON format
create or replace file format myjsonformat type = 'JSON' strip_outer_array=true;

--create temp holding/staging area for JSON data
create or replace stage my_json_stage file_format = myjsonformat ;





--create a table with one column of type variant
--**** Business Stage Table JSON ****
create table business(usersjson variant) ;

--upload the data from local computer to the temporary "holding area" stagefile area
put file://desktop/yelp-weather-project/yelp_dataset/yelp_academic_dataset_business.json  @my_json_stage auto_compress=true;

--copy into stage table from holding area
copy into business from @my_json_stage/yelp_academic_dataset_business.json.gz file_format=(format_name = myjsonformat) on_error = 'skip_file';




/* using the same format created above, 
the remaining files are copied into separate tables 
and named according to the data they provide. */

--**** Tips stage table JSON ****
create table tips(tipsjson variant) ;

-- to holding area
put file://desktop/yelp-weather-project/yelp_dataset/yelp_academic_dataset_tip.json  @my_json_stage auto_compress=true;


--to stage table
copy into tips from @my_json_stage/yelp_academic_dataset_tip.json.gz file_format=(format_name = myjsonformat) on_error = 'skip_file';





--**** CHECK IN stage table JSON ***()
create table check_in(checkinsjson variant) ;

-- to holding area
put file://desktop/yelp-weather-project/yelp_dataset/yelp_academic_dataset_checkin.json  @my_json_stage auto_compress=true;

--to stage table
copy into check_in from @my_json_stage/yelp_academic_dataset_checkin.json.gz file_format=(format_name = myjsonformat) on_error = 'skip_file';





--**** Review stage table JSON ***()
create table review(reviewsjson variant) ;

-- to holding area
put file://desktop/yelp-weather-project/yelp_dataset/yelp_academic_dataset_review.json  @my_json_stage auto_compress=true;


--to stage table
copy into review from @my_json_stage/yelp_academic_dataset_review.json.gz file_format=(format_name = myjsonformat) on_error = 'skip_file';






--**** User stage table JSON ***()
create table user(usersjson variant) ;

-- to holding area
put file://desktop/yelp-weather-project/yelp_dataset/yelp_academic_dataset_user.json  @my_json_stage auto_compress=true;

--to stage table
copy into user from @my_json_stage/yelp_academic_dataset_user.json.gz file_format=(format_name = myjsonformat) on_error = 'skip_file';






--**** Covid (closed restaraunts) stage table JSON ***()
create table covid(covidjson variant) ;

-- to holding area
put file://desktop/yelp-weather-project/covid_19_dataset_2020_06_10/covid.json  @my_json_stage auto_compress=true;

--to stage table
copy into covid from @my_json_stage/covid.json.gz file_format=(format_name = myjsonformat) on_error = 'skip_file';





/**** now create tables for temp and precipitation data , extract and load from CSV 
-- this can be done with GUI snce files are smaller than 50mb, create a CSV format with GUI
as well or use above methods similar to JSON set up only using CSV.
****/
CREATE TABLE "YELP"."STAGE"."PRECIPITATION" (
    "DATE" string, 
    "PRECIPITATION" float, 
    "PRECIPITATION_NORMAL" float);

--load data
PUT file://<file_path>/precipitation.csv @PRECIPITATION/ui1626199815004

COPY INTO "YELP"."STAGE"."PRECIPITATION" FROM @/ui1626199815004 FILE_FORMAT = '"YELP"."STAGE"."MYCSVFORMAT"' ON_ERROR = 'ABORT_STATEMENT' PURGE = TRUE;


--create temp table and load data
CREATE TABLE "YELP"."STAGE"."TEMPERATURE" (
    "DATE" string, 
    "MIN" FLOAT, 
    "MAX" FLOAT, 
    "NORMAL_MIN" FLOAT, 
    "NORMAL_MAX" FLOAT);

PUT file://<file_path>/temperature.csv @TEMPERATURE/ui1626200284271

COPY INTO "YELP"."STAGE"."TEMPERATURE" FROM @/ui1626200284271 FILE_FORMAT = '"YELP"."STAGE"."MYCSVFORMAT"' ON_ERROR = 'ABORT_STATEMENT' PURGE = TRUE;



