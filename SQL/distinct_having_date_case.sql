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
