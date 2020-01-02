/*
1. Which account (by name) placed the earliest order?
Your solution should have the account name and the date of the order.
*/

SELECT a.name, MIN(o.occurred_at) AS earliest_time
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY earliest_time
LIMIT 1;

-- Without grouping

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

/*
2. Find the total sales in usd for each account.
You should include two columns -
the total sales for each company's orders in usd and the company name.
*/

SELECT SUM(o.total) AS total, a.name
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name;

/*
3. Via what channel did the most recent (latest) web_event occur,
which account was associated with this web_event?
Your query should return only three values -
the date, channel, and account name.
*/

SELECT w.occurred_at AS date, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at
LIMIT 1;

/*
4. Find the total number of times each type of channel from
the web_events was used. Your final table should have two columns -
the channel and the number of times the channel was used.
*/

SELECT w.channel, COUNT(w.occurred_at) AS number_of_times
FROM web_events w
GROUP BY w.channel;

/*
5. Who was the primary contact associated with the earliest web_event?
*/

SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at
LIMIT 1;

/*
6. What was the smallest order placed by each account in terms of total usd.
Provide only two columns -
the account name and the total usd.
Order from smallest dollar amounts to largest.
*/

SELECT MIN(o.total) AS smallest_order, a.name
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY smallest_order;

/*
7. Find the number of sales reps in each region.
Your final table should have two columns -
the region and the number of sales_reps.
Order from fewest reps to most reps.
*/

SELECT COUNT(*) AS sales_rep, r.name
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
ORDER BY sales_rep;
