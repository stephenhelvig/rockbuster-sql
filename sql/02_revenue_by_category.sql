/* Revenue by Category — Catalog View (PostgreSQL)

Purpose: Summarize rentals & revenue by category while keeping the denominator = ALL films
         in each category (catalog-based), not just films that generated revenue.

Grain:   1 row per category (category_id).

Strategy:
  - films CTE: counts distinct films per category from the catalog.
  - rev CTE:   rolls up rentals & revenue via payment -> rental -> inventory -> film.
  - LEFT JOIN on category_id preserves categories with zero rentals/revenue.
  - Per-film metrics divide by films_in_category (catalog denominator).

Outputs:
  category, films_in_category, rentals, revenue, rentals_per_film, revenue_per_film.

Guards:
  COALESCE(...) to treat missing activity as 0; NULLIF(...) to avoid divide-by-zero.
*/

WITH films AS (
  SELECT c.category_id, c.name AS category,
         COUNT(DISTINCT f.film_id) AS films_in_category
  FROM film f
  JOIN film_category fc ON fc.film_id = f.film_id
  JOIN category c       ON c.category_id = fc.category_id
  GROUP BY c.category_id, c.name
),
rev AS (
  SELECT c.category_id,
         COUNT(r.rental_id) AS rentals,
         SUM(p.amount)      AS revenue
  FROM payment  p
  JOIN rental   r  ON r.rental_id    = p.rental_id
  JOIN inventory i ON i.inventory_id = r.inventory_id
  JOIN film      f ON f.film_id      = i.film_id
  JOIN film_category fc ON fc.film_id    = f.film_id
  JOIN category c       ON c.category_id = fc.category_id
  GROUP BY c.category_id
)
SELECT
  f.category,
  f.films_in_category,
  r.rentals,
  r.revenue,
  COALESCE(r.rentals, 0)::numeric / NULLIF(f.films_in_category, 0) AS rentals_per_film,
  COALESCE(r.revenue, 0)         / NULLIF(f.films_in_category, 0)  AS revenue_per_film
FROM films f
LEFT JOIN rev r USING (category_id)
ORDER BY revenue DESC;
