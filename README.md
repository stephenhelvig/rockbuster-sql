# Rockbuster Stealth Analysis
### Using SQL and Tableau to Guide a Streaming Launch

SQL + Tableau analysis for **Rockbuster Stealth**, a global movie rental company preparing to enter streaming.  
The project explores **catalog performance**, **customer segmentation**, and **geographic revenue trends** to guide content investment and market expansion.

- **Repo:** `rockbuster-sql`
- **Stack:** PostgreSQL → CSV exports → Tableau
- **Goal:** Clean, grain-aware queries you can reuse and explain.

---

## Repo Structure
- `sql/` — productionized Postgres queries (single SELECT; guards commented if present)
- `docs/` — case study notes & screenshots
- `data/` — CSV exports (optional; kept with .gitkeep)

## Data & Assumptions
- Dataset: **DVD Rental** sample (PostgreSQL).
- Each rental has a payment (in this project’s scope).
- Some queries use **catalog view** (count all films/customers even if zero activity).
- Others use **active view** (only revenue-generating rows).
- Guard queries are commented at the top of files when relevant.

## How to Run / Export
1. Open a `.sql` file in your SQL client (psql, DBeaver, etc.).  
2. Execute the statement.  
3. Export result → **CSV** 
4. Connect the CSV in **Tableau** and build/refresh visuals.

---

## Query Index

| File | Purpose (Grain) | View | Key Outputs |
|---|---|---|---|
| `sql/01_revenue_by_rating_postgres.sql` | Revenue & rentals **by rating** (1 row/rating). Uses full catalog for film counts. | **Catalog** | `rating, films_in_rating, rentals, revenue, pct_of_total_rentals, pct_of_total_revenue, revenue_per_film` |
| `sql/02_revenue_by_category_postgres.sql` | Revenue & rentals **by category** (1 row/category). Film counts from catalog. | **Catalog** | `category, films_in_category, rentals, revenue, rentals_per_film, revenue_per_film` |
| `sql/03a_revenue_by_film_postgres.sql` | Revenue **by film** with category & rating for context (1 row/film–category). | **Active** | `film_id, title, rating, category, revenue` |
| `sql/03b_revenue_by_film_safe_postgres.sql` | **Mulitple Categories Safe** revenue **by film** (1 row/film). Computes film revenue then attaches a single deterministic category. | **Active** | `film_id, title, rating, category, revenue` |
| `sql/04_customer_count_and_revenue_by_country_postgres.sql` | Customer count & total payments **by country** (1 row/country). | **Catalog** | `country, customer_count, total_payment` |
| `sql/05_customer_LTV_by_country_postgres.sql` | Customer-level LTV with country (1 row/customer). | **Active** | `customer_id, country, rentals, total_amount` |

### Catalog vs. Active (rule of thumb)
- **Catalog view**: denominator is the full catalog (e.g., films per rating, customers per country). Includes zero-activity items.  
- **Active view**: only rows that generated revenue (e.g., top films/customers).

---

## Highlights
- PG-13 leads total revenue, even after normalizing per film.  
- Some smaller categories punch above their weight on **revenue per film**.  
- High-LTV customers are broadly distributed across countries.

## Design Notes
- **Join spine**: revenue analyses anchor on `payment → rental → inventory → film`; catalog counts anchor on `film` (or `customer`) with LEFT JOINs.  
- **Many-to-many**: `film ↔ category` can duplicate rows; safe variant computes revenue per film first.  
- **Numerics**: use `COALESCE`, `NULLIF`, and numeric casts to avoid NULLs, divide-by-zero, and integer division.

---

## Next Steps
