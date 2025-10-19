/* Revenue by Rating — Catalog View (PostgreSQL)

Purpose: Summary by MPAA rating using the full film catalog as the denominator,
         so unrented films still count in films_in_rating.

Grain:   1 row per rating.

Join path: film ←left— inventory ←left— rental ←left— payment
           (LEFT JOINs keep zero-activity ratings.)

Columns:
  - rating
  - films_in_rating  (COUNT DISTINCT film_id from catalog)
  - rentals          (COUNT rental_id)
  - revenue          (SUM payment.amount)
  - pct_of_total_rentals = rentals in each rating * 100 / total_rentals (via totals CTE)
  - pct_of_total_revenue = revenue in each rating * 100 / total_revenue (via totals CTE)
  - revenue_per_film = revenue / films_in_rating

Guards:
  - COALESCE on SUM(amount) → treat “no payments” as 0
  - NULLIF on denominators → avoid divide-by-zero

Notes: Percentages use a single totals CTE for stability; let your BI tool handle formatting.
*/

WITH totals AS (
SELECT
COUNT(r.rental_id) AS total_rentals,
SUM(p.amount)      AS total_revenue
FROM film f
LEFT JOIN inventory i ON i.film_id = f.film_id
LEFT JOIN rental   r  ON r.inventory_id = i.inventory_id
LEFT JOIN payment  p  ON p.rental_id    = r.rental_id
)
SELECT
f.rating                                         AS rating,
COUNT(DISTINCT f.film_id)                        AS films_in_rating,
COUNT(r.rental_id)                               AS rentals,
COALESCE(SUM(p.amount), 0)                       AS revenue,
(COUNT(r.rental_id) * 100.0) / NULLIF(t.total_rentals, 0) AS pct_of_total_rentals,
(SUM(p.amount) * 100.0) / NULLIF(t.total_revenue, 0)      AS pct_of_total_revenue,
(COALESCE(SUM(p.amount), 0.0) / NULLIF(COUNT(DISTINCT f.film_id), 0))  AS revenue_per_film
FROM film f
LEFT JOIN inventory i ON i.film_id      = f.film_id
LEFT JOIN rental   r  ON r.inventory_id = i.inventory_id
LEFT JOIN payment  p  ON p.rental_id    = r.rental_id
CROSS JOIN totals t
GROUP BY f.rating, t.total_rentals, t.total_revenue
ORDER BY revenue DESC, f.rating;
