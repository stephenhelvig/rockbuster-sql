/* Revenue by Film (Future-proof, Category & Rating included) — Catalog of Performers (PostgreSQL)

Purpose:
  Report revenue at the film grain without risking double-counting from film↔category many-to-many.
  Revenue is computed per film first, then a single representative category is attached.

Grain:
  1 row per film (never duplicated by category).

Strategy:
  - film_revenue CTE: SUM(p.amount) per film via payment -> rental -> inventory -> film.
  - one_category CTE: pick one deterministic category per film (MAX(c.name) = alphabetical).
  - LEFT JOIN film_revenue to one_category to include films even if a category is missing.

Outputs:
  film_id,
  title,
  rating,
  category (representative),
  revenue

Notes:
  - Deterministic pick keeps totals stable even if a film has multiple categories.
  - If you want to show *all* categories without changing the grain, use the commented
    STRING_AGG alternative to attach a comma-separated category list.
*/

WITH film_revenue AS (
  SELECT
    f.film_id,
    f.title,
    f.rating,
    SUM(p.amount) AS revenue
  FROM payment  p
  JOIN rental   r ON r.rental_id    = p.rental_id
  JOIN inventory i ON i.inventory_id = r.inventory_id
  JOIN film      f ON f.film_id      = i.film_id
  GROUP BY f.film_id, f.title, f.rating
),
one_category AS (
  -- Attach one deterministic category per film (safe if films can have multiple categories)
  SELECT
    fc.film_id,
    MAX(c.name) AS category
  FROM film_category fc
  JOIN category c ON c.category_id = fc.category_id
  GROUP BY fc.film_id
)
SELECT
  fr.film_id        AS film_id,
  fr.title          AS title,
  fr.rating         AS rating,
  oc.category       AS category,   -- representative category (deterministic)
  fr.revenue        AS revenue
FROM film_revenue fr
LEFT JOIN one_category oc ON oc.film_id = fr.film_id
ORDER BY fr.revenue DESC, fr.film_id;


-- Alternative: if you prefer to show *all* categories without changing the grain,
-- replace one_category with a categories list:
-- film_cats AS (
--   SELECT fc.film_id,
--          STRING_AGG(DISTINCT c.name, ', ' ORDER BY c.name) AS categories
--   FROM film_category fc
--   JOIN category c ON c.category_id = fc.category_id
--   GROUP BY fc.film_id
-- )
-- ... then LEFT JOIN film_cats and select film_cats.categories instead of oc.category.
