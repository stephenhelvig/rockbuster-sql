# Rockbuster Stealth Analysis
### Using SQL and Tableau to Guide a Streaming Launch

SQL and Tableau analysis for **Rockbuster Stealth**, a global movie rental company preparing to enter streaming.  
The project explores **catalog performance**, **customer segmentation**, and **geographic revenue trends** to guide decisions on content investment and market expansion.

Key findings show that **catalog diversity drives steady growth**, **mid-sized regions deliver strong per-customer value**, and **high-value customers are globally dispersed**, informing leadership’s strategic roadmap.

- **Repo:** `rockbuster-sql`
- **Stack:** PostgreSQL → CSV exports → Tableau
- **Goals:** document queries and keep a tidy repo

---


- `sql/` — productionized queries (Postgres-dialect).
- `docs/` — narrative assets (case study, visuals).
- `data/` — CSV outputs for Tableau (tracked but empty by default via `.gitkeep`).

---

## Query Index

| File | Purpose | Inputs (tables) | Output (columns) | Notes / Guards |
|---|---|---|---|---|
| `01_revenue_by_rating_postgres.sql` | Revenue grouped by MPAA rating | `film`, `inventory`, `rental`, `payment` | rating, rentals, revenue | Guard: inner joins via PK/FK; `COALESCE` on revenue; `GROUP BY rating`. |
| `02_revenue_by_category_postgres.sql` | Revenue by film category | `category`, `film_category`, `film`, `inventory`, `rental`, `payment` | category, rentals, revenue | Guard: category join through bridge; distinct inventory keys. |
| `03a_revenue_by_film_category_postgres.sql` | Revenue by **film** within category | Same as 02 + `film.title` | category, film, rentals, revenue | For drill-downs; can be heavy—consider `WHERE category IN (...)`. |
| `03b_revenue_by_film_safe_postgres.sql` | **Safe** version w/ CTE guards & filters | Same as 03a | category, film, rentals, revenue | Guards: CTEs, constrained time window, `EXPLAIN` comment, optional `LIMIT`. |
| `04_customer_country_rollups_postgres.sql` | Customers by country with rollups | `customer`, `address`, `city`, `country`, `payment` | country, customers, revenue | Guard: `GROUPING SETS`/`ROLLUP` only if supported; otherwise plain `GROUP BY`. |
| `05_customer_ltv_by_country_postgres.sql` | LTV per customer & country | `customer`, `payment`, geo tables | customer_id, country, ltv_total, first_txn, last_txn | Guard: window fn for totals; floor to cents; exclude refunds if present. |

> Each `.sql` file starts with: project header, expected schema, and export instructions.


