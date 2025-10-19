/* Customer Count & Revenue by Country (Catalog View, PostgreSQL)

Purpose:
  Country-level rollup showing how many customers you have and how much they’ve paid in total.
  Counts all customers by country; countries with zero payments are still included.

Grain:
  1 row per country.

Strategy:
  - Join spine (customers -> geography): customer -> address -> city -> country.
  - LEFT JOIN to rental -> payment so countries with customers but no payments remain.
  - Aggregate at country.

Outputs:
  country,
  customer_count  (COUNT DISTINCT customer_id),
  total_payment   (SUM payment.amount, 0 if no payments)

Guards:
  - COALESCE(SUM(p.amount), 0) to show 0 instead of NULL when no payments.
  - Using LEFT JOINs preserves countries with zero activity.

Notes:
  If you only want countries with actual payments, switch the two LEFT JOINs to INNER JOINs
  and remove COALESCE.
*/

SELECT
co.country                                   AS country,
COUNT(DISTINCT c.customer_id)                AS customer_count,
COALESCE(SUM(p.amount), 0)                   AS total_payment
FROM customer c
JOIN address a   ON c.address_id = a.address_id
JOIN city ci     ON a.city_id     = ci.city_id
JOIN country co  ON ci.country_id = co.country_id
LEFT JOIN rental  r ON r.customer_id = c.customer_id
LEFT JOIN payment p ON p.rental_id   = r.rental_id
GROUP BY co.country
ORDER BY total_payment DESC, country;
