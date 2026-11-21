# Power BI DAX Measures

Create these measures after connecting Power BI to the MySQL `vw_sales_detail` view.

```DAX
Total Revenue = SUM(vw_sales_detail[net_revenue])

Total Profit = SUM(vw_sales_detail[gross_profit])

Total Orders = DISTINCTCOUNT(vw_sales_detail[order_id])

Unique Customers = DISTINCTCOUNT(vw_sales_detail[customer_id])

Average Order Value = DIVIDE([Total Revenue], [Total Orders])

Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0)

Units Sold = SUM(vw_sales_detail[quantity])

Revenue per Customer = DIVIDE([Total Revenue], [Unique Customers])

Previous Month Revenue =
CALCULATE([Total Revenue], DATEADD('Date'[Date], -1, MONTH))

MoM Revenue Growth % =
DIVIDE([Total Revenue] - [Previous Month Revenue], [Previous Month Revenue], 0)
```

## Recommended report pages
1. Executive Overview: Revenue, Profit, Orders, Customers, monthly trend.
2. Product Analysis: Category revenue, top products, margin.
3. Customer Analysis: Segment, top customers, repeat customer patterns.
4. Regional & Channel Analysis: Region/city and sales channel performance.

## Visual design
- Canvas: 16:9
- Use a restrained navy/white/teal theme.
- Add slicers for Date, Region, Category, Segment and Sales Channel.
- Use cards for KPIs, line chart for monthly trend, bar charts for rankings,
  and a matrix for category/region drill-down.
