SELECT channel,
       DATE_TRUNC('day', occurred_at) AS day,
	     COUNT(*) as event_num
FROM web_events
GROUP BY channel, day
ORDER BY 3 DESC;

--

SELECT Table1.channel,
       SUM(Table1.event_num) / COUNT(Table1.event_num) AS avg_day_event
FROM (
      SELECT channel,
             DATE_TRUNC('day', occurred_at) AS day,
      	     COUNT(*) as event_num
      FROM web_events
      GROUP BY channel, day
      ORDER BY 3 DESC) AS Table1
GROUP BY Table1.channel

--

SELECT DATE_TRUNC('month', occurred_at) AS month
FROM orders
GROUP BY 1
ORDER BY 1
LIMIT 1;

--

SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders;

--

SELECT AVG(standard_qty) AS avg_std_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(occurred_at))
      FROM orders);

--

SELECT SUM(total_amt_usd) AS total_usd
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(occurred_at))
      FROM orders);

--

/*
1. Provide the name of the sales_rep in each region
with the largest amount of total_amt_usd sales.
*/

SELECT t3.sales_name,
       t3.region,
       t3.usd
FROM (SELECT t1.region,
             MAX(t1.usd) usd
      FROM (SELECT r.name region,
                   s.name sales_name,
                   SUM(o.total_amt_usd) usd
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            JOIN sales_reps s
            ON a.sales_rep_id = s.id
            JOIN region r
            ON s.region_id = r.id
            GROUP BY 1, 2) AS t1
      GROUP BY 1) AS t2
JOIN (SELECT r.name region,
            s.name sales_name,
            SUM(o.total_amt_usd) usd
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      JOIN sales_reps s
      ON a.sales_rep_id = s.id
      JOIN region r
      ON s.region_id = r.id
      GROUP BY 1, 2) AS t3
ON t2.usd = t3.usd AND t2.region = t3.region;

-- WITH --

WITH t1 AS (SELECT r.name region,
                   s.name sales_name,
                   SUM(o.total_amt_usd) usd
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            JOIN sales_reps s
            ON a.sales_rep_id = s.id
            JOIN region r
            ON s.region_id = r.id
            GROUP BY 1, 2),
    t2 AS (SELECT t1.region,
             MAX(t1.usd) usd
           FROM t1
           GROUP BY 1),
    t3 AS (SELECT r.name region,
                  s.name sales_name,
                  SUM(o.total_amt_usd) usd
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            JOIN sales_reps s
            ON a.sales_rep_id = s.id
            JOIN region r
            ON s.region_id = r.id
            GROUP BY 1, 2)

SELECT t3.sales_name,
       t3.region,
       t3.usd
FROM  t2
JOIN  t3
ON t2.usd = t3.usd AND t2.region = t3.region;

/*
2. For the region with the largest (sum) of sales total_amt_usd,
how many total (count) orders were placed?
*/

SELECT r.name region_name,
      COUNT(*) total_order
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
WHERE r.name = (SELECT r.name region
                FROM orders o
                JOIN accounts a
                ON o.account_id = a.id
                JOIN sales_reps s
                ON a.sales_rep_id = s.id
                JOIN region r
                ON s.region_id = r.id
                GROUP BY 1
                ORDER BY SUM(o.total_amt_usd) DESC
                LIMIT 1)
GROUP BY region_name;

-- WITH --

WITH answer AS (SELECT r.name region,
                       COUNT(*) total_order
                FROM orders o
                JOIN accounts a
                ON o.account_id = a.id
                JOIN sales_reps s
                ON a.sales_rep_id = s.id
                JOIN region r
                ON s.region_id = r.id
                GROUP BY 1
                ORDER BY SUM(o.total_amt_usd) DESC
                LIMIT 1)

SELECT answer.region region_name,
       answer.total_order total_order
FROM answer

/*
3. How many accounts had more total purchases than the account name
which has bought the most standard_qty paper
throughout their lifetime as a customer?
*/

SELECT COUNT(*)
FROM (SELECT a.name account,
             COUNT(o.total) total_purchase
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      GROUP BY a.name
      HAVING SUM(o.total) > (SELECT SUM(o.total) total_purchase
                               FROM orders o
                               JOIN accounts a
                               ON o.account_id = a.id
                               WHERE a.name = (SELECT a.name account
                                               FROM orders o
                                               JOIN accounts a
                                               ON o.account_id = a.id
                                               GROUP BY 1
                                               ORDER BY SUM(o.standard_qty) DESC
                                               LIMIT 1)
                              GROUP BY a.name)) AS t1

-- WITH --

WITH most_std_qty AS (SELECT a.name account,
                             SUM(o.total) total_purchase
                      FROM orders o
                      JOIN accounts a
                      ON o.account_id = a.id
                      GROUP BY 1
                      ORDER BY SUM(o.standard_qty) DESC
                      LIMIT 1),
    total_company AS (SELECT a.name account,
                             COUNT(o.total) total_purchase
                      FROM orders o
                      JOIN accounts a
                      ON o.account_id = a.id
                      GROUP BY a.name
                      HAVING SUM(o.total) > (SELECT total_purchase
                                             FROM most_std_qty))

SELECT COUNT(*)
FROM total_company

/*
4.For the customer that spent the most
(in total over their lifetime as a customer)
total_amt_usd, how many web_events did they have for each channel?
*/

SELECT a.name,
       w.channel,
       COUNT(*) web_event_num
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = (SELECT a.name customer
                FROM orders o
                JOIN accounts a
                ON o.account_id = a.id
                GROUP BY 1
                ORDER BY SUM(o.total_amt_usd) DESC
                LIMIT 1)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- WITH --

WITH best_customer AS (SELECT a.name customer
                       FROM orders o
                       JOIN accounts a
                       ON o.account_id = a.id
                       GROUP BY 1
                       ORDER BY SUM(o.total_amt_usd) DESC
                       LIMIT 1)

SELECT a.name,
       w.channel,
       COUNT(*) web_event_num
FROM web_events w
JOIN accounts a
ON w.account_id = a.id AND a.name = (SELECT customer FROM best_customer)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
5. What is the lifetime average amount spent
in terms of total_amt_usd for the top 10 total spending accounts?
*/

SELECT AVG(t1.total_spent) avg_total_spent
FROM (SELECT a.name customer,
             SUM(o.total_amt_usd) AS total_spent
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10) AS t1

-- WITH --

WITH total_spent AS (SELECT a.name customer,
                            SUM(o.total_amt_usd) AS total_spent
                     FROM orders o
                     JOIN accounts a
                     ON o.account_id = a.id
                     GROUP BY 1
                     ORDER BY 2 DESC
                     LIMIT 10)

SELECT AVG(total_spent.total_spent) avg_total_spent
FROM total_spent

/*
6. What is the lifetime average amount spent
in terms of total_amt_usd, including only the companies
that spent more per order, on average, than the average of all orders.
*/

SELECT AVG(t1.avg_per_order) avg_per_order_per_company
FROM (SELECT a.name customer,
             AVG(o.total_amt_usd) AS avg_per_order
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      GROUP BY 1
      HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd)
                                     FROM orders o)
      ) AS t1

-- WITH --

WITH avg_spent_per_order AS (SELECT AVG(o.total_amt_usd)
                             FROM orders o),
     avg_company_spent AS (SELECT a.name customer,
                                  AVG(o.total_amt_usd) AS avg_per_order
                           FROM orders o
                           JOIN accounts a
                           ON o.account_id = a.id
                           GROUP BY 1
                           HAVING AVG(o.total_amt_usd)
                                  > (SELECT * FROM avg_spent_per_order))

SELECT AVG(a.avg_per_order) avg_per_order_per_company
FROM avg_company_spent a
