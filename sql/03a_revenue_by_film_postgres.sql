/* Revenue by Film (Category & Rating included) — Active View (PostgreSQL)

Purpose:
  Rank films by total revenue, including category and rating for context.
  Uses an “active” population (only revenue-generating films).

Grain:
  1 row per film–category.
  Assumes one category per film; if not, a film will appear multiple times and its revenue will repeat.

Strategy:
  - Join spine: payment -> rental -> inventory -> film -> film_category -> category
    (INNER JOINs restrict to films that generated revenue.)
  - SUM(p.amount) aggregates revenue at the film level, then grouped with category & rating.

Outputs:
  film_id,
  title,
  rating,
  category,
  revenue

Guards:
  - Optional validation query (commented below) checks the “one category per film” assumption:
    films with 0 or >1 categories should return 0 rows if the assumption holds.

Notes:
  If there's ever more than one category added to a film and you later aggregate this output by category without deduping films, totals can be overstated.
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
