SELECT *
FROM sales_dataset;

SELECT *
FROM samplestore_assignment;

SET sql_safe_updates = 0;
UPDATE samplestore_assignment
SET Sales = REPLACE(REPLACE(Sales, '$', ''), ',', '');

SET sql_safe_updates = 0;
UPDATE samplestore_assignment
SET profit = REPLACE(
               REPLACE(
                   REPLACE(
                       REPLACE(profit, '$', ''),
                   '(', ''),
               ')', ''),
           ',', '');

SELECT `Ship_Date` 
	FROM samplestore_assignment;
    
ALTER TABLE samplestore_assignment ADD Ship_dates DATE;

UPDATE samplestore_assignment
SET Ship_dates = STR_TO_DATE(`Ship_Date`, '%m/%d/%Y');

SELECT `Order_Date` 
	FROM samplestore_assignment;
    
ALTER TABLE samplestore_assignment ADD order_dates DATE;
UPDATE samplestore_assignment
SET order_dates = STR_TO_DATE(`Order_Date`, '%m/%d/%Y');

-- Which sub-categories tend to be sold in high quantities but result in poor or negative profits?-- 

SELECT
	'Sub-category',
    SUM(Quantity) AS Total_Quantity,
    ROUND(SUM(profit),2) AS Total_profit
FROM samplestore_assignment
GROUP BY'Sub-category'
HAVING SUM(Quantity) > (SELECT 
								AVG(Quantity)
                                FROM samplestore_assignment
                                )
AND SUM(Profit) <= 0
ORDER BY Total_Quantity DESC;
-- Are higher discounts consistently linked to lower profits across all markets, or are there exceptions?
SELECT 
    Segment,
    Market,
    ROUND(AVG(Discount), 2) AS avg_discount,
    ROUND(AVG(Profit), 2) AS avg_profit
FROM 
    samplestore_assignment
GROUP BY 
    Segment, Market
ORDER BY 
    Segment, avg_discount DESC;
    
-- Which customer segments benefit from high discounts yet still generate substantial profit?
SELECT 
    Segment,
    ROUND(AVG(Discount),2) AS avg_dis,
    ROUND(sum(profit),2) AS tot_pro
FROM 
    samplestore_assignment
GROUP BY 
    Segment
ORDER BY 
    Segment
    ;

-- Which cities are purchasing the most items overall, and how do their profit patterns compare?

SELECT 
    Segment,
    ROUND(SUM(quantity),2) AS Total_Quantity,
    ROUND(sum(profit),2) AS tot_pro
FROM 
    samplestore_assignment
GROUP BY 
    City
ORDER BY 
    Total_Quantity DESC
;    

 -- Which markets (e.g., Asia Pacific, Europe) show the largest disparity between sales and profit?
 
 SELECT 
    Market,
    SUM(sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Sales) - SUM(Profit) AS Sales_Profit_Disparity
FROM 
    samplestore_assignment
GROUP BY 
    Market
ORDER BY 
    Sales_Profit_Disparity DESC;

 -- Are there any delays between order date and ship date that occur more in certain regions or for specific segments?

SELECT 
    Region,
    Segment,
    AVG(DATEDIFF(Ship_Dates, Order_Dates)) AS Avg_Shipping_Delay,
    MAX(DATEDIFF(Ship_Dates, Order_Dates)) AS Max_Delay,
    MIN(DATEDIFF(Ship_Dates, Order_Dates)) AS Min_Delay
FROM 
    samplestore_assignment
GROUP BY 
    Region, Segment
ORDER BY 
    Avg_Shipping_Delay DESC
    ;
 
 -- Which year or quarter had the best overall profit performance globally?
 
SELECT 
    YEAR(Order_Dates) AS Order_Year,
    QUARTER(Order_Dates) AS Order_Quarter,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM 
    samplestore_assignment
GROUP BY 
    Order_Year, Order_Quarter
ORDER BY 
    Total_Profit DESC
;

 -- Identify seasonal patterns — are there specific months where losses spike or profits soar?
 
SELECT 
    MONTH(Order_Dates) AS Order_Month,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM 
    samplestore_assignment
GROUP BY 
    Order_Month
ORDER BY 
    Order_Month
;

 
 SET sql_safe_updates = 0;
SELECT *
FROM finance; 

SELECT 
    STR_TO_DATE(Date, '%d-%b-%Y') AS formatted_date
FROM 
    finance;
ALTER TABLE finance ADD COLUMN Date_Formatted DATE;

UPDATE finance
SET Date_Formatted = STR_TO_DATE(Date, '%d-%b-%Y');


 -- Which days saw the stock open lower than the previous day’s close but close higher than it opened?
 
 SELECT 
    Date_formatted,
    `Open Price`,
    `Close Price`,
    `Prev Close`
FROM 
    finance
WHERE 
    `Open Price` < `Prev Close`
    AND `Close Price` > `Open Price`
ORDER BY 
    Date_formatted
;

-- Find the dates when the stock price reached or exceeded ₹1000 during the day.

SELECT 
    Date_Formatted,
    `High Price`
FROM 
    finance
WHERE 
    `High Price` >= 1000
ORDER BY 
	Date_Formatted
;

SELECT 
    Date_Formatted,
    `Total Traded Quantity`,
    Turnover
FROM 
    finance
WHERE 
    `Total Traded Quantity` < 1000
	AND Turnover > 50000
ORDER BY 
	Date_Formatted
;

-- Identify all dates where the daily price range (high minus low) exceeded ₹100.

SELECT 
    Date_Formatted,
    `High Price`,
    `Low Price`,
    (`High Price` - `Low Price`) AS Daily_Range
FROM 
    finance
WHERE 
    (`High Price` - `Low Price`) > 100
ORDER BY 
	Date_Formatted
;
-- What is the average closing price for each year?

SELECT 
    YEAR(Date_Formatted) AS Year,
    AVG(`Close Price`) AS Avg_Closing_Price
FROM 
    finance
GROUP BY 
    YEAR(Date_Formatted)
ORDER BY 
    Year;


 -- Calculate the total number of shares traded each year.
 
 SELECT 
     YEAR(Date_Formatted) AS Year,
    SUM(`Total Traded Quantity`) AS Total_Shares_Traded
FROM 
    finance
GROUP BY 
     YEAR(Date_Formatted)
ORDER BY 
    Year;


 -- Which year had the highest average turnover per trading day?
 
 SELECT 
   YEAR(Date_Formatted) AS Year,
    AVG(Turnover) AS Avg_Turnover
FROM 
    finance
GROUP BY 
    YEAR(Date_Formatted)
ORDER BY 
    Avg_Turnover DESC
;

-- Find the years where the average traded quantity was below 5,000.

SELECT 
    YEAR(Date_Formatted) AS Year,
    AVG(`Total Traded Quantity`) AS Avg_Traded_Quantity
FROM 
    finance
GROUP BY 
     YEAR(Date_Formatted)
HAVING 
    Avg_Traded_Quantity < 5000
ORDER BY 
    Year;


-- Which months had an average close price above ₹500?

SELECT 
    DATE_FORMAT(Date_Formatted, '%b') AS Month,
    AVG(`Close Price`) AS Avg_Close_Price
FROM 
    finance
GROUP BY 
    DATE_FORMAT(Date_Formatted, '%b')
HAVING 
    Avg_Close_Price > 500
ORDER BY 
    STR_TO_DATE(Month, '%b');

SELECT *
FROM hr_data;

UPDATE hr_data
SET hire__dates = CASE
    WHEN hire_date LIKE '%/%/%' THEN STR_TO_DATE(hire_date, '%c/%e/%Y')
    WHEN hire_date LIKE '%-%-%' THEN STR_TO_DATE(hire_date, '%d-%m-%y')
    ELSE NULL
END;

ALTER TABLE hr_data
DROP COLUMN hire_dates;

ALTER TABLE hr_data ADD birth_date DATE;
UPDATE hr_data
SET birth_date = CASE
    WHEN birthdate LIKE '%/%/%' THEN STR_TO_DATE(birthdate, '%c/%e/%Y')
    WHEN birthdate LIKE '%-%-%' THEN STR_TO_DATE(birthdate, '%d-%m-%y')
    ELSE NULL
END
;

-- What is the gender breakdown in the Company?

SELECT 
	Gender, 
    COUNT(gender) AS count
FROM hr_data
GROUP BY Gender;

 -- How many employees work remotely for each department?
 
SELECT 
    department,
    COUNT(department) AS remote_employee_count
FROM 
    hr_data
WHERE 
    location = 'Remote'
GROUP BY 
    department
ORDER BY 
    remote_employee_count DESC;
    
-- What is the distribution of employees who work remotely and HQ

SELECT 
    location,
    COUNT(location) AS employee_count
FROM 
    hr_data
GROUP BY 
    location
ORDER BY 
    employee_count DESC
;

-- What is the race distribution in the Company? 5. What is the distribution of employee across different states?

SELECT 
    race,
    COUNT(race) AS employee_count
FROM 
    hr_data
GROUP BY 
    race
ORDER BY 
    employee_count DESC
;

SELECT 
    location_state,
    COUNT(location_state) AS employee_count
FROM 
    hr_data
GROUP BY 
    location_state
ORDER BY 
    employee_count DESC
;

-- What is the number of employees whose employment has been terminated

SELECT 
    COUNT(termdate) AS terminated_employee_count
FROM 
    hr_data
WHERE 
    termdate IS NOT NULL
;

-- Who is/are the longest serving employee in the organization.

SELECT 
    ï»¿id,
    first_name,
    last_name,
    hire_date
FROM 
    hr_data
WHERE 
    hire_date = (
        SELECT MIN(hire_date) FROM hr_data
    );

-- Return the terminated employees by their race

SELECT 
    race,
    COUNT(race) AS terminated_count
FROM 
    hr_data
WHERE 
    termdate IS NOT NULL AND termdate != ''
GROUP BY 
    race
ORDER BY 
    terminated_count DESC
;

-- What is the age distribution in the Company?

SELECT
  CASE
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 20 AND 29 THEN '20-29'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 30 AND 39 THEN '30-39'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 40 AND 49 THEN '40-49'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) BETWEEN 50 AND 59 THEN '50-59'
    WHEN TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) >= 60 THEN '60+'
    ELSE 'Under 20'
  END AS age_group,
  COUNT(*) AS employee_count
FROM
  hr_data
GROUP BY
  age_group
ORDER BY
  age_group;


-- How have employee hire counts varied over time?

SELECT 
  DATE_FORMAT(hire_date, '%Y-%m') AS hire_month,
  COUNT(*) AS hire_count
FROM 
  hr_data
GROUP BY 
  hire_month
ORDER BY 
  hire_month
;

-- What is the tenure distribution for each department?

SELECT 
  department,
  TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS tenure_years,
  COUNT(department) AS employee_count
FROM 
  hr_data
GROUP BY 
  department,
  tenure_years
ORDER BY 
  department,
  tenure_years;

-- What is the average length of employment in the company?

SELECT 
  AVG(DATEDIFF(
    IFNULL(termdate, CURDATE()), 
    hire_date
  )) / 365 AS avg_employment_years
FROM 
  hr_data
WHERE 
  hire_date IS NOT NULL;

-- Which department has the highest turnover rate?

SELECT 
  department,
  COUNT(department) AS total_employees,
  SUM(CASE 
        WHEN termdate IS NOT NULL AND termdate != '' 
        THEN 1 
        ELSE 0 
      END) AS terminated_employees,
  ROUND(
    SUM(CASE 
          WHEN termdate IS NOT NULL AND termdate != '' 
          THEN 1 
          ELSE 0 
        END) * 100.0 / COUNT(department), 
    2
  ) AS turnover_rate_percent
FROM 
  hr_data
GROUP BY 
  department
ORDER BY 
  turnover_rate_percent DESC;

SELECT *
FROM employee_table;


ALTER TABLE employee_table
DROP COLUMN hiredate;

ALTER TABLE employee_table
DROP COLUMN dob;

SET sql_safe_updates = 0;
UPDATE employee_table
SET hire_date = CASE
    WHEN hire_date LIKE '%/%/%' THEN STR_TO_DATE(hire_date, '%c/%e/%Y')
    WHEN hire_date LIKE '%-%-%' THEN STR_TO_DATE(hire_date, '%d-%m-%y')
    ELSE NULL
END;

ALTER TABLE employee_table ADD birth_date DATE;
UPDATE employee_table
SET birth_date = STR_TO_DATE(date_of_birth, '%c/%e/%Y')
;

-- Find departments where over 50% of employees were hired in the past five years.
SELECT 
    department,
    COUNT(*) AS total_employees,
    SUM(hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)) AS recent_hires,
    ROUND((SUM(hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)) * 100.0 / COUNT(*)), 2) AS percentage
FROM employee_table
GROUP BY department
HAVING percentage > 50
ORDER BY percentage DESC;
