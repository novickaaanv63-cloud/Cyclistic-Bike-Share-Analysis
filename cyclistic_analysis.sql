-- Cyclistic Bike-Share Analysis
-- Google BigQuery SQL
-- Analysis period: August 2025 - July 2026
-- Project: cyclistic-case-study-505413

-- ============================================================
-- 01. MONTHLY ROW COUNTS
-- Purpose: Verify the number of records in each monthly table
-- before combining and cleaning the dataset.
-- ============================================================
SELECT '2025-08' AS month, COUNT(*) AS total_rows
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202508`
UNION ALL
SELECT '2025-09', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202509`
UNION ALL
SELECT '2025-10', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202510`
UNION ALL
SELECT '2025-11', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202511`
UNION ALL
SELECT '2025-12', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202512`
UNION ALL
SELECT '2026-01', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202601`
UNION ALL
SELECT '2026-02', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202602`
UNION ALL
SELECT '2026-03', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202603`
UNION ALL
SELECT '2026-04', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202604`
UNION ALL
SELECT '2026-05', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202605`
UNION ALL
SELECT '2026-06', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202606`
UNION ALL
SELECT '2026-07', COUNT(*)
FROM `cyclistic-case-study-505413.cyclisticdata.trips_202607`;


-- ============================================================
-- 02. CHECK TABLE SCHEMA
-- Purpose: Inspect column names, data types, and column order
-- across all monthly trip tables.
-- ============================================================
SELECT
  table_name,
  column_name,
  data_type,
  ordinal_position
FROM `cyclistic-case-study-505413.cyclisticdata.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name LIKE 'trips_%'
ORDER BY table_name, ordinal_position;


-- ============================================================
-- 03. CHECK SCHEMA CONSISTENCY
-- Purpose: Confirm that every column has the same data type and
-- appears in all 12 monthly tables.
-- Expected result: tables_count = 12 for every column.
-- ============================================================
SELECT
  column_name,
  data_type,
  COUNT(DISTINCT table_name) AS tables_count
FROM `cyclistic-case-study-505413.cyclisticdata.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name LIKE 'trips_%'
GROUP BY column_name, data_type
ORDER BY column_name, data_type;


-- ============================================================
-- 04. CHECK TOTAL ROW COUNT
-- Purpose: Verify the total number of records in the combined
-- dataset before cleaning.
-- Result: 6,037,933 rows.
-- ============================================================
SELECT COUNT(*) AS total_rows
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_all_trips`;


-- ============================================================
-- 05. CHECK FOR DUPLICATE RIDE IDS
-- Purpose: Compare total records with unique ride IDs.
-- Result: 35 duplicate records were identified.
-- ============================================================
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ride_id) AS unique_ride_ids,
  COUNT(*) - COUNT(DISTINCT ride_id) AS duplicate_rows
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_all_trips`;


-- ============================================================
-- 06. REMOVE DUPLICATE RECORDS
-- Purpose: Create an intermediate table by removing completely
-- duplicated rows. Result: 35 duplicates removed.
-- ============================================================
CREATE OR REPLACE TABLE
  `cyclistic-case-study-505413.cyclisticdata.cyclistic_cleaned` AS
SELECT DISTINCT *
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_all_trips`;


-- ============================================================
-- 07. CHECK MISSING VALUES AND RIDE DURATION
-- Purpose: Check critical nulls and invalid ride durations.
-- ============================================================
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(ride_id IS NULL) AS null_ride_id,
  COUNTIF(started_at IS NULL) AS null_started_at,
  COUNTIF(ended_at IS NULL) AS null_ended_at,
  COUNTIF(member_casual IS NULL) AS null_member_casual,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 0) AS invalid_duration,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) BETWEEN 1 AND 59)
    AS rides_under_1_min,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440)
    AS rides_24h_or_more
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_cleaned`;


-- ============================================================
-- 08. CREATE THE FINAL CLEANED TABLE
-- Purpose: Keep rides lasting from 1 minute to under 24 hours.
-- Final result: 5,871,668 records.
-- ============================================================
CREATE OR REPLACE TABLE
  `cyclistic-case-study-505413.cyclisticdata.cyclistic_final` AS
SELECT *
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_cleaned`
WHERE TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 60
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 1440;


-- ============================================================
-- 09. VALIDATE THE FINAL CLEANED TABLE
-- Results: 5,871,668 final rows and zero invalid durations.
-- ============================================================
SELECT
  COUNT(*) AS final_rows,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60)
    AS rides_under_1_min,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440)
    AS rides_24h_or_more,
  COUNTIF(TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 0)
    AS invalid_duration
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`;


-- ============================================================
-- 10. TOTAL RIDES: MEMBERS VS CASUAL RIDERS
-- Key finding: members 64.77%; casual riders 35.23%.
-- ============================================================
SELECT
  member_casual,
  COUNT(*) AS total_rides,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_rides
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual
ORDER BY total_rides DESC;


-- ============================================================
-- 11. AVERAGE RIDE DURATION: MEMBERS VS CASUAL RIDERS
-- Key finding: casual 18.93 minutes; members 12.26 minutes.
-- ============================================================
SELECT
  member_casual,
  COUNT(*) AS total_rides,
  ROUND(AVG(TIMESTAMP_DIFF(ended_at, started_at, SECOND)) / 60, 2)
    AS avg_ride_minutes
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual
ORDER BY avg_ride_minutes DESC;


-- ============================================================
-- 12. RIDES BY DAY OF WEEK
-- Purpose: Compare weekly patterns and preserve weekday order.
-- ============================================================
SELECT
  member_casual,
  FORMAT_DATE('%A', DATE(started_at)) AS day_of_week,
  EXTRACT(DAYOFWEEK FROM started_at) AS day_number,
  COUNT(*) AS total_rides
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual, day_of_week, day_number
ORDER BY day_number, member_casual;


-- ============================================================
-- 13. MONTHLY RIDE TRENDS
-- Purpose: Compare monthly volumes and seasonal patterns.
-- ============================================================
SELECT
  member_casual,
  FORMAT_DATE('%Y-%m', DATE(started_at)) AS month,
  COUNT(*) AS total_rides
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual, month
ORDER BY month, member_casual;


-- ============================================================
-- 14. RIDES BY HOUR OF DAY
-- Purpose: Compare hourly usage patterns by customer type.
-- ============================================================
SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS hour_of_day,
  COUNT(*) AS total_rides
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual, hour_of_day
ORDER BY hour_of_day, member_casual;


-- ============================================================
-- 15. BIKE TYPE PREFERENCES
-- Purpose: Calculate bike-type share within each customer group.
-- ============================================================
SELECT
  member_casual,
  rideable_type,
  COUNT(*) AS total_rides,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (PARTITION BY member_casual),
    2
  ) AS percentage_within_group
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_rides DESC;


-- ============================================================
-- 16. AVERAGE RIDE DURATION BY DAY OF WEEK
-- Purpose: Compare daily average duration by customer type.
-- ============================================================
SELECT
  member_casual,
  FORMAT_DATE('%A', DATE(started_at)) AS day_of_week,
  EXTRACT(DAYOFWEEK FROM started_at) AS day_number,
  ROUND(AVG(TIMESTAMP_DIFF(ended_at, started_at, SECOND)) / 60, 2)
    AS avg_ride_minutes
FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
GROUP BY member_casual, day_of_week, day_number
ORDER BY day_number, member_casual;


-- ============================================================
-- 17. TOP 10 START STATIONS BY CUSTOMER TYPE
-- Purpose: Rank the most frequently used start stations for
-- members and casual riders separately.
-- ============================================================
WITH station_rides AS (
  SELECT
    member_casual,
    start_station_name,
    COUNT(*) AS total_rides
  FROM `cyclistic-case-study-505413.cyclisticdata.cyclistic_final`
  WHERE start_station_name IS NOT NULL
  GROUP BY member_casual, start_station_name
),
ranked_stations AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY member_casual
      ORDER BY total_rides DESC
    ) AS station_rank
  FROM station_rides
)
SELECT
  member_casual,
  station_rank,
  start_station_name,
  total_rides
FROM ranked_stations
WHERE station_rank <= 10
ORDER BY member_casual, station_rank;
