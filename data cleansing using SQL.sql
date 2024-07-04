/*Making a new table*/
create table practice_cleansing.empfirst as
(select * from practice_cleansing.salaries as salaries
left join practice_cleansing.companies as companies
on salaries.comp_name = companies.ï»¿company_name
left join practice_cleansing.functions as functions
on salaries.func_code = functions.ï»¿function_code
left join practice_cleansing.employees2 as employees
on salaries.employee_id = employees.employee_code_emp)

/*Change data types of date*/
update empfirst
set date= str_to_date(date,"%d/%c/%Y %H:%i")

/*Create a new table by select only relevant columns*/
create table cleaned2 as
(select
concat(ef.employee_id,cast(ef.date as date)) as id,
cast(ef.date as date) as month_year,
ef.employee_id,
ef.employee_name,
ef.gender,
ef.age,
ef.salary,
ef.function_group,
ef.comp_name,
ef.company_city,
ef.company_state,
ef.company_type,
ef.const_site_category
from practice_cleansing.empfirst as ef)

/*checking number of rows in cleaned2*/
SELECT * FROM cleaned2
select count(1) from cleaned2
/*output : 7784*/

/* Try to change comp_name to company_name by right-click on cleaned2*/
/* remove all unwanted spaces from all text columns by using trim*/
UPDATE cleaned2
SET id = TRIM(id),
	employee_id	= TRIM(employee_id),
	employee_name = TRIM(employee_name),
	gender = TRIM(gender),
	function_group = TRIM(function_group),
	company_name = TRIM(company_name),
	company_city = TRIM(company_city),
	company_state = TRIM(company_state),
	company_type = TRIM(company_type),
	const_site_category = TRIM(const_site_category)
    
/*Checking 'NULL' values*/
SELECT *
	FROM cleaned2
	WHERE id IS NULL
    OR month_year IS NULL
    OR employee_id IS NULL
	OR employee_name IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR salary IS NULL
	OR function_group IS NULL
	OR company_name IS NULL
	OR company_city IS NULL
	OR company_state IS NULL
	OR company_type IS NULL
	OR const_site_category IS NULL

/*Checking how many missing values in each column*/
SELECT count(id)
FROM cleaned2
WHERE id = ' ' or id=''

SELECT count(employee_id)
FROM cleaned2
WHERE employee_id = ' ' or employee_id=''

SELECT count(employee_name)
FROM cleaned2
WHERE employee_name = ' ' or employee_name =''

SELECT count(gender)
FROM cleaned2
WHERE gender = ' ' or gender =''

SELECT count(age)
FROM cleaned2
WHERE age = ' ' or age =''

SELECT count(salary)
FROM cleaned2
WHERE salary = ' ' or salary =''

SELECT count(function_group)
FROM cleaned2
WHERE function_group = ' ' or function_group =''

SELECT count(company_name)
FROM cleaned2
WHERE company_name = ' ' or company_name =''

SELECT count(company_city)
FROM cleaned2
WHERE company_city = ' ' or company_city =''

SELECT count(company_state)
FROM cleaned2
WHERE company_state = ' ' or company_state =''

SELECT count(company_type)
FROM cleaned2
WHERE company_type = ' ' or company_type =''

SELECT count(const_site_category)
FROM cleaned2
WHERE const_site_category = ' ' or const_site_category =''

/*Checking distinct every column incase there is irrelevant values*/
Select distinct(gender) from cleaned2
Select distinct(salary) from cleaned2 order by 1
Select distinct(function_group) from cleaned2
Select distinct(company_name) from cleaned2
Select distinct(company_city) from cleaned2
Select distinct(company_state) from cleaned2
Select distinct(company_type) from cleaned2
Select distinct(const_site_category) from cleaned2

/*We got :
1. Missing values salary ('' or ' '): 67
2. Missing values const_site_category ('' or ' ') : 754
3. Inconsistent entry const_site_employee Commercial and Commerciall
4. Change data type of salary
5. Inconsistent entry company_city : Goiania and Goianiaa
6. Standardization company_state : GOIAS
7. Inconsistent entry company_type : Construction Site and Construction Sites 

What we need todo :
1. Replace ',' to '.' then change salary from text to double
2. Change input in gender from F to Female and M to Male
3. Change input in company_city from Gioaniaa to Gioania
4. Change input const_site_employee from Commerciall to Commercial
5. Change input company_type from Construction Sites to Construction Site
6. Change company_state from GOIAS to Goias
7. Delete the 1 mi salara=y because it was used only as a test by H.R.Department
8. Delete missing values
9. Feature extraction : Make new column pay_month contain year and month
*/

/*1.*/
update cleaned2
set salary = cast(replace(salary,',','.') as double)
select distinct salary from cleaned2 order by 1
select count(salary) from cleaned2 where salary=0 /*count = 67 equal to number of missing values*/
/*After change data type of salary missing values change from ' ' to 0*/
/*2.*/
Update cleaned2
set gender = case 
			 when gender='F' then 'Female'
             when gender='M' then 'Male'
             else gender
             end
/*3.*/
Update cleaned2
set 
	company_city = case 
				   when company_city='Gioaniaa' then 'Gioania'
                   else company_city
                   end
/*4.*/
Update cleaned2
set
	const_site_category = case
						  when const_site_category = 'Commerciall' then 'Commercial'
                          else const_site_category
                          end
/*5.*/
Update cleaned2
set
	company_type = case 
				   when company_type='Construction Sites' then 'Construction Site'
                   else company_type
                   end
/*6.*/
Update cleaned2
set
	company_state = case 
					when company_state='GOIAS' then 'Goias'
                    else company_state
                    end
/*7.*/
DELETE FROM cleaned2
WHERE salary=1000000
/*8*/
Delete from cleaned2
where salary=0
select distinct salary from cleaned2 order by 1
--
Delete from cleaned2
where const_site_category='' or ' '
select distinct const_site_category from cleaned2 order by 1

/*Check how many rows we have*/
select count(1) from cleaned2
/*output : 6980 from 7784*/

/*9*/
ALTER TABLE `practice_cleansing`.`cleaned2` 
ADD COLUMN `pay_month` VARCHAR(45) NULL DEFAULT NULL AFTER `const_site_category`
update cleaned2
set pay_month=left(month_year,7)

/*Check and delete duplicate value*/
select id from
(select id,employee_name, count(id)
from cleaned2
group by 1,2
having count(id)>1
order by 1) as satu

DELETE FROM cleaned2 WHERE id in 
(select id from
(select id,employee_name, count(id)
from cleaned2
group by 1,2
having count(id)>1
order by 1) as satu)

/*Check how many rows we have*/
select count(1) from cleaned2
/*output : 6634 from 6980*/
