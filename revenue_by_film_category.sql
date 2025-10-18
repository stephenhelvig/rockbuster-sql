/* Revenue by Film–Category
   Grain: 1 row per film–category (film repeats if it has multiple categories)
   Metric: SUM(p.amount) as revenue
   Join path: payment -> rental -> inventory -> film -> film_category -> category
*/

SELECT
  f.film_id        AS film_id,
  f.title          AS title,
  f.rating         AS rating,
  c.name           AS category,  -- category label
  SUM(p.amount)    AS revenue    -- total payments attributed to the film
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
