# Customer Shopping Behavior Analysis

A data analysis project on a retail dataset of 3,900 customer purchases. I cleaned the data with Python, loaded it into a SQL database, answered business questions with SQL, and summarised the results with charts.

## Tools used
Python (pandas, matplotlib), SQL (SQLite), Power BI (for the dashboard)

## Folder structure
```
data/         raw and cleaned csv files
sql/          queries.sql  (Q1-Q10 + my extra queries E1-E5)
results/      output of every query as csv
images/       charts
analysis.py   cleaning, loading to SQLite, running queries, charts
```

## How to run
```bash
pip install -r requirements.txt
python analysis.py
```
It creates a local `customer.db` file, so no database installation is needed.

## Data cleaning
- Only `Review Rating` had missing values (37 rows). I filled them with the median rating of the same category.
- Renamed columns to snake_case so they are easier to use in SQL.
- Added `age_group` (age quartiles) and `purchase_frequency_days` (frequency text converted to days).
- Dropped `promo_code_used` because it was exactly the same as `discount_applied`.
- Checked that `customer_id` is unique and no nulls are left.

## What I found
Total revenue is $233,081 from 3,900 orders, around $59.76 per order.

- **Gender:** male customers bring in about 68% of revenue ($157,890 vs $75,191).
- **Category:** Clothing is the biggest ($104K), then Accessories ($74K), Footwear ($36K), Outerwear ($19K). Clothing and Accessories together are about 77% of revenue.
- **Subscribers:** they do not spend more per order ($59.49 vs $59.87). Only 27% of customers are subscribed.
- **Discounts:** about 43% of orders use a discount, but discounted orders are not bigger ($59.28 vs $60.13).
- **Age:** revenue is split fairly evenly (24% to 27% per group).
- **Segments:** 3,116 of 3,900 customers have more than 10 previous purchases, so the "Loyal" group is 80% of everyone. The thresholds probably need to be changed for this data.
- **Shipping:** Express orders average $60.48 and Standard $58.46. The gap is small.
- **Best rated items:** Gloves, Sandals, Boots, Hat, Skirt (about 3.8 average rating).

## Recommendations
1. Look again at the discount strategy. Discounts are used a lot but do not increase spend per order, so targeted offers may work better.
2. Make the subscription more valuable. Subscribers are not spending more right now.
3. Run campaigns aimed at female customers, who bring in about a third of revenue.
4. Focus stock and marketing on Clothing and Accessories.


## Dashboard
For the Power BI part I used `data/customer_cleaned.csv`.

