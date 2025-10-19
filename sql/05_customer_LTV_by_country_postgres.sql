/* Customer LTV by Country (Active View, PostgreSQL)

Purpose:
  One row per customer with their lifetime rentals and revenue, plus country for mapping.
  Designed as a base table that Tableau can aggregate by country or rank customers.

Grain:
  1 row per customer (scoped to their current address’ country).

Strategy:
  - Join spine: payment -> rental -> customer -> address -> city -> country.
    (INNER JOINs restrict to customers who generated revenue.)
  - Aggregate at customer_id, then let BI tools roll up by country as needed.

Outputs:
  customer_id,
  country,
  rentals        (COUNT of rental_id),
  total_amount   (SUM of payment.amount)

Guards:
  - None needed for this dataset; starting at payment excludes zero-activity customers.
    If you need to include customers with zero payments, switch the last two joins to LEFT JOINs
    from customer and wrap SUM with COALESCE(...,0).
*/

SELECT
  c.customer_id,
  co.country,
  SUM(p.amount) AS total_amount
FROM payment p
JOIN rental   r  ON r.rental_id   = p.rental_id
JOIN customer c  ON c.customer_id = r.customer_id
JOIN address  a  ON a.address_id  = c.address_id
JOIN city     ci ON ci.city_id    = a.city_id
JOIN country  co ON co.country_id = ci.country_id
GROUP BY
  c.customer_id,
  co.country
ORDER BY
  total_amount DESC;
