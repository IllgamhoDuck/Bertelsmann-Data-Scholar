/*
1. When was the earliest order ever placed? You only need to return the date.
*/

SELECT MIN(o.occurred_at)
FROM orders o;

/*
2. Try performing the same query as in question 1
without using an aggregation function.
*/

SELECT o.occurred_at
FROM orders o
ORDER BY o.occurred_at
LIMIT 1;

/*
3. When did the most recent (latest) web_event occur?
*/

SELECT MAX(o.occurred_at)
FROM orders o;

/*
4. Try to perform the result of the previous query
without using an aggregation function.
*/

SELECT o.occurred_at
FROM orders o
ORDER BY o.occurred_at DESC
LIMIT 1;

/*
5. Find the mean (AVERAGE) amount spent per order on each paper type,
as well as the mean amount of each paper type purchased per order.
Your final answer should have 6 values -
one for each paper type for the average number of sales,
as well as the average amount.
*/

SELECT AVG(o.standard_qty) AS avg_std_qty,
	     AVG(o.gloss_qty) AS avg_gloss_qty,
       AVG(o.poster_qty) AS avg_poster_qty,
       AVG(o.standard_amt_usd) AS std_usd,
       AVG(o.gloss_amt_usd) AS gloss_usd,
       AVG(o.poster_amt_usd) AS poster_usd
FROM orders o;

/*
6. Via the video, you might be interested in how to calculate the MEDIAN.
Though this is more advanced than what we have covered so far try finding -
what is the MEDIAN total_usd spent on all orders?
*/

SELECT SUM(o.total_amt_usd) / 2
FROM orders o
WHERE id BETWEEN 3456 AND 3457 ;
