# Customer Shopping Behavior Analysis

A data analysis project exploring 3,900 customer purchases to identify revenue trends, purchasing patterns, discount effectiveness, and customer behavior. The project uses Python for data cleaning and analysis, SQL for business queries, and Power BI for dashboard visualization.

## Tools Used
- **Python:** pandas, matplotlib
- **SQL:** SQLite
- **Power BI:** Dashboard and data visualization

## Project Structure

```text
customer-shopping-behavior-analysis/
├── data/          # Raw and cleaned CSV files
├── sql/           # SQL queries (Q1–Q10 and E1–E5)
├── results/       # CSV outputs from SQL queries
├── analysis.py    # Data cleaning, SQLite loading, queries, and charts
├── requirements.txt
└── README.md
```

## How to Run

1. Install the required Python packages:

   ```bash
   pip install -r requirements.txt
   ```

2. Run the analysis:

   ```bash
   python analysis.py
   ```

The script creates a local `customer.db` SQLite database, so no separate database server is required.

## Data Cleaning

- Handled 37 missing review ratings by filling them with the median rating for the corresponding product category.
- Renamed columns to snake_case for easier SQL querying.
- Created `age_group` using age quartiles.
- Converted purchase frequency descriptions into `purchase_frequency_days`.
- Dropped `promo_code_used` because it duplicated `discount_applied`.
- Checked customer ID uniqueness and verified that no null values remained.

## Key Findings

### Revenue Overview
- **Total revenue:** $233,081 across 3,900 orders.
- **Average order value:** Approximately $59.76.

### Gender
- Male customers generated approximately $157,890, or 68% of revenue.
- Female customers generated approximately $75,191, or 32% of revenue.

### Product Categories
- Clothing: approximately $104K.
- Accessories: approximately $74K.
- Footwear: approximately $36K.
- Outerwear: approximately $19K.

Clothing and Accessories together contributed approximately 77% of total revenue.

### Subscription Behavior
- Approximately 27% of customers are subscribers.
- Subscribers spent an average of $59.49 per order, compared with $59.87 for non-subscribers.

### Discount Effectiveness
- Approximately 43% of orders used a discount.
- Discounted orders averaged $59.28, compared with $60.13 for orders without discounts.

### Age Groups
Revenue was distributed relatively evenly across age groups, with each group contributing approximately 24%–27%.

### Customer Segments
- 3,116 out of 3,900 customers had more than 10 previous purchases.
- The current Loyal segment represents approximately 80% of customers, suggesting that the segmentation thresholds may need refinement.

### Shipping Preferences
- Express shipping average order value: $60.48.
- Standard shipping average order value: $58.46.

The difference is relatively small.

### Highest-Rated Products
Gloves, Sandals, Boots, Hats, and Skirts were among the highest-rated product categories or items, with average ratings around 3.8. Validate the exact grouping used in the SQL query before interpreting these as individual products.

## Business Recommendations

1. **Improve discount targeting:** Discounts are common, but discounted orders have slightly lower average values. Test targeted offers and evaluate their impact on revenue and profitability.
2. **Strengthen subscription value:** Explore exclusive benefits and measure subscriber retention and spending over time.
3. **Expand female customer engagement:** Test campaigns designed to increase engagement and revenue among female customers.
4. **Prioritize key categories:** Use demand, margins, and inventory data to guide marketing and stock decisions for Clothing and Accessories.
5. **Refine customer segmentation:** Adjust purchase-frequency thresholds so the Loyal segment better distinguishes customer behavior.

## Power BI Dashboard

The Power BI dashboard uses `data/customer_cleaned.csv` and provides a visual overview of customer purchasing behavior, revenue, product categories, and related business metrics.

