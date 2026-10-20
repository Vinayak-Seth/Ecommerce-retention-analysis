# Power BI dashboard — build guide

Tool: **Power BI Desktop** (free, Windows). Install from the Microsoft Store.
Save your file as `dashboard/ecommerce_retention.pbix`.

Plan for 3 pages. One question per page. A recruiter should understand each page in 10 seconds.

---

## 1. Load the data

Home → **Get data → Text/CSV** → load these files from `outputs/` one by one:

| File | Used on |
|---|---|
| `order_facts.csv` | every page (main fact table) |
| `customer_facts.csv` | page 2 |
| `04_rfm_segments.csv` | page 2 |
| `03_cohort_retention.csv` | page 2 |
| `12_retention_scenarios.csv` | page 2 |
| `06_delivery_vs_reviews.csv` | page 3 |
| `10_seller_late_delivery.csv` | page 3 |

After loading, open **Table view** and check the column types:
- `purchase_date`, `first_purchase_date`, `last_purchase_date` → **Date**
- `purchase_month`, `cohort_month` → **Text** (keep them as text so "2017-01" sorts correctly)
- money columns → **Decimal number**

## 2. Relationships (Model view)

Drag to connect:
- `customer_facts[customer_id]` → `order_facts[customer_id]` (one-to-many)
- `customer_facts[customer_id]` → `04_rfm_segments[customer_id]` (one-to-one)

The other CSVs are pre-aggregated summaries. Leave them unconnected.

## 3. Measures

Click `order_facts` → **New measure**, and paste one at a time:

```DAX
Total Revenue = SUM(order_facts[order_value])
Orders = COUNTROWS(order_facts)
Customers = DISTINCTCOUNT(order_facts[customer_id])
AOV = DIVIDE([Total Revenue], [Orders])
Late Delivery % = AVERAGE(order_facts[is_late])
Avg Review = AVERAGE(order_facts[review_score])
Avg Delivery Days = AVERAGE(order_facts[delivery_days])
Repeat Customer % =
    DIVIDE(
        CALCULATE(COUNTROWS(customer_facts), customer_facts[is_repeat] = 1),
        COUNTROWS(customer_facts)
    )
Repeat Order Share % =
    DIVIDE(CALCULATE([Orders], order_facts[order_seq] > 1), [Orders])
```

Format the `%` measures as Percentage (Measure tools → Format → %), and revenue as Currency with 0 decimals.
**The data is Brazilian, so the currency is BRL (R$), not ₹.**

**Check:** your card values must match `outputs/01_business_kpis.csv`. If they don't, a type or relationship is wrong. Fix that before you build anything else.

---

## Page 1 — "How is the business doing?" (Executive overview)

| Visual | Fields |
|---|---|
| 5 **Cards** across the top | Total Revenue, Orders, AOV, Repeat Customer %, Late Delivery % |
| **Line chart** | X: `purchase_month`, Y: Total Revenue. Add Orders on a secondary axis |
| **Line chart** | X: `purchase_month`, Y: Late Delivery % and Avg Review. The two lines move in opposite directions in Nov-2017 and Feb–Mar 2018 |
| **Slicer** | `state` (dropdown) |

Filter this page: `purchase_month` from 2017-01 to 2018-08. The months before and after that are incomplete in the dataset and make the trend look like a crash.

Title text box: one sentence that states the finding, not "Overview".

## Page 2 — "Why isn't revenue compounding?" (Customers & retention)

| Visual | Fields |
|---|---|
| **Matrix** (cohort heatmap) | Rows: `cohort_month`, Columns: `months_since_first`, Values: `retention_pct` (Sum). Filter `months_since_first` > 0, otherwise the 100% column flattens the colours. Then Format → Cell elements → **Background color** on |
| **Bar chart** | `04_rfm_segments[segment]` vs Count of customer_id |
| **Bar chart** | `segment` vs Sum of `total_value` |
| **Table** | all columns of `12_retention_scenarios` — this is the "what's it worth" visual |
| **Card** | Repeat Customer % |

## Page 3 — "Where does the customer experience break?" (Delivery & operations)

| Visual | Fields |
|---|---|
| **Column chart** | `06_delivery_vs_reviews[delivery_bucket]` vs `avg_review`, plus `pct_1_2_star` as a line (Line and clustered column chart) |
| **Bar chart** | `order_facts[state]` vs Late Delivery %, sorted descending. Use a bar chart, not a map: Power BI's map often misplaces Brazilian state codes like "SP" |
| **Line chart** | `purchase_month` vs Late Delivery % |
| **Table** | `10_seller_late_delivery` top 10 by `late_orders` |

---

## Design rules

- 1 accent colour plus grey. Use red only for "bad" (late, 1–2 star).
- Every page title is the conclusion in plain English, e.g. "97% of customers never place a second order".
- Remove gridlines and default visual titles you don't need.
- Use the same card size and alignment on every page (View → Gridlines + Snap to grid).

## Export and publish

1. **File → Export → Export to PDF**, then save as `dashboard/dashboard.pdf`. Recruiters can open this without Power BI.
2. Screenshot each page and save them to `dashboard/page1.png` etc. They show up in your GitHub README.
3. Optional live link: **Publish** needs a work or school Microsoft account. Try your university email. Then, in the Power BI web app, **File → Embed report → Publish to web**. If your university admin has disabled publish-to-web, skip this step. The PDF and screenshots are enough. If you really want a public link, rebuild page 1 in **Tableau Public** (free) using the same CSVs.
