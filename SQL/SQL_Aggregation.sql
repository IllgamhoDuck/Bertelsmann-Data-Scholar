/*
1. Find the total amount of poster_qty paper ordered in the orders table.
*/

SELECT COUNT(o.poster_qty)
FROM orders o;

/*
2. Find the total amount of standard_qty paper ordered in the orders table.
*/

SELECT COUNT(o.standard_qty)
FROM orders o;

/*
3. Find the total dollar amount of sales using
the total_amt_usd in the orders table.
*/

SELECT SUM(o.total_amt_usd)
FROM orders o;

/*
4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper
for each order in the orders table.
This should give a dollar amount for each order in the table.
*/

SELECT o.standard_amt_usd + o.gloss_amt_usd AS total_usd_amount
FROM orders o;


/*
5. Find the standard_amt_usd per unit of standard_qty paper.
Your solution should use both an aggregation and a mathematical operator.
*/

SELECT SUM(o.standard_amt_usd) / SUM(o.standard_qty) AS standard_per_unit
FROM orders o;
