# Customer shopping behavior analysis
# Steps: clean the data with pandas -> load into SQLite -> run the SQL queries -> make charts

import re
import sqlite3
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# 1. load the raw data
df = pd.read_csv("data/customer_shopping_behavior_raw.csv", encoding="utf-8-sig")
print("rows, columns:", df.shape)
print("missing values:")
print(df.isnull().sum()[df.isnull().sum() > 0])

# 2. cleaning
# only Review Rating has missing values (37 rows), fill with the median of that category
df["Review Rating"] = df.groupby("Category")["Review Rating"].transform(lambda x: x.fillna(x.median()))

# column names -> snake_case so they are easy to use in SQL
df.columns = [re.sub(r"\s+", "_", c.strip().lower()) for c in df.columns]
df = df.rename(columns={"purchase_amount_(usd)": "purchase_amount"})

# age groups using quartiles
df["age_group"] = pd.qcut(df["age"], q=4, labels=["Young Adult", "Adult", "Middle-aged", "Senior"]).astype(str)

# turn the frequency text into number of days
freq_days = {"Weekly": 7, "Fortnightly": 14, "Bi-Weekly": 14, "Monthly": 30,
             "Quarterly": 90, "Every 3 Months": 90, "Annually": 365}
df["purchase_frequency_days"] = df["frequency_of_purchases"].map(freq_days)

# promo_code_used is exactly the same as discount_applied, so drop one of them
print("promo code same as discount:", (df["discount_applied"] == df["promo_code_used"]).all())
df = df.drop(columns="promo_code_used")

print("nulls left:", df.isnull().sum().sum(), "| customer_id unique:", df["customer_id"].is_unique)
df.to_csv("data/customer_cleaned.csv", index=False)

# 3. load into a SQLite database (no server needed)
con = sqlite3.connect("customer.db")
df.to_sql("customer", con, if_exists="replace", index=False)

# 4. run every query in sql/queries.sql and save the output
text = open("sql/queries.sql").read()
for block in re.split(r"\n(?=-- (?:Q|E)\d+\.)", text):
    m = re.match(r"-- ((?:Q|E)\d+)\.", block)
    if m:
        result = pd.read_sql(block.strip().rstrip(";"), con)
        result.to_csv(f"results/{m.group(1).lower()}.csv", index=False)
        print(m.group(1), "->", len(result), "rows")

# 5. charts
plt.rcParams.update({"figure.dpi": 130, "axes.spines.top": False, "axes.spines.right": False})
blue = "#2f6f9f"

def run(sql):
    return pd.read_sql(sql, con)

def save(name):
    plt.tight_layout()
    plt.savefig(f"images/{name}.png")
    plt.close()

d = run("SELECT gender, SUM(purchase_amount) AS rev FROM customer GROUP BY gender")
plt.bar(d.gender, d.rev, color=blue)
plt.title("Revenue by gender (USD)")
save("01_revenue_by_gender")

d = run("SELECT age_group, SUM(purchase_amount) AS rev FROM customer GROUP BY age_group ORDER BY rev DESC")
plt.bar(d.age_group, d.rev, color=blue)
plt.title("Revenue by age group (USD)")
save("02_revenue_by_age_group")

d = run("SELECT category, SUM(purchase_amount) AS rev FROM customer GROUP BY category ORDER BY rev DESC")
plt.bar(d.category, d.rev, color=blue)
plt.title("Revenue by category (USD)")
save("03_revenue_by_category")

d = run("SELECT location, SUM(purchase_amount) AS rev FROM customer GROUP BY location ORDER BY rev DESC LIMIT 10")
d = d.iloc[::-1]
plt.barh(d.location, d.rev, color=blue)
plt.title("Top 10 states by revenue (USD)")
save("04_top_states")

d = run("""SELECT CASE WHEN previous_purchases = 1 THEN 'New'
                      WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
                      ELSE 'Loyal' END AS segment, COUNT(*) AS n
           FROM customer GROUP BY segment""").set_index("segment").reindex(["New", "Returning", "Loyal"])
plt.bar(d.index, d.n, color=blue)
plt.title("Customers by segment")
save("05_customer_segments")

d = run("SELECT season, category, SUM(purchase_amount) AS rev FROM customer GROUP BY season, category")
d.pivot(index="season", columns="category", values="rev").plot(kind="bar", figsize=(7, 4))
plt.title("Revenue by season and category (USD)")
plt.xticks(rotation=0)
plt.legend(title="category", loc="upper left", bbox_to_anchor=(1.01, 1), frameon=False)
save("06_season_category")

d = run("SELECT subscription_status AS s, ROUND(AVG(purchase_amount), 2) AS avg FROM customer GROUP BY s")
plt.bar(d.s, d.avg, color=blue)
plt.title("Average spend: subscribers vs non-subscribers (USD)")
save("07_subscription_spend")

con.close()
print("done")
