------------------------
----- LEFT & RIGHT -----
------------------------

/*
1. In the accounts table, there is a column holding the website
for each company. The last three digits specify what type of web address
they are using. A list of extensions (and pricing) is provided here.
Pull these extensions and provide how many of each website type exist
in the accounts table.
*/

SELECT RIGHT(website, 3) AS domain,
       COUNT(*) AS num_of_type
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

/*
2. There is much debate about how much the name
(or even the first letter of a company name) matters.
Use the accounts table to pull the first letter of each company name to see
the distribution of company names that begin with each letter (or number).
*/

SELECT LEFT(name, 1) AS company_initial,
       COUNT(*) AS num_of_company
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

/*
3. Use the accounts table and a CASE statement to create two groups:
one group of company names that start with a number and
a second group of those company names that start with a letter.
What proportion of company names start with a letter?
*/

WITH total AS (SELECT COUNT(*) AS total
               FROM accounts),
     num_company AS (SELECT CASE WHEN LEFT(name, 1)
                                 IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
                                 THEN 'number'
                                 ELSE 'letter' END AS type,
                            COUNT(*) AS num_of_company
                     FROM accounts
                     GROUP BY 1
                     ORDER BY 2 DESC)

SELECT num_company.type,
       CAST(num_company.num_of_company AS FLOAT) /
       CAST((SELECT total FROM total) AS FLOAT) AS proportion
FROM num_company;

/*
4. Consider vowels as a, e, i, o, and u. What proportion of
company names start with a vowel, and what percent start with anything else?
*/

WITH total AS (SELECT COUNT(*) AS total
               FROM accounts),
     num_company AS (SELECT CASE WHEN LEFT(UPPER(name), 1)
                                 IN ('A', 'E', 'I', 'O', 'U')
                                 THEN 'vowel'
                                 ELSE 'etc' END AS type,
                            COUNT(*) AS num_of_company
                     FROM accounts
                     GROUP BY 1
                     ORDER BY 2 DESC)

SELECT num_company.type,
       CAST(num_company.num_of_company AS FLOAT) /
       CAST((SELECT total FROM total) AS FLOAT) AS proportion
FROM num_company;

-------------------------------------
----- POSITION, STRPOS, SUBSTR ------
-------------------------------------

/*
1. Use the accounts table to create first and last name columns that
hold the first and last names for the primary_poc.
*/

-- POSITION
SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) AS first,
       RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last
FROM accounts;

-- STRPOS
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first,
       RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last
FROM accounts;

/*
2. Now see if you can do the same thing for every rep name
in the sales_reps table. Again provide first and last name columns.
*/

-- POSITION
SELECT LEFT(name, POSITION(' ' IN name) - 1) AS first,
       RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) AS last
FROM sales_reps;

-- STRPOS
SELECT LEFT(name, STRPOS(name, ' ') - 1) AS first,
       RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) AS last
FROM sales_reps;

-------------------
----- CONCAT ------
-------------------

/*
1. Each company in the accounts table wants to create
an email address for each primary_poc.
The email address should be the first name of the primary_poc.
last name primary_poc @ company name .com.
*/

SELECT name,
       LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1)
       || '.'
       || RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))
       || '@'
       || name
       || '.com'
       AS email
FROM accounts;

/*
2. You may have noticed that in the previous solution some of the
company names include spaces, which will certainly not work in an email address.
See if you can create an email address that will work by
removing all of the spaces in the account name,
but otherwise your solution should be just as in question 1.
Some helpful documentation is here.
https://www.postgresql.org/docs/8.1/functions-string.html
*/

SELECT name,
       LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1)
       || '.'
       || RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))
       || '@'
       || REPLACE(name, ' ', '')
       || '.com'
       AS email
FROM accounts;

/*
3. We would also like to create an initial password,
which they will change after their first log in.
The first password will be the first letter of the primary_poc''s
first name (lowercase), then the last letter of their first name (lowercase),
the first letter of their last name (lowercase),
the last letter of their last name (lowercase),
the number of letters in their first name,
the number of letters in their last name,
and then the name of the company they are working with,
all capitalized with no spaces.
*/

--correct answer
WITH primary_poc AS (SELECT name,
                        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first,
                        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last
                     FROM accounts)

SELECT a.name,
          LOWER(LEFT(p.first, 1))
       || LOWER(RIGHT(p.first, 1))
       || LOWER(LEFT(p.last, 1))
       || LOWER(RIGHT(p.last, 1))
       || LENGTH(p.first)
       || LENGTH(p.last)
       || UPPER(REPLACE(a.name, ' ', ''))
       AS password
FROM accounts a
JOIN primary_poc p
ON a.name = p.name;

--another version
WITH primary_poc AS (SELECT name,
                        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first,
                        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last
                     FROM accounts),
     company AS (SELECT name,
                        LEFT(name, STRPOS(name, ' ') - 1) AS first,
                        RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) AS last
                 FROM accounts)

SELECT a.name,
          LOWER(LEFT(p.first, 1))
       || LOWER(LEFT(p.last, 1))
       || LOWER(LEFT(c.first, 1))
       || LOWER(LEFT(c.last, 1))
       || LENGTH(c.first)
       || LENGTH(c.last)
       || UPPER(REPLACE(a.name, ' ', ''))
       AS password
FROM accounts a
JOIN primary_poc p
ON a.name = p.name
JOIN company c
ON a.name = c.name;

-----------------
----- CAST ------
-----------------

/*
1. Write a query to look at the top 10 rows to understand the columns
and the raw data in the dataset calld sf_crime_data
*/

SELECT *
FROM sf_crime_data
LIMIT 10;

/*
2. Look at the data column in the sf_crime_data.
Notice the date in the correct format.
*/

SELECT date
FROM sf_crime_data
LIMIT 10;

/*
3. Write a query to change the date into the correct SQL date format.
You will need to use at least SUBSTR and CONCAT to perform this operation.
*/

SELECT date,
          SUBSTR(date, 7, 4)
       || '-'
       || SUBSTR(date, 1, 2)
       || '-'
       || SUBSTR(date, 4, 2)
       AS formatted_date
FROM sf_crime_data;

/*
4. Once you have created a column in the correct format,
use either CAST of :: to convert this to a date
*/

WITH formatted_date AS (SELECT id,
                                 SUBSTR(date, 7, 4)
                               || '-'
                               || SUBSTR(date, 1, 2)
                               || '-'
                               || SUBSTR(date, 4, 2)
                               AS formatted_date
                        FROM sf_crime_data)

SELECT s.date,
       f.formatted_date::date
FROM sf_crime_data s
JOIN formatted_date f
ON s.id = f.id;

---------------------
----- COALESCE ------
---------------------

/*
1. Run the query entered below in the SQL workspace
to notice row with missing data
*/

SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
2. Use COALESCE to fill in the accounts.id column
with the account.id for the NULL value for the table in 1.
*/

SELECT COALESCE(a.id, a.id) filled_id,
       a.name,
       a.website,
       a.lat,
       a.long,
       a.primary_poc,
       a.sales_rep_id,
       o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
3. Use COALESCE to fill in the orders.account_id column
with the account.id for the NULL value for the table in 1.
*/

SELECT COALESCE(a.id, a.id) filled_id,
       a.name,
       a.website,
       a.lat,
       a.long,
       a.primary_poc,
       a.sales_rep_id,
       o.id,
       COALESCE(o.account_id, a.id) filled_account_id,
       o.occurred_at,
       o.standard_qty,
       o.gloss_qty,
       o.poster_qty,
       o.total,
       o.standard_amt_usd,
       o.gloss_amt_usd,
       o.poster_amt_usd,
       o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
4. Use COALESCE to fill in each of the qty and usd columns
with 0 for the table in 1.
*/

SELECT COALESCE(a.id, a.id) filled_id,
       a.name,
       a.website,
       a.lat,
       a.long,
       a.primary_poc,
       a.sales_rep_id,
       o.id,
       COALESCE(o.account_id, a.id) filled_account_id,
       o.occurred_at,
       COALESCE(o.standard_qty, 0) filled_standard_qty,
       COALESCE(o.gloss_qty, 0) filled_gloss_qty,
       COALESCE(o.poster_qty, 0) filled_poster_qty,
       o.total,
       COALESCE(o.standard_amt_usd, 0) filled_standard_amt_usd,
       COALESCE(o.gloss_amt_usd, 0) filled_gloss_amt_usd,
       COALESCE(o.poster_amt_usd, 0) filled_poster_amt_usd,
       o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
5. Run the query in 1 with the WHERE removed and COUNT the number of ids.
*/

SELECT COUNT(a.id)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

/*
6. Run the query in 5,
but with the COALESCE function used in questions 2 through 4.
*/

SELECT COUNT(a.id)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;
