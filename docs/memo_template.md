# Recommendation memo — template

Write this yourself in Word or Google Docs, one page maximum, then export it to `docs/recommendation_memo.pdf`.
Every number must come from a file in `outputs/` (the source file is shown in brackets). Delete the brackets in the final version.

---

**To:** Head of Growth, Olist marketplace
**From:** Vinayak Seth, Business Analyst
**Subject:** Revenue is not compounding — fix second-order conversion first

### 1. The problem (2–3 sentences)
State the headline: total revenue, the repeat-customer rate, and the share of revenue from repeat customers. [01_business_kpis]
Say why it matters: almost all growth has to be bought with new-customer acquisition.

### 2. What the data shows (3 findings, one short paragraph each)

**Finding 1 — Retention is the leak.**
Give the retention % in month 1 to month 3 for a typical cohort [03_cohort_retention] and the segment sizes [05_segment_summary].

**Finding 2 — Late delivery wrecks satisfaction, mostly in specific places and periods.**
Compare average review on time vs 1–3 days late vs 4+ days late [06]. Name the worst months [02] and states [08].

**Finding 3 — A hypothesis I tested and rejected.**
I expected late first deliveries to be the main reason customers don't return. Customers with a late first order do repeat less [07], but the revenue gap is small [11] because only ~7% of orders are late.
→ Late delivery is a *reputation and review* problem, not the main *retention* problem.
(Keep this finding. It shows you follow data over assumptions, and interviewers ask about it.)

### 3. Recommendations (prioritized)

| # | Action | Why | Estimated impact |
|---|---|---|---|
| 1 | Second-order program for "New high-value" customers (e.g. a voucher 30 days after first delivery) | biggest segment by revenue that has bought only once [05] | +1–2 pp repeat rate ≈ R$ ___ [12] |
| 2 | Add carrier and seller capacity before peak periods in the worst states | late-% spikes [02, 08] | protects ratings on __% of orders |
| 3 | Seller late-delivery scorecard | top sellers by late orders [10] | ___ late orders addressed |

### 4. Assumptions and limits (3 bullets)
- Correlation, not causation. Recommendation 1 should be tested as an A/B test before full rollout.
- Repeat value uses the historical average revenue per repeat customer [12].
- Data covers 2016–2018 only. Incomplete months are excluded from the trends.

### 5. Next step
One sentence: what you would measure in the first 30 days of the pilot.
