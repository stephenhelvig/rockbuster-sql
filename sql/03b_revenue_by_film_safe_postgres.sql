/* Revenue by Film (Future-proof: Category & Rating included)
   Grain: one row per film (never duplicated by category).
   Why: film ↔ category can be many-to-many in other datasets. We compute revenue per film first,
        then attach exactly one deterministic category so totals are stable even if a film has multiple categories.
   Category choice: MAX(c.name) picks one category alphabetically (stable, deterministic).
   Join path (revenue): payment -> rental -> inventory -> film
   Metric: SUM(p.amount) as revenue
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
