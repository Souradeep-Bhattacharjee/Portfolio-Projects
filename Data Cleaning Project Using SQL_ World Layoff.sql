-- Data Cleaning Project Using SQL: World Layoff--

-- Create a Schema called "world_layoff"
-- Add data using table data import wizard

-- Objectives --
-- 1. Create a staging table so that we do not lose our raw data
-- 2. Check for duplicates and remove
-- 3. Fix the data (Spelling, Trimming, Data-Type...)
-- 4. Check for NULL & Blank and fix them
-- 5. Additional cleanup and removal of extra data/column

-- Let's Start

-- First, let's check and observe the table to figure out the issues

select *
from layoffs
;

-- 1. Let's create a staging table so that we do not lose our raw data

create table layoffs_stage 
like layoffs # It adds the column headers like we have in the layoffs table
;

-- Let's add the same data in table layoffs_stage

insert into layoffs_stage
select *
from layoffs # It inserts the data which we get from querying layoffs table
;

-- Now let's check our newly created table layoffs_stage

select *
from layoffs_stage
;
-- End of Objective 1 --

-- 2. Let's now Check for duplicates annd remove them

-- To check for duplicates lets assign a row number to the data
-- Best practice is to check all rows

select *,
row_number() over 
(partition by company, location, industry,total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stage
;

-- Now using the above code we need to check where row_num > 1
-- Let's use CTE for this (we can also use sub-query)

with CTE_duplicate as
(
select *,
row_number() over 
(partition by company, location, industry,total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stage
)
select *
from CTE_duplicate
where row_num > 1
;

-- Now let's add the value for row_num
-- For this lets create another table with the row_num column

create table layoffs_stage2
like layoffs # Creating the new table
;

alter table layoffs_stage2
add row_num int # adding the new column row_num
; 

select *
from layoffs_stage2 # Checking the new table
;

insert into layoffs_stage2
select *,
row_number() over (
partition by company, location, industry,total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions
) as row_num
from layoffs_stage 
;

-- Now we can delete the data where row_num > 1 which means duplicate

delete
from layoffs_stage2
where row_num > 1
;
-- End of Objective 2 --

-- 3. Let's now Fix the data (Spelling, Trimming, Data-Type...)

select distinct company
from layoffs_stage2
order by 1
;

-- Let's Trim anything extra from the company column

update layoffs_stage2
set company = trim(company)
;

-- Let's check the industry now

select distinct industry
from layoffs_stage2
order by 1
;

-- Now after checking the data we can see that there are 3 different types of crypto industry
-- But as they are the same industry, let's change them to 'crypto'

select distinct industry
from layoffs_stage2
where industry like 'Crypto%'
;

update layoffs_stage2
set industry = 'Crypto'
where industry like 'Crypto%'
;

-- Now let's check for the country column

select distinct country
from layoffs_stage2
order by 1
;

-- Now after checking the data we can see that there are two united states (one with '.dot' in the end)
-- Now we can fix this in multiple ways 

-- Solution 1 (Just like we did for the industry)

select distinct country
from layoffs_stage2
where country like 'United States%'
;

update layoffs_stage2
set country = 'United States'
where country like 'United States%'
;

-- Solution 2 (Using the Trim & Trailing)

select distinct country, trim(trailing '.' from country)
from layoffs_stage2
where country like 'United States%'
;

update layoffs_stage2
set country = trim(trailing '.' from country)
where country like 'United States%'
;

-- Now we need to fix is the data type for `date` column (as its in text format)

select `date`
from layoffs_stage2
;

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_stage2
;

update layoffs_stage2
set `date` = str_to_date(`date`, '%m/%d/%Y')
;

-- Now that we have fixed the format let's update the data type for the `date` column

alter table layoffs_stage2
modify column `date` date
;
-- End of Objective 3 --

-- 4. Check for NULL & Blank and fix them

select *
from layoffs_stage2
;

-- After checking the table we can see that there are some NULL & Blank in the industry column
-- It's always better to update all the Blanks to NULL

select *
from layoffs_stage2
where industry = ''
;

update layoffs_stage2
set industry = NULL 
where industry = ''
;

-- Now let's check the NULL values and populate values if possible

select *
from layoffs_stage2
where industry is NULL
;

-- Now let's see if we can populate any data for these NULL values

select *
from layoffs_stage2
where company like 'Airbnb%'
;

-- As we can see for another row of Airbnb there is an industry available
-- Now let's check for all of them where we got NULL

select l1.industry, l2.industry
from layoffs_stage2 as l1
join layoffs_stage2 as l2
	on l1.company = l2.company
where l1.industry is null
and l2.industry is not null
;

-- Now let's update the null values with the other values

update layoffs_stage2 as l1
join layoffs_stage2 as l2
	on l1.company = l2.company
Set l1.industry = l2.industry
where l1.industry is null
and l2.industry is not null
;

-- Now for the analysis we do not need the rows where total_laid_off & percentage_laid_off is NULL

select *
from layoffs_stage2
where total_laid_off is NULL
and percentage_laid_off is NULL
;

delete
from layoffs_stage2
where total_laid_off is NULL
and percentage_laid_off is NULL
;
-- End of Objective 4 --

-- 5. Additional cleanup and removal of extra data/column

-- Let's now delete the extra column that we created row_num

alter table layoffs_stage2
drop column row_num
;
-- End of Objective 4 --

-- Let's now see the final cleaned table --

select *
from layoffs_stage2
;

-- End of Project --
