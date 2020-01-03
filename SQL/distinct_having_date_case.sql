--------------------
---- DISTINCT ------
--------------------

/*
1. Use DISTINCT to test if there are any accounts
associated with more than one region.
*/

SELECT DISTINCT a.name AS account,
                r.name AS region
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
ORDER BY account;

2. Have any sales reps worked on more than one account?

SELECT DISTINCT s.name AS sales_reps,
                a.name AS account
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
ORDER BY sales_reps;

--------------------
---- HAVING --------
--------------------

--1. How many of the sales reps have more than 5 accounts that they manage?

SELECT COUNT(*) AS how_man_sales_rep_have_more_than_5_accounts
FROM (
  SELECT s.name AS sales_rep,
         COUNT(*) AS account_num
  FROM accounts a
  JOIN sales_reps s
  ON a.sales_rep_id = s.id
  GROUP BY sales_rep
  HAVING COUNT(*) > 5
  ORDER BY account_num) AS Table1;

--2. How many accounts have more than 20 orders?

SELECT COUNT(*) AS how_man_accounts_have_more_than_20_orders
FROM (
  SELECT a.name AS account,
         COUNT(*) AS order_num
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY account
  HAVING COUNT(*) > 20
  ORDER BY order_num) AS Table1;

--3. Which account has the most orders?

SELECT Table1.account AS which_account_has_the_most_order,
       Table1.order_num
FROM (
  SELECT a.name AS account,
         COUNT(*) AS order_num
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY account
  HAVING COUNT(*) > 20
  ORDER BY order_num DESC) AS Table1
LIMIT 1;

--4. Which accounts spent more than 30,000 usd total across all orders?

SELECT a.name AS account,
       SUM(o.total_amt_usd) AS usd_total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY account
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY usd_total DESC;

--5. Which accounts spent less than 1,000 usd total across all orders?

SELECT a.name AS account,
       SUM(o.total_amt_usd) AS usd_total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY account
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY usd_total DESC;

--6. Which account has spent the most with us?

SELECT Table1.account, Table1.usd_total
FROM (
  SELECT a.name AS account,
         SUM(o.total_amt_usd) AS usd_total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY account
  ORDER BY usd_total DESC) AS Table1
LIMIT 1;

--7. Which account has spent the least with us?

SELECT Table1.account, Table1.usd_total
FROM (
  SELECT a.name AS account,
         SUM(o.total_amt_usd) AS usd_total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY account
  ORDER BY usd_total) AS Table1
LIMIT 1;

/*
8. Which accounts used facebook
as a jchannel to contact customers more than 6 times?
*/

SELECT a.name AS account,
       COUNT(*) AS contact_customer
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY account
HAVING COUNT(*) > 6
ORDER BY contact_customer;

--9. Which account used facebook most as a channel?

SELECT Table1.account, Table1.contact_customer
FROM (
  SELECT a.name AS account,
         COUNT(*) AS contact_customer
  FROM accounts a
  JOIN web_events w
  ON a.id = w.account_id
  WHERE w.channel = 'facebook'
  GROUP BY account
  HAVING COUNT(*) > 6
  ORDER BY contact_customer DESC) AS Table1
LIMIT 1;

--10. Which channel was most frequently used by most accounts?

SELECT a.id, a.name, w.channel, COUNT(*) AS num_of_channel_used
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY num_of_channel_used DESC
LIMIT 10;

--------------------
---- DATE ----------
--------------------

/*
1. Find the sales in terms of total dollars for all orders in each year,
ordered from greatest to least.
Do you notice any trends in the yearly sales totals?
*/

SELECT DATE_PART('year', o.occurred_at) AS year,
       SUM(o.total_amt_usd) AS total_dollars
FROM orders o
GROUP BY year
ORDER BY total_dollars DESC;

/*
2. Which month did Parch & Posey have the greatest sales
in terms of total dollars? Are all months evenly represented by the dataset?
*/

SELECT DATE_PART('month', o.occurred_at) AS month,
       SUM(o.total_amt_usd) AS total_dollars
FROM orders o
WHERE o.occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY month
ORDER BY total_dollars DESC;

/*
3. Which year did Parch & Posey have the greatest sales
in terms of total number of orders?
Are all years evenly represented by the dataset?
*/

SELECT DATE_PART('year', o.occurred_at) AS year,
       COUNT(*) AS total_order
FROM orders o
GROUP BY 1
ORDER BY 2 DESC;

/*
4. Which month did Parch & Posey have the greatest sales
in terms of total number of orders?
Are all months evenly represented by the dataset?
*/

SELECT DATE_PART('month', o.occurred_at) AS month,
       COUNT(*) AS total_order
FROM orders o
WHERE o.occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY month
ORDER BY total_order DESC;

5. In which month of which year did Walmart spend the most
on gloss paper in terms of dollars?

SELECT a.name,
       DATE_PART('month', o.occurred_at) AS month,
       SUM(o.gloss_amt_usd) AS total_spend_on_gloss_paper
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY month, a.name
ORDER BY total_spend_on_gloss_paper DESC;

--------------------
---- CASE ----------
--------------------

/*
1. Write a query to display for each order, the account ID,
total amount of the order, and the level of the order - ‘Large’ or ’Small’
- depending on if the order is $3000 or more, or smaller than $3000.
*/

SELECT account_id, total,
       CASE WHEN total >= 3000 THEN 'Large'
       WHEN total < 3000 THEN 'Small' END
       AS level_of_order
FROM orders;

/*
2. Write a query to display the number of orders in each of three categories,
based on the total number of items in each order.
The three categories are:
'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/

SELECT account_id, total,
       CASE WHEN total >= 2000 THEN 'At Least 2000'
       WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
       WHEN total < 1000 THEN 'Less than 1000' END
       AS level_of_order
FROM orders;

/*
3. We would like to understand 3 different levels of customers
based on the amount associated with their purchases.
The top level includes anyone with a Lifetime Value
(total sales of all orders) greater than 200,000 usd.
The second level is between 200,000 and 100,000 usd.
The lowest level is anyone under 100,000 usd.
Provide a table that includes the level associated with each account.
You should provide the account name,
the total sales of all orders for the customer, and the level.
Order with the top spending customers listed first.
*/

SELECT a.name AS customer,
       SUM(o.total_amt_usd) AS total_usd,
       CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top level'
       WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'second level'
       WHEN SUM(o.total_amt_usd) < 100000 THEN 'lowest level' END
       AS level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY customer
ORDER BY SUM(o.total_amt_usd) DESC;

/*
4. We would now like to perform a similar calculation to the first,
but we want to obtain the total amount spent by customers only in 2016 and 2017.
Keep the same levels as in the previous question.
Order with the top spending customers listed first.
*/

SELECT a.name AS customer,
       SUM(o.total_amt_usd) AS total_usd,
       CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top level'
       WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'second level'
       WHEN SUM(o.total_amt_usd) < 100000 THEN 'lowest level' END
       AS level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at BETWEEN '2016-01-01' AND '2017-12-31'
GROUP BY 1
ORDER BY 2 DESC;

/*
5. We would like to identify top performing sales reps,
which are sales reps associated with more than 200 orders.
Create a table with the sales rep name, the total number of orders,
and a column with top or not depending on if they have more than 200 orders.
Place the top sales people first in your final table.
*/

SELECT s.name AS sales_rep,
       COUNT(*) AS order_num,
       CASE WHEN COUNT(*) > 200 THEN 'top'
       WHEN COUNT(*) <= 200 THEN 'not' END
       AS level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY 1
ORDER BY 2 DESC;

/*
6. The previous didn't account for the middle,
nor the dollar amount associated with the sales.
Management decides they want to see these characteristics represented as well.
We would like to identify top performing sales reps,
which are sales reps associated with more than 200 orders or
more than 750000 in total sales.
The middle group has any rep with more than 150 orders or 500000 in sales.
Create a table with the sales rep name, the total number of orders,
total sales across all orders, and a column with top, middle,
or low depending on this criteria.
Place the top sales people based on dollar amount of sales first
in your final table. You might see a few upset sales people by this criteria!
*/

SELECT s.name AS sales_rep,
       COUNT(*) AS order_num,
       SUM(o.total_amt_usd) AS total_usd,
       CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
       WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
       ELSE 'low' END
       AS level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY 1
ORDER BY 3 DESC;
