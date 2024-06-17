-- Data Cleaning Project Using SQL: World Layoff--

-- Create Schema called "world_layoff"
-- Add data using table data import wizard

-- Objectives --
-- 1. Create a staging table so that we do not loose our raw data
-- 2. Check for duplicates annd remove
-- 3. Fix the data (Spelling, Trimming, Data-Type...)
-- 4. Check for NULL & Blank and fix them
-- 5. Additional cleanup and removal of extra data / column

-- Let' Start

-- First let's check and observe the table to figure out issues

select *
from layoffs
;

-- 1. Let's create a staging table so that we do not loose our raw data

create table layoffs_stage 
like layoffs # It adds the column headers like we have in layoffs table
;

-- Lets add the same data in table layoffs_stage

insert into layoffs_stage
select *
from layoffs # It inserts the data which we get from quering layoffs table
;

-- Now lets check our newly created table layoffs_stage

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

Select *
from layoffs_stage2;
