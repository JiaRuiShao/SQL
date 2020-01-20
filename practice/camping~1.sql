--Q2:
/*2. Write a SQL statement to show the total dollar amount 
sold to customers summarized by state/province of
their customer site address and 
each month of each Year (YYYY-MM). 
(If the state/province is NULL then
use the City in its place)*/

SELECT  NVL(cs.prov_state,cs.city) AS state_city, 
		TO_CHAR(co.order_date, 'YYYY-MM') AS sold_time, 
		SUM(od.quantity*od.extended_price) AS sales
FROM ((orderdetail od INNER JOIN customerorder co
					ON od.order_no = co.order_no) INNER JOIN customersite cs
												  ON co.cust_no = cs.cust_no)
WHERE od.returned != 'Y'
GROUP BY NVL(cs.prov_state,cs.city),  TO_CHAR(co.order_date, 'YYYY-MM');
----------------------------------------------------------------------------------
SELECT  NVL(cs.prov_state,cs.city) AS state_city, 
		TO_CHAR(co.order_date, 'YYYY-MM') AS sold_time, 
		SUM(od.quantity*od.extended_price) AS sales
FROM ((orderdetail od INNER JOIN customerorder co
					ON od.order_no = co.order_no) INNER JOIN customersite cs
												  ON co.cust_no = cs.cust_no
												  AND co.site_no = cs.site_no)
WHERE od.returned != 'Y'
GROUP BY NVL(cs.prov_state,cs.city), TO_CHAR(co.order_date, 'YYYY-MM');

--Q3:
/*3. Write a SQL statement to show the total dollar amount 
sold summarized by product name and each month
of each Year (YYYY-MM) along with RANK 
(order by increasing RANK). Only include sales by reps who
met or exceeded their 2017 sales quota*/

SELECT  p.product_name, 
		TO_CHAR(co.order_date, 'YYYY-MM') AS sold_time, 
		SUM(od.quantity*od.extended_price) AS sales,
        RANK() OVER(ORDER BY SUM(od.quantity*od.extended_price) DESC) 
		AS ranking
FROM (((orderdetail od INNER JOIN product p
						ON od.prod_no = p.prod_no) 
								INNER JOIN customerorder co
								ON co.order_no = od.order_no) 
										INNER JOIN rep r
										ON r.rep_no = co.rep_no)
WHERE od.returned != 'Y' AND r.rep_sales_17 >= r.rep_quota_17
GROUP BY p.product_name, TO_CHAR(co.order_date, 'YYYY-MM');


--Q4:
/*4. Write a SQL statement to show all Canadian based customer’s name, 
state/province and total dollar amount
sold on “Outdoor Products” or “Environmental Line” product types*/

SELECT  c.customer_name, NVL(cs.prov_state,cs.city) AS state_city, 
		SUM(od.quantity*od.extended_price) AS sales
FROM(((((orderdetail od INNER JOIN product p
						ON od.prod_no = p.prod_no) 
							INNER JOIN customerorder co
							ON co.order_no = od.order_no) 
								INNER JOIN customersite cs
								ON cs.cust_no = co.cust_no
								AND cs.site_no = co.site_no)
									INNER JOIN country cy 
									ON cy.country_cd = cs.country_cd)
										INNER JOIN customer c
										ON c.cust_no = cs.cust_no)
WHERE od.returned != 'Y' AND cy.country_name = 'Canada' 
	  AND (p.prod_type IN ( 'Outdoor Products', 'Environmental Line'))
GROUP BY c.customer_name, NVL(cs.prov_state,cs.city);

--Q5:
/*5. Write a SQL statement to show the product name 
and total profit for the product that has the largest profit
margin (extended price compared to product cost) 
when sold over the internet.*/

SELECT p.product_name, 
	   (SUM(od.quantity*(od.extended_price - p.prod_cost))/SUM(od.quantity*od.extended_price)) AS profit_margin
FROM((orderdetail od INNER JOIN product p
						ON od.prod_no = p.prod_no) 
							INNER JOIN customerorder co
							ON co.order_no = od.order_no)
WHERE od.returned != 'Y' AND co.channel = 'Internet Sales'
GROUP BY p.product_name
ORDER BY SUM(od.quantity*(od.extended_price - p.prod_cost)) DESC
FETCH FIRST 1 ROW ONLY;

--Q7:
/*7. Which month (be sure to say from which year) had 
the largest percentage increase in sales over the prior
month? Justify your rationale and show your SQL query 
(Hint: Look at the LAG function).*/

SELECT 	order_month, order_sales,prior_order_sales,
        ROUND(((order_sales-prior_order_sales)/prior_order_sales),2) AS percentage_increase
FROM (SELECT TO_CHAR(co.order_date, 'YYYY-MM') AS order_month,
            SUM(od.quantity*od.extended_price) AS order_sales,
            LAG (SUM(od.quantity*od.extended_price), 1) OVER 
            (ORDER BY TO_CHAR(co.order_date, 'YYYY-MM') ASC) AS prior_order_sales
       FROM (customerorder co 
       INNER JOIN orderdetail od
       ON co.order_no=od.order_no)
       WHERE od.returned != 'Y'
       GROUP BY TO_CHAR(co.order_date, 'YYYY-MM')
     )
WHERE prior_order_sales > 0
ORDER BY percentage_increase Desc
FETCH FIRST 1 ROW ONLY;

/*8. Create a VIEW in your own schema that 
joins together all of the columns in all of the tables. 
Be aware of Cartesian products 
e.g., between the ship address and customer.*/

CREATE VIEW  view_table
AS
SELECT *
FROM customer c NATURAL JOIN
     customersite cs NATURAL JOIN
     country cy NATURAL JOIN
     branch b NATURAL JOIN 
     customerorder co NATURAL JOIN
     rep r NATURAL JOIN
     orderdetail od NATURAL JOIN
     product p;
