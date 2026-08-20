# Cyclistic Bike-Share Analysis

An end-to-end data analytics case study comparing how casual riders and annual members use Cyclistic bikes. The project was completed as part of the Google Data Analytics Professional Certificate.

## Business Task

Develop data-driven marketing recommendations that can help Cyclistic convert casual riders into annual members.

## Analysis Question

**How do annual members and casual riders use Cyclistic bikes differently?**

## Project Overview

Cyclistic is a fictional bike-share company in Chicago. Its customers include casual riders, who purchase single-ride or day passes, and annual members, who purchase yearly memberships.

The purpose of this analysis is to identify differences in riding behavior and use those insights to support targeted membership campaigns.

## Dataset

- **Source:** Public Cyclistic/Divvy historical trip data
- **Period:** August 2025 – July 2026
- **Files:** 12 monthly CSV files
- **Initial dataset:** 6,037,933 rows
- **Final cleaned dataset:** 5,871,668 rows

The dataset contains ride identifiers, bike types, start and end timestamps, station information, coordinates, and customer type (`member` or `casual`).

## Tools Used

- **Google BigQuery / SQL** — data validation, cleaning, transformation, and analysis
- **Tableau Public** — data visualization and dashboard creation
- **GitHub** — project documentation and SQL portfolio

## Data Preparation and Cleaning

The 12 monthly datasets were combined into one table in BigQuery. The following quality checks and cleaning steps were completed:

1. Verified the row count of every monthly table.
2. Checked column names, data types, and schema consistency across all 12 tables.
3. Validated the total number of combined records.
4. Identified 35 duplicate ride IDs and removed duplicated records.
5. Checked critical fields for missing values.
6. Identified invalid ride durations.
7. Removed rides shorter than one minute and rides lasting 24 hours or longer.
8. Created and validated the final analysis-ready table containing 5,871,668 rides.

[View the complete BigQuery SQL analysis](cyclistic_analysis.sql)

## Analysis Performed

The analysis compared casual riders and annual members across:

- total rides and percentage of rides;
- average ride duration;
- day-of-week patterns;
- monthly and seasonal trends;
- hourly usage patterns;
- bike-type preferences;
- average ride duration by weekday;
- most frequently used start stations.

## Tableau Dashboard

An interactive Tableau dashboard was created to visualize the differences between casual riders and annual members.

[View the interactive Tableau dashboard](https://public.tableau.com/app/profile/yana.novytska/viz/CyclisticBike-ShareAnalysis_17871437811940/CyclisticBike-ShareAnalysisMembersvsCasualRiders)

![Cyclistic dashboard — top section](dashboard-top.png.png)

![Cyclistic dashboard — bottom section](dashboard-bottom.png.png)

## Key Findings

- Annual members generated **64.77%** of all rides, while casual riders accounted for **35.23%**.
- Casual riders took longer trips, averaging **18.93 minutes**, compared with **12.26 minutes** for annual members.
- Members showed stronger activity during weekdays and commuting hours, suggesting more regular transportation use.
- Casual riders were relatively more active during weekends and later in the day, suggesting more recreational use.
- Both groups showed strong seasonality, with higher demand during warmer months and lower demand during winter.
- Differences in hourly activity, ride duration, bike preferences, and popular start stations create opportunities for targeted marketing.

Overall, annual members appear to use Cyclistic as a regular transportation service, while casual riders are more likely to use it occasionally for leisure and recreation.

## Recommendations

1. **Launch seasonal membership campaigns.**  
   Promote annual memberships before and during the high-demand spring and summer seasons. Test a limited-time discount or short membership trial.

2. **Target casual riders during weekends and leisure hours.**  
   Run digital campaigns when casual riders are most active and connect recreational riding with the convenience of annual membership.

3. **Demonstrate the financial value of membership.**  
   Show a simple comparison between repeated single-ride or day-pass costs and the cost of annual membership.

4. **Promote membership at popular casual-rider stations.**  
   Place QR codes, digital advertisements, and membership offers at stations frequently used by casual riders.

5. **Test campaigns and measure conversion.**  
   Use A/B testing to compare messages, discounts, and advertising channels. Track membership conversion rate, click-through rate, cost per conversion, and repeat casual rides before conversion.

## Data Limitations

The dataset contains trip-level information but does not include customer demographics, pricing history, individual purchase behavior, or reasons for choosing a particular pass. Therefore, the recommendations should be treated as data-informed hypotheses and validated through a pilot marketing campaign.

## Project Outcome

This project demonstrates my ability to:

- clean and validate a multi-million-row dataset using SQL;
- use aggregations, CTEs, and window functions in BigQuery;
- identify meaningful customer behavior patterns;
- build an interactive Tableau dashboard;
- translate analytical findings into practical business recommendations.

---

**Author:** Yana Novytska
