/*********************************************************************
Now that the ODS is complete and the ERD is done as well, a STAR schema
is created to map our analysis tables using a FACT and DIM feature of the STAR
schema. Here is where the analysis will take shape and queries will be created
to gain insight to the question: does weather affect Yelp reviews?
Lets find out...

Last Update: 7/18/2021
***********************************************************************/

--to create tables and perform ETL from ODS for reporting and analytics
CREATE SCHEMA "YELP"."DW";