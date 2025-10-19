/* Revenue by Film (Category & Rating included)
   Grain: one row per film–category.
          Assumes one category per film; if a film has multiple categories it will appear multiple times,
          and the film’s total revenue will repeat across those rows.
   Join path: payment -> rental -> inventory -> film -> film_category -> category
   Metric: SUM(p.amount) as revenue
   Note: If you later aggregate this output by category without deduping films, totals can be overstated.
*/

-- ===== Guard (optional; uncomment to validate) =====
-- -- Films that have 0 or >1 categories (If truly one category per film, should return 0 rows)
-- SELECT
--   f.film_id,
--   f.title,
--   COUNT(DISTINCT fc.category_id) AS category_count
-- FROM film f
-- JOIN film_category fc ON fc.film_id = f.film_id
-- GROUP BY f.film_id, f.title
-- HAVING COUNT(DISTINCT fc.category_id) <> 1
-- ORDER BY f.film_id;

-- ===== Main query (single result set) =====
SELECT
  f.film_id        AS film_id,
  f.title          AS title,
  f.rating         AS rating,
  c.name           AS category,
  SUM(p.amount)    AS revenue
FROM payment   p
JOIN rental    r      ON r.rental_id    = p.rental_id
JOIN inventory i      ON i.inventory_id = r.inventory_id
JOIN film      f      ON f.film_id      = i.film_id
JOIN film_category fc ON fc.film_id     = f.film_id
JOIN category c       ON c.category_id  = fc.category_id
GROUP BY
  f.film_id, f.title, f.rating, c.name
ORDER BY
  revenue DESC, film_id;
