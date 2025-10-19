/* Customer Count & Revenue by Country (Catalog View, PostgreSQL)

Purpose:
  Country-level rollup showing how many customers per country and how much they’ve paid in total.

Grain:
  1 row per country.

Strategy:
  - Join spine: customer -> address -> city -> country.
  - Aggregate at country.

Outputs:
  country,
  customer_count  (COUNT DISTINCT customer_id),
  total_payment   (SUM payment.amount, 0 if no payments)

Guards:
  - COALESCE(SUM(p.amount), 0) to show 0 instead of NULL when no payments.
*/

SELECT
  co.country                     AS country,
  COUNT(DISTINCT c.customer_id)  AS customer_count,
  COALESCE(SUM(p.amount), 0)     AS total_payment
FROM customer c
JOIN address  a   ON a.address_id  = c.address_id
JOIN city     ci  ON ci.city_id    = a.city_id
JOIN country  co  ON co.country_id = ci.country_id
JOIN rental  r   ON r.customer_id = c.customer_id
JOIN payment p   ON p.rental_id   = r.rental_id
GROUP BY
  co.country
ORDER BY
  total_payment DESC;
