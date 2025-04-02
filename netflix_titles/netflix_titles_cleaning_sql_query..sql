-- Data Cleaning in SQL--


Select *
From netflix;


-- Step 1: Remove Duplicates 

CREATE TABLE netflix_cleaned
LIKE netflix;

SELECT *
FROM netflix_cleaned;

INSERT netflix_cleaned
SELECT *
FROM netflix;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY show_id, 'type', title, director, date_added, release_year) AS row_num
FROM netflix_cleaned;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY show_id, 'type', title, director, date_added, release_year) AS row_num
FROM netflix_cleaned
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

	-- No Duplicates Found --



-- Step 2: Standardize the Data

	-- country --
    
SELECT country
FROM netflix_cleaned;

SELECT country
FROM netflix_cleaned 
WHERE country LIKE '%,%';

SELECT country
FROM netflix_cleaned 
WHERE country LIKE ',%';

		/* The above query returned two rows which had commas at the begining */

SELECT country,
TRIM(LEADING ',' FROM country)
FROM netflix_cleaned
WHERE country LIKE ',%';

UPDATE netflix_cleaned
SET country = TRIM(LEADING ',' FROM country)
WHERE country LIKE ',%'; 
    
SELECT country,
TRIM(SUBSTRING(country, 1,LOCATE(',', country)-1))
FROM netflix_cleaned
WHERE country LIKE '%,%';

UPDATE netflix_cleaned
SET country = TRIM(SUBSTRING(country, 1,LOCATE(',', country)-1))
WHERE country LIKE '%,%';

SELECT country, TRIM(country)
FROM netflix_cleaned;

UPDATE netflix_cleaned
SET country = TRIM(country);

	-- data_added --

SELECT date_added
FROM netflix_cleaned;

SELECT date_added
FROM netflix_cleaned
WHERE date_added = '';

UPDATE netflix_cleaned
SET date_added = NULL
WHERE date_added = '';

SELECT date_added,
STR_TO_DATE(date_added, '%M %d,%Y')
FROM netflix_cleaned;

UPDATE netflix_cleaned
SET date_added = STR_TO_DATE(date_added, '%M %d,%Y');

ALTER TABLE netflix_cleaned
MODIFY COLUMN date_added DATE;



-- Step 3: Null Values or blank values

SELECT 
	SUM(show_id = '') AS show_id_blank,
    SUM(type = '') AS type_blank,
	SUM(title = '') AS title_blank,
    SUM(director = '') AS director_blank,
    SUM(cast = '') AS cast_blank,
    SUM(country = '') AS country_blank,
    SUM('date_added' = '') AS date_added_blank,
    SUM(release_year = '') AS release_year_blank,
	SUM(rating = '') AS rating_blank,
	SUM(duration = '') AS duration_blank,
	SUM(listed_in = '') AS listed_in_blank,
	SUM(description = '') AS description_blank
FROM netflix_cleaned;

SELECT 
	SUM(show_id IS NULL) AS show_id_null,
    SUM('type' IS NULL) AS type_null,
	SUM(title IS NULL) AS title_null,
    SUM(director IS NULL) AS director_null,
    SUM(cast IS NULL) AS cast_null,
    SUM(country IS NULL) AS country_null,
    SUM(date_added IS NULL) AS date_added_null,
    SUM(release_year IS NULL) AS release_year_null,
	SUM(rating IS NULL) AS rating_null,
	SUM(duration IS NULL) AS duration_null,
	SUM(listed_in IS NULL) AS listed_in_null,
	SUM(description IS NULL) AS description_null
FROM netflix_cleaned;

UPDATE netflix_cleaned
SET director = NULLIF(director, ''),
    cast = NULLIF(cast, ''),
    country = NULLIF(country, ''),
    rating = NULLIF(rating, ''),
    duration = NULLIF(duration, '');
    


-- Step 3: Null Values or blank values

ALTER TABLE netflix_cleaned
DROP COLUMN cast;

ALTER TABLE netflix_cleaned
DROP COLUMN description;


SELECT *
FROM netflix_cleaned;