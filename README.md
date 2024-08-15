# Analysing the cost implications of patient admission using SQL


![image](https://github.com/user-attachments/assets/c922833b-d954-4843-a35d-e7c8ef412bb3)



# Table of contents

- [Objective](#objective)
- [Data Source](#data-source)
- [Stages](#stages)
- [Design](#design)
  - [Mockup](#mockup)
  - [Tools](#tools)
- [Development](#development)
  - [Pseudocode](#pseudocode)
  - [Data Exploration](#data-exploration)
  - [Data Cleaning](#data-cleaning)
  - [Data Transformation](#data-transformation)
  - [Create SQL View](#create-sql-view)
- [Visualization](#visualization)
  - [Results](#results)
  - [DAX Measures](#dax-measures)
- [Analysis](#analysis)
  - [Findings](#findings)
  - [Insights](#insights)
- [Recommendation](#recommendation)
- [Conclusion](#conclusion)



  # Objective

  - What is the business problem?

  The Chief Operating Officer of the Hospital aims to determine the financial implication of admitting patients in a secondary care services.


  - What could be the ideal solution?
 
  Access the hospital database using SQL and create a visualization that provides insights into the factors that contribute to running cost in the facility. The visualization/dashboard would show

  - Total patients
  - Average cost per day on each patient
  - Average stay
  - Top spending insurance company
  - Cost of managing each medical condition

  This will help the chief operating officer to make informed decisions on service efficiency and cost cutting measures.

## User story

As the COO of the Trust, I want to visualize the cost implications of admitting patients in the our hospital. 

This dashboard should help me identify the top contributing insurance providers, and cost of managing patients in our hospital.

With this information, I can make informed decisions about which insurance companies to work with, and the services to cut to reduce the overall runnning cost.


# Data Source

- What data is needed to achieve the set out objective?

The dataset should include;
- Gender
- Medical Condition
- Insurance provider
- Age group
- Date of admission
- Date of discharge


The dataset is sourced fron kaggle in an CSV file format, [see here to find it](https://www.kaggle.com/datasets/muhammadehsan000/healthcare-dataset-2019-2024/data?select=healthcare_dataset.csv)


# Stages

- Design
- Development
- Analysis


# Design

## Dashboard composition
- what should the dashboard show based on the requirements provided?

To understand what it should contain, we need to understand what business questions the dashboard need to answer.

1. How many patients are admitted in the hospital?
2. What are the contributions of each insurance providers?
3. What is the cost of patient admission based on age group?
4. What are the cost of managing each medical conditions?
5. What are the cost of acquiring medications?
6. How much does it cost to manage each patient per day?


## Dashboard mockup

- The dashboard layout will contain the following visuals to answer our question;

1. TreeMap
2. Column chart
3. Bar chart
4. Tables
5. Score cards
6. Filters for interactvity

![image](https://github.com/user-attachments/assets/9f556d25-ad52-430b-9181-fa53f49e20c4)


## Tools


| Tool | Purpose |
| --- | --- |
| Excel | Exploring the data |
| SQL Server | Cleaning, testing, and analyzing the data |
| Power BI | Visualizing the data via interactive dashboards |
| GitHub | Hosting the project documentation and version control |
| Mokkup AI | Designing the wireframe/mockup of the dashboard | 

# Development

## Pseudocode

- What is the best approach to create the solution from start to finish?

1. Get the data
2. Explore the data in Excel
3. Load the data into SQL Server
4. Clean the data with SQL
5. Test the data with SQL
6. Visualize the data in Power BI
7. Generate the findings based on the insights
8. Write the documentation 
9. Publish and present findings to the board.

## Data exploration 


## Data Cleaning

The aim is to normlize and structure our dataset to be ready for analysis.


The cleaned data should meet the following criteria:

- Contain only columns relevant to the analysis
- All data types should be appropriate for the contents of each column
- No null and blank values in the dataset indicating complete data for all records.

To attaiin a normalized dataset, the following steps are required;

1. Remove irrelavant columns by dropping them from the duplicate table
2. Remove null and blank fields in the dataset



## Data Transformation 


```sql

/*
# 1. Create new columns 'agegroup' and 'Duration'
# 2. Update created columns from exisiting columns
*/


-- 1a.
ALTER TABLE health_care_adm
ADD Age_Group varchar(30);

UPDATE health_care_adm
SET Age_Group = CASE
 	           WHEN Age BETWEEN 13 AND 19 THEN 'Teenager(13-19y)'
		   WHEN Age BETWEEN 20 AND 32 THEN 'Young_Adult(20-32y)'
		   WHEN Age BETWEEN 33 AND 52 THEN 'Adult(33-52y)'
		   WHEN Age BETWEEN 53 AND 72 THEN 'Late middle-Aged(53-72y)'
		   ELSE 'Senior(>73y)'
		END;

-- 1b.
ALTER TABLE health_care_adm
ADD Duration INT;

UPDATE health_care_adm
SET Duration = DATEDIFF(day, Date_of_Admission, Discharge_Date);

```

## Create SQL View

```sql
/*
# 1. Create view to store transformed dataset
# 2. Select the relevant columns from the existing table
*/

-- 1.
CREATE VIEW health_care_adm_view AS

-- 2.
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

-- 3.
FROM 
	health_care_adm
```

# Visualization

## Results

The final dashboard shows a detailed analysis of the cost of managing patients and associated medical conditions on daily basis in the hospital.


![image](https://github.com/user-attachments/assets/1c20b875-b59f-4339-a0ae-915fa68eb22f)


## DAX Measures

### 1. Total Billing
```sql
Total Billing (M) = 
VAR Million = 1000000
VAR SumofBilling = SUM(health_care_adm_view[Billing_Amount])
VAR TotalBilling = DIVIDE(SumofBilling, Million)

Return TotalBilling

```

### 2. Average Billing 
```sql
Average Billing (M) = 
VAR Million = 1000
VAR AvgBilling = AVERAGE(health_care_adm_view[Billing_Amount])
VAR AverageTotalBilling = DIVIDE(AvgBilling, Million)

Return AverageTotalBilling
```

### 3. Average Billing Per day
```sql
Average Billing per day = 
VAR TotalBilling = SUM(health_care_adm_view[Billing_Amount])
VAR TotalDays = SUM(health_care_adm_view[Duration])
Var AvgBillingDay = DIVIDE(TotalBilling, TotalDays)

Return AvgBillingDay
```

### 4. Average stay
```sql
Average Stay (days) = 
VAR AverageStay = AVERAGE(health_care_adm_view[Duration])

Return AverageStay
```
### 5. Total Patients Admitted 
```sql
Total Patients Admitted = 
VAR countofpatients = COUNT(health_care_adm_view[Gender])

Return countofpatients
```

### 6. Total Female Admitted
```sql
Total Female Admitted = 
VAR CountofFemalePatients = COUNTROWS(FILTER(health_care_adm_view, health_care_adm_view[Gender] = "Female"))

Return CountofFemalePatients
```

### 7. Total Male Admitted
```sql
Total Male Admitted = 
VAR CountofmalePatients = COUNTROWS(FILTER(health_care_adm_view, health_care_adm_view[Gender] = "Male"))

Return CountofmalePatients
```

# Analysis

## Findings

#### 1. What are the top contributing insurance providers?

| Rank | Insurance providers    | Total contributions(m) |
|------|------------------------|------------------------|
| 1    | Cigna                  |   287.14               | 
| 2    | Medicare               |   285.72               |
| 3    | Bluecross              |   283.25               |
| 4    | United Healthcare      |   282.45               |
| 5    | Aetna                  |   278.86               |


#### 2. What is the cost of admission by age group?
| Rank | Age Group              | Total cost(m)         |
|------|------------------------|-----------------------|
| 1    |Late middle-aged(53-72y)| 420.39                | 
| 2    |Adult(33-52y)           | 417.80                |
| 3    |Senior(>73y)            | 270.42                |
| 4    |Young Adult(20-32y)     | 264.33                |
| 5    |Teenagers(13-19y)       | 44.50                 |


#### 3. What is the cost of managing each medical condition?

| Rank | Medical Condition      | Total cost(m)         |
|------|------------------------|-----------------------|
| 1    |Diabetes                | 238.24                | 
| 2    |Obesity                 | 238.21                |
| 3    |Arthritis               | 237.33                |
| 4    |Hypertension            | 235.72                |
| 5    |Asthma                  | 235.46                |
| 6    |Cancer                  | 232.17                |


### 4. What is the cost implication of medications ?

| Rank | Medication             | Total costs(m)        |
|------|------------------------|-----------------------|
| 1    |Ibuprofen               | 286.36                | 
| 2    |Aspirin                 | 283.94                |
| 3    |Paracetamol             | 282.68                |
| 4    |Penicillin              | 282.13                |
| 5    |Liptor                  | 282.32                |



## Insights

Our findings show that insurance providers such as Medicare and Cigna provide the best value for money. On average, the daily cost of admitting a patient over a 24 hour period is £1639 and £1648 respectively despite covering the larger number of patients. 
On the other hand, covering fewer number of patients, BlueCross, Aetna, and United Healthcare have a significantly higher daily costs in managing the patients on the hospital service. 

We also observed cost variation amongst these providers for similar conditions and duration of stay. This suggests a revisit to the exisiting contract for renegotiation as it does not meet the cost cutting criteria put in place by the new management.

Secondly, "late middle-aged (53-73y)" patients have the highest cost of admission on the service, further analysis suggest a relationship between complex cases such as diabetes and obesity which are prevalent in this age group needing longer hospital stay. As expected, the "Senior(>73y)" age group were majorly admitted into care for arthritis which is prevalent in individuals of that age. Teenagers(13-19y) accured the least cost of admission as the conditions under consideration are mostly susceptible to adults and elderly.

Thirdly, diabetes and obesity are chronic conditions that require continous and long-term management. They require regular doctor visits and medications contributing to high cost of management seen in the dataset available. Additionally, it is highly prevalent and  affect a greater proportion of the population. Despite seen as cost intensive, cancer is seen to have accured the least cost over the time period. This is because cancer treatment is often shorter-term or time limited as opposed to obesity and diabetes which require lifestyle changes and frequent hospital visits.

Finally, The high cost seen in medications such as Ibuprofen could be due to its versatility and wide use in managing most medical conditions. Additionally, their frequent and long-term use despite its relatively low cost per dose can be a contributing factor in the high cost. 

# Recommendations

1. Given that individuals aged between 53 and 73 years spend the longer time under secondary care, accuring the highest cost of management, negotiating an age-specific insurance policy is advised to ensure transparency in dealing with every age groups under the service.
2. Insurance providers Medicare and Cigna offer the best price of managing a patient daily. Negotiating with these providers to expand their offerings on better rates for these medical conditions that accure high cost should be considered.
3. To effectively reduce cost accured in the procurement of medication, procurement process for medication such as Ibuprofen which is widely used in the service should be reviewed by the board to explore other cost saving opportunities such as bulk purchase or alternative suppliers.
4. To improve efficiency in the management of patients, thus reducing the duration of stay, the use of multidisciplinary teams is advised to ensure each patient is given the best care which  in turn reduce the number of days spent in the service.


# Conclusion

Based data driven insights, implementing the recommendation can effectively manage costs, improve operational efficiency, and imporve patient outcomes. 
