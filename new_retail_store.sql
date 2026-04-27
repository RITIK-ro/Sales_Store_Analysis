DROP TABLE IF EXISTS RETAIL_STORE;
CREATE TABLE RETAIL_STORE (
transaction_id	 VARCHAR(20) ,
customer_id	     VARCHAR(20) ,
customer_name	 VARCHAR(40) ,
customer_age	 INT,
gender	         VARCHAR(20) ,
product_id	     VARCHAR(20) ,
product_name	 VARCHAR(50),
product_category	VARCHAR(50),
quantiy	         INT,
prce	         NUMERIC,
payment_mode	 VARCHAR(35),
purchase_date	 DATE,
time_of_purchase	TIME,
status	         VARCHAR(50));

BULK INSERT RETAIL_STORE
FROM 'C:\Users\Ritik Raushan\OneDrive\Documents\WEMADE.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		CODEPAGE = '65001'
		);

		SELECT * FROM RETAIL_STORE
		-- NOW WE WILL HAVE TO WORK ON DEUPLICATE TABLE
		SELECT * INTO SALES FROM RETAIL_STORE
		SELECT * FROM SALES

		-- TO CHECK DUPLICATE DATA
		SELECT transaction_id, count(*)
		from SALES
		group by transaction_id
		having count (transaction_id)>1


--TXN240646	2
--TXN342128	2
--TXN855235	2
--TXN981773	2

with cte as(
select *,
	ROW_NUMBER () OVER (PARTITION BY TRANSACTION_ID ORDER BY TRANSACTION_ID) AS ROW_NUM
	FROM SALES
	)
	--delete from cte
	--where ROW_NUM = 2
	SELECT * FROM cte
	WHERE ROW_NUM>1

	select * from SALES

	-- correction of header
	EXEC sp_rename'sales.quantiy','Quantity','COLUMN'
	EXEC sp_rename'sales.prce','Price','COLUMN'

	-- TO CHECK DATA TYPE
	SELECT COLUMN_NAME, DATA_TYPE 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME='sales'


	-- to check null value
	--select * from sales
	--where Price is null
	--or Quantity is null
	--or Quantity is null
	--or Quantity is null
	--or Quantity is null



	DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + 
'SELECT ''' + COLUMN_NAME + ''' AS column_name,
COUNT(*) - COUNT([' + COLUMN_NAME + ']) AS null_count
FROM sales
UNION ALL
'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

-- last UNION ALL hataane ke liye
SET @sql = LEFT(@sql, LEN(@sql) - 10);

EXEC(@sql);
-- to delet null value
delete from sales
where customer_id is null
-- jis tarah excel me ham ye dekhte ctrl+shift+l karke ve dekhna h in gender
select distinct gender
from sales

-- if you have 4 option what there is 'm' and male but in this table don't have but i want to
-- change one time and again replace this for my practic
update sales
set gender = 'Male'
where gender = 'm'
select * from sales

-- cleaning payment mode column
select distinct payment_mode
from sales

update sales
set payment_mode='Credit Card'
where payment_mode = 'CC'
-- main insight what your are bussiness insight
-- Q1. what are the top 5 most selling products by quantity
select * from sales
select distinct product_name 
from sales
select distinct product_category
from sales

select product_category,count(*) as most_sell
from sales
group by product_category
order by most_sell desc;


select top 5 product_name , sum(quantity) as total_quantity_sold
from sales
where status = 'delivered'
group by product_name
order by total_quantity_sold desc;

select distinct status
from sales;

-- business problem -- we don't know which product are most in demand
-- 1. Wardrobe 2. Vegtable 3. Sofa 4. Dining table 5. Fruits

select top 10 * from sales
-- Q2. Which product are most frequenty cancelled?
select top 10 product_name, count(*) as cancelled_item
from sales
where status = 'cancelled'
group by product_name
order by cancelled_item

-- business problem: Frequant cancellation affect revenue and customer trust.

-- 3. what time of the day has the highest number of purchase
select * from sales
select 
	case when DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		when DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		when DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		when DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS TIME_OF_DAY,
		COUNT(*) AS TOTAL_ORDERS
		FROM SALES
		GROUP BY 
		case when DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		when DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		when DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		when DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END
		ORDER BY TOTAL_ORDERS DESC;

		-- business problem : Find peak sales time
		-- Business impact : Optimize staffing, promotion, ans server load

		select * from sales
		select Price*Quantity as Total_amount
		from sales
		select top 5 customer_name, SUM(Price*Quantity) as total_spend
		from sales
		group by customer_name
		order by total_spend desc;

	-- but isko ham aise kar sakte h taki rupya vali symbol mil sake

	select top 5 customer_name, 
	FORMAT(SUM(Price*Quantity),'en-IN') as total_spend
	from sales
	group by customer_name
	order by total_spend desc;


	SELECT TOP 5 
    customer_name,
    FORMAT(SUM(Price * Quantity), 'N', 'en-IN') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(Price * Quantity) DESC;


select top 5 customer_name,
'$'+format (sum(Price*Quantity), 'n','en-in') as toal_spend
from sales
group by customer_name
order by sum(Price*Quantity) desc;



-- Q5. Which product categories generate the highest revenue?
select * from sales

select product_category,  sum(Price*Quantity) as Highest_revenue
from sales
group by product_category
order by Highest_revenue desc;


select product_category, '₹'+format(sum(Price*Quantity),'0') as Highest_revenue
from sales
group by product_category
order by Highest_revenue

SELECT 
    product_category,  
    FORMAT(SUM(Price * Quantity),'C0', 'en-IN') AS Highest_revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(Price * Quantity) DESC;

SELECT Product_category ,
format(sum(Price*Quantity),'C0','en-IN') AS Highest_revenue
from sales
group by Product_category
order by sum(Price*Quantity) desc;

-- What is the return/cancellation rate per product  category
select Product_category,
	count(case when status = 'cancelled' then 1 end) *100.0/count(*) as cancelled_percent
	from sales
	group by Product_category
	order by cancelled_percent

	select product_category , 
		Format(count(case when status = 'cancelled' then 1 end) *100.0/count(*),'N2')+' %' as cancelled_percent
		from sales
		group by product_category
		order by cancelled_percent desc;

		--

		select product_category , 
		Format(count(case when status = 'cancelled' then 1 end) *100.0/count(*),'N2')+' %' as cancelled_percent
		from sales
		group by product_category
		order by cancelled_percent desc;



		-- Now for return
		select * from sales

		select product_category,
		format(count(case when status = 'returned' then 1 end) *100.0/count(*), 'n2')+' %' as return_percent
		from sales
		group by product_category
		order by return_percent

		-- Business impact : reduce returns, improve product descriptions/ expections. Helps 
		-- indentify and fix product or logistic issue.

		-- Q7. what is the most preffered payment mode?
		select * from sales

		select payment_mode , count(*) as total_count
		from sales
		group by payment_mode
		order by total_count desc;


		-- Business impact : sabse jayada credit card use ho rhe means customer ko credit card
		-- use karte time kisi type ki problem nhi ho jaise network issue, error, iska process
		-- easy rakhna hoga aur isi method me aur jyada easy banana hoga taki customer ko koi 
		-- probelm nhi ho

		-- Q8. How does age group affect purchasing behaviour?
		select * from sales
		select min(customer_age),max(customer_age)
		from sales
		select 
			case
				when customer_age between 18 and 25 then '18-25' 
				when customer_age between 26 and 35 then '26-35'
				when customer_age between 36 and 50 then '34-50'
				else '50+'
				end as customer_age,
				format(sum(Price*Quantity),'C0','en-IN') as Total_purchase
				from sales
				group by case
				when customer_age between 18 and 25 then '18-25' 
				when customer_age between 26 and 35 then '26-35'
				when customer_age between 36 and 50 then '34-50'
				else '50+'
				end 
				order by Total_purchase desc;

				-- Business impact
				-- 35-50 years old person do shops more than other so we should provide award
				-- and other benefite

				-- Q9. What's the monthly sales trend?
				select * from  sales

				-- Method 1
				SELECT FORMAT(purchase_date,'yyyy-MM') as month_year,
				FORMAT(SUM(Price*Quantity),'C0','en-IN')AS TOTAL_SALES,
				SUM(Quantity) as Total_Quantity
				from sales
				Group by Format(purchase_date,'yyyy-MM')

				-- method 2
				select 
					--year(purchase_date) as years,
					month (purchase_date) as months,
					format(sum(Price*Quantity),'C0','en-IN') as Total_sales,
					sum(Quantity) as total_quantity
					from sales
					Group by year(purchase_date),month(purchase_date)
					order by months
				-- Business impact : Plan iverntory and marketing according to seasonal trends.


		--Q10. Are certain genders buying more specific product categories?
		-- What is aggrigate function
		select * from sales
		select product_category,gender, count(product_category) as total_purchase
		from sales
		group by gender,product_category
		order by total_purchase desc


		select gender, product_category, count(product_category) as total_purchase
		from sales
		group by gender, product_category
		order by gender,product_category desc;