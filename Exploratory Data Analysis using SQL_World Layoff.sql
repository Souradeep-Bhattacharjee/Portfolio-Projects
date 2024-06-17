-- Exploratory Data Analysis using SQL: World Layoff --

-- Analysis to Perform:
-- Find out the max and min of total layoff done by a company in a single year
-- Find the company who did the higest number of layoff including all the years
-- Find the industry who did the higest number of layoff including all the years
-- Find the country who did the higest number of layoff including all the years
-- Find the total layoff per year
-- Find yearly rolling total layoff
-- Find out yerly wise which 5 company did the most layoff and rank them accrodingly
-- Find out yerly wise which 5 country did the most layoff and rank them accrodingly

-- Let's Start --

-- First lest check the cleared data

select * 
from layoffs_stage2
;

-- Let's find out the max and min of total layoff done by a company in a single year

select max(total_laid_off), min(total_laid_off)
from layoffs_stage2
;

-- Let's find the company who did the higest number of layoff including all the years

select company, sum(total_laid_off) as sum_total
from layoffs_stage2
group by company
order by sum_total desc
;

-- Let's find the industry who did the higest number of layoff including all the years

select industry, sum(total_laid_off) as sum_total
from layoffs_stage2
group by industry
order by sum_total desc
;

-- Let's find the Country who did the higest number of layoff including all the years

select country, sum(total_laid_off) as sum_total
from layoffs_stage2
group by country
order by sum_total desc
;

-- Let's find the total layoff per year

select year(`date`) as `Year`, sum(total_laid_off) as yearly_sum_total
from layoffs_stage2
where year(`date`) is not null
group by `Year`
order by `Year`ASC
;

-- Lets now find yearly rolling total layoff

with CTE_company_off as
(
select year(`date`) as `Year`, sum(total_laid_off) as yearly_sum_total
from layoffs_stage2
where year(`date`) is not null
group by `Year`
order by `Year`ASC
)
select `Year`, yearly_sum_total,
sum(yearly_sum_total) over (order by `Year` ASC) as yearly_rolling_layoff
from CTE_company_off
;

-- Lets now find mothly rolling total layoff

with CTE_company_off as
(
select substring(`date`,1,7) as `month` , sum(total_laid_off) as monthly_sum_total
from layoffs_stage2
where substring(`date`,1,7) is not null
group by `month`
order by `month`ASC
)
select `month`, monthly_sum_total,
sum(monthly_sum_total) over (order by `month` ASC) as yearly_rolling_layoff
from CTE_company_off
;

-- find out yerly wise which 5 company did the most layoff

with CTE_company_year as
(
select company, year(`date`) as `Year`, 
sum(total_laid_off) as sum_total
from layoffs_stage2
group by company, `Year`
), CTE_rank_filter as
(
select *, dense_rank() over (partition by `Year`order by sum_total desc) as ranks
from CTE_company_year
where `Year` is not null
)
select company, `Year`, sum_total , ranks
from CTE_rank_filter
where ranks <= 5
order by `Year` ASC
;

-- find out yerly wise which 5 country did the most layoff

with CTE_country_year as
(
select country, year(`date`) as `Year`, 
sum(total_laid_off) as sum_total
from layoffs_stage2
group by country, `Year`
), CTE_rank_filter as
(
select *, dense_rank() over (partition by `Year`order by sum_total desc) as ranks
from CTE_country_year
where `Year` is not null
)
select country, `Year`, sum_total , ranks
from CTE_rank_filter
where ranks <= 5
order by `Year` ASC
;

-- End of Project --