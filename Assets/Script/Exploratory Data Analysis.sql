/*
This project is aimed to analyse patients admission to understand the factors that are related to patient care, resource utilisation
and financial metric.
The objective of this study will identify pattrerns that could lead to improved outcomes, optimised resource allocation, and efficient billing process.
*/

-- Create a database for datasourcing and manipulation

CREATE DATABASE healthcare_db;

USE healthcare_db;

-- Import flat file from Excel to serve as database content
SELECT TOP(1000) *
FROM Health_Care_Admissions;

-- Create a duplicate copy to preserve the original structure of the raw data;

SELECT *
INTO 
	health_care_adm
FROM
	Health_Care_Admissions;

-- To verify if the duplicate copy was created

SELECT TOP (100) *
FROM health_care_adm;

-- Dataset Normalisation and overview
/*
# 1. Create an agegroup column
# 2. Convert 'billing_amount' column to a two decimal figure
# 3. Find the length of stay in hospital by subtracting date of admission from date of discharge
# 4. Drop columns not relevant to the analysis
*/

-- Go through the columns relevant to analysis to check for errors
-- Age
SELECT MAX (Age) AS Maximum_Age, MIN(Age) AS Minimum_Age
FROM health_care_adm;

-- Gender
SELECT DISTINCT Gender
FROM health_care_adm;

-- Blood Group
SELECT DISTINCT Blood_Type
FROM health_care_adm;

-- Insurance Cover
SELECT DISTINCT Insurance_Provider
FROM health_care_adm;

-- Medical_Condition
SELECT DISTINCT Medical_Condition
FROM health_care_adm;

-- Medication
SELECT DISTINCT Medication
FROM health_care_adm;

-- Test Results
SELECT DISTINCT Test_Results
FROM health_care_adm;


/*
# 1. create new columns for agegroup and duration of stay in the hospital'
# 2. Create column for duration of stay in the hospital
# 3. Convert the billing column to 2 decimal places
# 4. Drop irrelevant column by creating a new table
# 5. check for null fields
*/
--- 1. 
ALTER TABLE health_care_adm
ADD Age_Group varchar(30);

-- Populate the new column using the existing column
UPDATE health_care_adm
SET Age_Group = CASE
					WHEN Age BETWEEN 13 AND 19 THEN 'Teenager(13-19y)'
					WHEN Age BETWEEN 20 AND 32 THEN 'Young_Adult(20-32y)'
					WHEN Age BETWEEN 33 AND 52 THEN 'Adult(33-52y)'
					WHEN Age BETWEEN 53 AND 72 THEN 'Late middle-Aged(53-72y)'
					ELSE 'Senior(>73y)'
				END;

SELECT TOP (100) *
FROM health_care_adm;

--- 2. 
ALTER TABLE health_care_adm
ADD Duration INT;


-- POPULATE THE COLUMN
UPDATE health_care_adm
SET Duration = DATEDIFF(day, Date_of_Admission, Discharge_Date);

--- 3.

UPDATE health_care_adm
SET Billing_Amount = ROUND(Billing_Amount, 2);

-- 4.
-- Drop columns not relevant to our analysis
ALTER TABLE health_care_adm
DROP COLUMN Name,
		 Age,
		 Date_of_Admission,
		 Doctor,
		 Hospital,
		 Room_Number,
		 Discharge_Date;

-- To verify the columns have been dropped

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'health_care_adm';


-- 5. 
SELECT *
FROM health_care_adm
WHERE gender is null;

--- DETAILED EXPLORATORY DATA ANALYSIS
-- 1. What is the proportion of male to female

SELECT Gender, COUNT(*) AS Count,
								CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_care_adm)), 2) AS float) AS Proportion_of_Gender
FROM health_care_adm
GROUP BY Gender;

-- 2. What is the distribution of patients by agegroup

SELECT Age_Group,  COUNT (*) AS Count_of_Patients, 
									CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_care_adm)), 1)AS FLOAT) AS Percent_of_Patients
FROM health_care_adm
GROUP BY Age_Group
ORDER BY Count_of_Patients DESC;

-- 3. What is the proportion of medical condition in the hospital?

SELECT 
	Medical_Condition,
		COUNT(*) AS Count_of_Condition, 
			CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_care_adm)),0) AS FLOAT) AS Proportion_of_Condition
FROM 
	health_care_adm

WHERE Medical_Condition IN ('Diabetes', 'Cancer')

GROUP BY Medical_Condition;

-- 4. What is the distribution of Age group by medical condition (Cancer)
SELECT Age_Group, 
		Medical_Condition, 
		Count(*) AS Count_of_Patients,
		CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_care_adm)),1) AS FLOAT) AS Percent_of_Patients
FROM 
	health_care_adm
WHERE 
	Medical_Condition = 'Cancer'
GROUP BY 
	Age_Group, Medical_Condition
ORDER BY 
	Count_of_Patients DESC;

-- 6. What is the distribution of Age group by medical condition (Diabetes)
SELECT Age_Group, 
		Medical_Condition, 
		Count(*) AS Count_of_Patients,
		CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_care_adm)),1) AS FLOAT) AS Percent_of_Patients
FROM 
	health_care_adm
WHERE 
	Medical_Condition = 'Diabetes'
GROUP BY 
	Age_Group, Medical_Condition
ORDER BY 
	Count_of_Patients DESC; 

-- 6. What is distribution of insurance providers and amount covered.

SELECT Insurance_Provider,
		ROUND(Sum(Billing_Amount),1) AS Total_Billing_Amount	
FROM 
	health_care_adm
GROUP BY 
	Insurance_Provider
ORDER BY 
	Total_Billing_Amount DESC;

-- 7. Contribution of amount by insurance providers
SELECT TOP 1 WITH TIES
		Medical_Condition, 
		Insurance_Provider,
		ROUND(SUM(Billing_Amount),2) AS Total_Contribution
FROM
	health_care_adm
GROUP BY
	Medical_Condition,
	Insurance_Provider
ORDER BY 
	ROW_NUMBER( ) OVER (PARTITION BY Insurance_Provider ORDER BY ROUND(SUM(Billing_Amount),2) DESC);

-- 8. Duration of stay in the hospital by medical condition
SELECT
	Medical_Condition,
	SUM(Duration) AS Total_stay
FROM 
	health_care_adm
GROUP BY
	Medical_Condition
ORDER BY
	Total_stay desc;

-- 9. Admission type by age group and medical condition
SELECT TOP 1 WITH TIES
	Admission_Type,
	Medical_Condition,
	Age_Group,
	COUNT (*) AS Total_Count
FROM
	health_care_adm
GROUP BY
	Admission_Type,
	Medical_Condition,
	Age_Group
ORDER BY
	ROW_NUMBER() OVER (PARTITION BY Admission_Type ORDER BY COUNT (*) DESC);

-- Create a views_table for PowerBI visualisation.
CREATE VIEW health_care_adm_view AS
SELECT
	Gender,
	Medical_Condition,
	Insurance_Provider,
	Billing_Amount,
	Admission_Type,
	Medication,
	Test_Results,
	Age_Group,
	Duration
FROM 
	health_care_adm

-- Confirm the views
SELECT TOP (100) *
FROM health_care_adm_view;