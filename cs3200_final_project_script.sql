
-- ============ DROP & CREATE DATABASE (if necessary) ============
DROP DATABASE IF EXISTS final_project;

CREATE DATABASE final_project;
USE final_project;

-- CREATE PARENT TABLES
CREATE TABLE neighborhoods (
	neighborhood_id INT AUTO_INCREMENT PRIMARY KEY,
    neighborhood VARCHAR(45) NOT NULL
);

CREATE TABLE charges (
	nibrs_id VARCHAR(3) PRIMARY KEY,
    nibrs_desc VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE offenses (
	offense_id INT PRIMARY KEY,
    crime VARCHAR(100) NOT NULL
);

-- ================== CREATE CHILD TABLES ==================
CREATE TABLE arrests (
	arrest_id INT AUTO_INCREMENT PRIMARY KEY,
    neighborhood_id INT NOT NULL,
    nibrs_id VARCHAR(3) NOT NULL,
    juvenile TINYINT NOT NULL,
    arrest_date DATE NOT NULL,
    district VARCHAR(10) NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id),
    FOREIGN KEY (nibrs_id) REFERENCES charges(nibrs_id)
);

CREATE TABLE homicides (
	homicide_id INT AUTO_INCREMENT PRIMARY KEY,
    neighborhood_id INT NOT NULL,
    homicide_date DATE NOT NULL,
    district VARCHAR(10) NOT NULL,
	victim_age INT NOT NULL,
    weapon VARCHAR(45),
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

CREATE TABLE incidents (
	incident_id INT PRIMARY KEY,
    offense_id INT NOT NULL,
    neighborhood_id INT NOT NULL,
    district VARCHAR(10) NOT NULL,
    report_date_year_month DATE NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id),
    FOREIGN KEY (offense_id) REFERENCES offenses(offense_id)
);

-- ============== CREATE DEMOGRAPHIC TABLES ==============
CREATE TABLE ages (
	neighborhood_id INT PRIMARY KEY,
    total INT NOT NULL,
    median_age DECIMAL(2, 1) NOT NULL,
    age_0_9 INT NOT NULL,
    age_10_17 INT NOT NULL,
    age_18_19 INT NOT NULL,
    age_20_34 INT NOT NULL,
    age_35_59 INT NOT NULL,
    age_60_over INT NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

CREATE TABLE household_type (
	neighborhood_id INT PRIMARY KEY,
    total INT NOT NULL,
    married_family INT NOT NULL,
    male_head INT NOT NULL,
    female_head INT NOT NULL,
    living_alone INT NOT NULL,
    not_living_alone INT NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

CREATE TABLE nativity (
	neighborhood_id INT PRIMARY KEY,
    total INT NOT NULL,
    native INT NOT NULL,
    naturalization INT NOT NULL,
    not_citizen INT NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

CREATE TABLE education (
	neighborhood_id INT PRIMARY KEY,
    total_pop_over_25 INT NOT NULL,
    less_than_hs INT NOT NULL,
    hs_grad INT NOT NULL,
    ged_or_other INT NOT NULL,
    some_college INT NOT NULL,
    associates INT NOT NULL,
    bachelors INT NOT NULL,
    masters_or_more INT NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

CREATE TABLE income (
	neighborhood_id INT PRIMARY KEY,
    median_income INT NOT NULL,
    total_households INT NOT NULL,
    inc_0k_15k INT NOT NULL,
    inc_15k_25k INT NOT NULL,
    inc_25k_35k INT NOT NULL,
    inc_35k_50k INT NOT NULL,
    inc_50k_75k INT NOT NULL,
    inc_75k_100k INT NOT NULL,
    inc_100k_150k INT NOT NULL,
    inc_150k_more INT NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

CREATE TABLE poverty (
	neighborhood_id INT PRIMARY KEY,
    neighborhood_pop INT NOT NULL,
    total_in_poverty INT NOT NULL,
    poverty_rate FLOAT NOT NULL,
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(neighborhood_id)
);

-- ================= LOAD / INSERT THE DATA ===============

-- Update permissions
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

SET SQL_SAFE_UPDATES = 0;

-- ============ LOAD PARENT TABLE DATA =============
-- Neighborhoods
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/boston_neighborhoods_only.csv'
INTO TABLE neighborhoods
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(neighborhood);

INSERT INTO neighborhoods (neighborhood)
VALUES ('Unknown');

UPDATE neighborhoods
SET neighborhood = TRIM(REPLACE(REPLACE(neighborhood, '\n', ''), '\r', ''));

-- Charges
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/boston_charges.csv'
INTO TABLE charges
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nibrs_id, nibrs_desc);
    
-- Offenses
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/boston_offenses.csv'
INTO TABLE offenses
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(crime, offense_id);

DELETE FROM offenses
WHERE offense_id = 0;

-- ============== LOAD CHILD TABLE DATA ===============
-- Arrests
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/boston_arrests_BEST.csv'
INTO TABLE arrests
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(nibrs_id, juvenile, @nb_name, district, arrest_date)
SET neighborhood_id = (
	SELECT neighborhood_id
	FROM neighborhoods
	WHERE neighborhood = @nb_name);
    
-- Homicides
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/boston_homicides_BETTER.csv'
INTO TABLE homicides
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@nb_name, homicide_date, district, victim_age, weapon)
SET neighborhood_id = (
	SELECT neighborhood_id
	FROM neighborhoods
	WHERE neighborhood = @nb_name);

-- Incidents
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/boston_incidents_BETTER.csv'
INTO TABLE incidents
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(incident_id, offense_id, @nb_name, district, report_date_year_month)
SET neighborhood_id = (
	SELECT neighborhood_id
	FROM neighborhoods
	WHERE neighborhood = @nb_name);

DELETE FROM incidents
WHERE incident_id = 0;

-- ============= LOAD DEMOGRAPHIC TABLE DATA =============
-- Ages
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/neighborhood_age.csv'
INTO TABLE ages
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(@nb_name, total, median_age, age_0_9, age_10_17, age_18_19, age_20_34, age_35_59, age_60_over)
SET neighborhood_id = (
	SELECT neighborhood_id
    FROM neighborhoods
    WHERE neighborhood = @nb_name);

-- Education
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/neighborhood_education.csv'
INTO TABLE education
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@nb_name, total_pop_over_25, less_than_hs, hs_grad, ged_or_other, some_college, associates, bachelors, masters_or_more)
SET neighborhood_id = (
	SELECT neighborhood_id
    FROM neighborhoods
    WHERE neighborhood = @nb_name);

-- Household type
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/neighborhood_household_type.csv'
INTO TABLE household_type
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(@nb_name, total, married_family, male_head, female_head, living_alone, not_living_alone)
SET neighborhood_id = (
	SELECT neighborhood_id
    FROM neighborhoods
    WHERE neighborhood = @nb_name);

-- Income
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/neighborhood_household_income.csv'
INTO TABLE income
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@nb_name, median_income, total_households,inc_0k_15k, inc_15k_25k, inc_25k_35k, inc_35k_50k,
    inc_50k_75k, inc_75k_100k, inc_100k_150k, inc_150k_more)
SET neighborhood_id = (
	SELECT neighborhood_id
    FROM neighborhoods
    WHERE neighborhood = @nb_name);

-- Nativity
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/household_nativity.csv'
INTO TABLE nativity
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@nb_name, total, native, naturalization, not_citizen)
SET neighborhood_id = (
	SELECT neighborhood_id
    FROM neighborhoods
    WHERE neighborhood = @nb_name);

-- Poverty
LOAD DATA LOCAL INFILE '/Users/avatrento/Downloads/Courses/Fall 2025/CS3200/Clean Project Materials/neighborhood_poverty.csv'
INTO TABLE poverty
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@nb_name, neighborhood_pop, total_in_poverty, poverty_rate)
SET neighborhood_id = (
	SELECT neighborhood_id
    FROM neighborhoods
    WHERE neighborhood = @nb_name);

-- ========== VIEW ALL TABLES (can be pinned) ===========

SELECT * FROM neighborhoods;
SELECT * FROM charges;
SELECT * FROM offenses;
SELECT * FROM arrests;
SELECT * FROM homicides;
SELECT * FROM incidents;
SELECT * FROM ages;
SELECT * FROM education;
SELECT * FROM household_type;
SELECT * FROM income;
SELECT * FROM nativity;
SELECT * FROM poverty;

-- ================== Queries ====================

-- 1. List of Available Years in Data for arrests, homicides, and incidents 
SELECT "Incidents" AS DATA, YEAR(report_date_year_month) AS YEAR
FROM incidents
GROUP BY YEAR(report_date_year_month)
UNION
SELECT "Arrests" AS DATA, YEAR(arrest_date) AS YEAR
FROM arrests
GROUP BY YEAR(arrest_date)
UNION
SELECT "Homicides" AS DATA, YEAR(homicide_date) AS YEAR
FROM homicides
GROUP BY YEAR(homicide_date)
ORDER BY DATA, YEAR; 

-- 2.
-- 2a. Neighborhoods’ arrest count
SELECT n.neighborhood, COUNT(*) AS arrest_count
FROM arrests AS a
INNER JOIN neighborhoods AS n
ON a.neighborhood_id = n.neighborhood_id
WHERE YEAR(a.arrest_date) BETWEEN 2019 AND 2024
GROUP BY n.neighborhood
ORDER BY arrest_count;

-- 2b. Neighborhoods’ drug arrest count
SELECT n.neighborhood, COUNT(a.arrest_id) AS count_drug_arrest
FROM arrests AS a
INNER JOIN charges AS c
  ON a.nibrs_id = c.nibrs_id
INNER JOIN neighborhoods AS n
  ON a.neighborhood_id = n.neighborhood_id
WHERE c.nibrs_desc LIKE "%DRUG/NARCOTICS%"
   OR c.nibrs_desc = "DRUG/NARCOTICS VIOLATION"
   OR c.nibrs_desc LIKE "%DRUG%"  
GROUP BY n.neighborhood
ORDER BY count_drug_arrest DESC;

-- 3. Different incidents for all the neighborhoods 
SELECT n.neighborhood, o.crime, COUNT(*) as crime_count
FROM incidents i
JOIN offenses o ON i.offense_id = o.offense_id
JOIN neighborhoods n ON i.neighborhood_id = n.neighborhood_id
GROUP BY n.neighborhood_id, n.neighborhood, o.crime
ORDER BY n.neighborhood, crime_count DESC;

-- 4.
-- 4a. The most common crime in each neighborhood
SELECT n.neighborhood, c.crime AS most_common_crime, c.count
FROM (
    SELECT i.neighborhood_id, o.crime, COUNT(*) as count
    FROM incidents i
    JOIN offenses o ON i.offense_id = o.offense_id
    GROUP BY i.neighborhood_id, o.crime
) c
JOIN (
    SELECT neighborhood_id, MAX(count) as max_count
    FROM (
        SELECT i.neighborhood_id, o.crime, COUNT(*) as count
        FROM incidents i
        JOIN offenses o ON i.offense_id = o.offense_id
        GROUP BY i.neighborhood_id, o.crime
    )count
    GROUP BY neighborhood_id
) mc ON c.neighborhood_id = mc.neighborhood_id AND c.count = mc.max_count
JOIN neighborhoods n ON c.neighborhood_id = n.neighborhood_id
ORDER BY c.count DESC;

-- 4b. The most common crime in each neighborhood (excluding mv crash response)
SELECT n.neighborhood, c.crime AS most_common_crime, c.count
FROM (
    SELECT 
        i.neighborhood_id, 
        o.crime, 
        COUNT(*) as count
    FROM incidents i
    JOIN offenses o ON i.offense_id = o.offense_id
    WHERE o.crime NOT LIKE "%mv crash response%"
    GROUP BY i.neighborhood_id, o.crime
) c
JOIN (
    SELECT 
        neighborhood_id, 
        MAX(count) as max_count
    FROM (
        SELECT 
            i.neighborhood_id, 
            o.crime, 
            COUNT(*) as count
        FROM incidents i
        JOIN offenses o ON i.offense_id = o.offense_id
        WHERE o.crime NOT LIKE "%mv crash response%"
        GROUP BY i.neighborhood_id, o.crime
    )count
    GROUP BY neighborhood_id
) mc ON c.neighborhood_id = mc.neighborhood_id AND c.count = mc.max_count
JOIN neighborhoods n ON c.neighborhood_id = n.neighborhood_id
ORDER BY c.count DESC;

-- 5. The list of neighborhoods with the highest number of homicides (between 2019 to 2024)
SELECT n.neighborhood, COUNT(h.homicide_id) AS homicide_count
FROM homicides h
JOIN neighborhoods n ON h.neighborhood_id = n.neighborhood_id
WHERE h.homicide_date BETWEEN "2019-01-01" AND "2024-12-31"
GROUP BY n.neighborhood
ORDER BY homicide_count DESC;

-- 6.
-- 6a. Neighborhoods’ max victim age 
SELECT n.neighborhood, MAX(h.victim_age) AS max_victim_age
FROM homicides AS h
INNER JOIN neighborhoods AS n
ON h.neighborhood_id = n.neighborhood_id
WHERE YEAR(h.homicide_date) = 2024
GROUP BY n.neighborhood;

-- 6b. Neighborhoods’ average victim age
SELECT n.neighborhood, AVG(h.victim_age) AS avg_victim_age
FROM homicides AS h
INNER JOIN neighborhoods AS n
ON h.neighborhood_id = n.neighborhood_id
WHERE YEAR(h.homicide_date) = 2024
GROUP BY n.neighborhood;

-- 7. List of neighborhoods’ median income, arrest rate, and most common arrest label 
SELECT n.neighborhood, i.median_income, ROUND((COUNT(a.arrest_id) * 1000.0 / p.neighborhood_pop), 2) AS arrest_rate,
    (	SELECT c.nibrs_desc
        FROM arrests a
        JOIN charges c ON a.nibrs_id = c.nibrs_id
        WHERE a.neighborhood_id = n.neighborhood_id
        GROUP BY a.nibrs_id, c.nibrs_desc
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_common_arrest
FROM neighborhoods n
JOIN income i ON n.neighborhood_id = i.neighborhood_id
JOIN poverty p ON n.neighborhood_id = p.neighborhood_id
LEFT JOIN arrests a ON n.neighborhood_id = a.neighborhood_id
GROUP BY n.neighborhood_id, n.neighborhood, i.median_income, p.neighborhood_pop
ORDER BY i.median_income DESC;

-- 8. List of neighborhoods’ poverty rate, average annual crime rate, average annual arrest rate, total incidents, total arrests
SELECT n.neighborhood, p.poverty_rate, ROUND((inc.incident_count * 1000.0 / p.neighborhood_pop / inc.years_of_data), 2) AS avg_annual_crime_rate,
    ROUND((a.arrest_count * 1000.0 / p.neighborhood_pop / a.years_of_data), 2) AS avg_annual_arrest_rate,
    inc.incident_count AS total_incidents,
    a.arrest_count AS total_arrests
FROM neighborhoods n
JOIN poverty p ON n.neighborhood_id = p.neighborhood_id
LEFT JOIN (
    SELECT neighborhood_id, COUNT(*) AS incident_count, COUNT(DISTINCT YEAR(report_date_year_month)) AS years_of_data
    FROM incidents 
    GROUP BY neighborhood_id
) inc ON n.neighborhood_id = inc.neighborhood_id
LEFT JOIN (
    SELECT neighborhood_id, COUNT(*) AS arrest_count, COUNT(DISTINCT YEAR(arrest_date)) AS years_of_data
    FROM arrests 
    GROUP BY neighborhood_id
) a ON n.neighborhood_id = a.neighborhood_id
ORDER BY p.poverty_rate DESC;

-- 9. List of neighborhoods’ education college enrollment rate and property crime 
SELECT n.neighborhood, 
    ROUND(((e.some_college + e.associates + e.bachelors + e.masters_or_more) * 100.0 / e.total_pop_over_25), 2) AS college_enrollment_rate,
    ROUND((COUNT(i.incident_id) * 1000.0 / a.total), 2) AS property_crime_rate_per_1000,
    COUNT(i.incident_id) AS property_crime_count
FROM neighborhoods AS n
JOIN education AS e ON n.neighborhood_id = e.neighborhood_id
JOIN ages AS a ON n.neighborhood_id = a.neighborhood_id
LEFT JOIN incidents AS i ON n.neighborhood_id = i.neighborhood_id
LEFT JOIN offenses AS o ON i.offense_id = o.offense_id 
    AND (o.crime LIKE "%LARCENY%" 
         OR o.crime LIKE "%BURGLARY%" 
         OR o.crime LIKE "%THEFT%")
GROUP BY n.neighborhood_id, n.neighborhood, e.some_college, e.associates, 
         e.bachelors, e.masters_or_more, e.total_pop_over_25, a.total
ORDER BY property_crime_rate_per_1000 DESC;

-- 10. List of neighborhoods’ foreign/native born, median income, college educated, and poverty rate
SELECT n.neighborhood, ROUND((nat.not_citizen * 100.0 / nat.total), 1) AS foreign_born_percent, ROUND((nat.native * 100.0 / nat.total), 1) AS native_born_percent, i.median_income,
    ROUND((e.some_college + e.associates + e.bachelors + e.masters_or_more) * 100.0 / e.total_pop_over_25, 1) AS percent_college_educated, p.poverty_rate
FROM neighborhoods n
JOIN nativity nat ON n.neighborhood_id = nat.neighborhood_id
JOIN income i ON n.neighborhood_id = i.neighborhood_id
JOIN education e ON n.neighborhood_id = e.neighborhood_id
JOIN poverty p ON n.neighborhood_id = p.neighborhood_id
ORDER BY foreign_born_percent DESC;







    