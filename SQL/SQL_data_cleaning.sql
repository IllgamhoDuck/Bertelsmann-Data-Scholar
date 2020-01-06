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
