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

Notes:
  Sorting by total_amount DESC then rentals makes Top-N selection straightforward in BI.
*/

SELECT
c.customer_id,
co.country,
COUNT(r.rental_id) AS rentals,
SUM(p.amount)      AS total_amount
FROM payment  p
JOIN rental   r  ON p.rental_id   = r.rental_id
JOIN customer c  ON r.customer_id = c.customer_id
JOIN address  a  ON c.address_id  = a.address_id
JOIN city     ci ON a.city_id      = ci.city_id
JOIN country  co ON ci.country_id  = co.country_id
GROUP BY c.customer_id, co.country
ORDER BY total_amount DESC, rentals DESC, c.customer_id;
