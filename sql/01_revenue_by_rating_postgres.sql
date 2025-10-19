/* Revenue by Rating — Catalog View (PostgreSQL)

Purpose:
  Summarize rentals & revenue by MPAA rating with the denominator = ALL films in the catalog,
  so unrented films still count in films_in_rating.

Grain:
  1 row per rating.

Strategy:
  - totals CTE: computes grand totals for rentals & revenue once (for stable % of total).
  - Main query:
      • Film counts from film (catalog).
      • Rentals & revenue via LEFT JOINs: film -> inventory -> rental -> payment,
        so ratings with zero activity are retained.
      • Percent-of-total fields divide by the totals from the CTE.
      • revenue_per_film uses the catalog denominator (films_in_rating).

Outputs:
  rating,
  films_in_rating,
  rentals,
  revenue,
  pct_of_total_rentals,
  pct_of_total_revenue,
  revenue_per_film

Guards:
  - COALESCE(SUM(p.amount), 0.0) to treat “no payments” as 0 in arithmetic.
  - NULLIF(denominator, 0) to avoid divide-by-zero in per-film and percentage calcs.
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
