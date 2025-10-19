# Rockbuster Stealth Analysis
### Using SQL and Tableau to Guide a Streaming Launch

SQL and Tableau analysis for **Rockbuster Stealth**, a global movie rental company preparing to enter streaming.  
The project explores **catalog performance**, **customer segmentation**, and **geographic revenue trends** to guide decisions on content investment and market expansion.

Key findings show that **catalog diversity drives steady growth**, **mid-sized regions deliver strong per-customer value**, and **high-value customers are globally dispersed**, informing leadership’s strategic roadmap.

- **Repo:** `rockbuster-sql`
- **Stack:** PostgreSQL → CSV exports → Tableau
- **Goals:** document queries and keep a tidy repo

---

## Repo Structure
rockbuster-sql/
├─ README.md
├─ docs/
│ └─ case-study.md
├─ sql/
│ ├─ 01_revenue_by_rating_postgres.sql
│ ├─ 02_revenue_by_category_postgres.sql
│ ├─ 03a_revenue_by_film_category_postgres.sql
│ ├─ 03b_revenue_by_film_safe_postgres.sql
│ ├─ 04_customer_country_rollups_postgres.sql
│ └─ 05_customer_ltv_by_country_postgres.sql
└─ data/
└─ .gitkeep


