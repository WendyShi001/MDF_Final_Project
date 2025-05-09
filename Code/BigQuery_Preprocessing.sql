-- ============================================================================
-- Create a fully-dense hourly panel for ALL Manhattan zones between
-- 2024-08-01 00:00 and 2025-01-31 23:00, with holiday & calendar features
-- ============================================================================

CREATE OR REPLACE TABLE
  `caramel-source-455904-v8.Taxi_Data.trips_manhattan_hourly` AS

-- ---------------------------------------------------------------------------
-- 1) CTE: list of Manhattan zone IDs
-- ---------------------------------------------------------------------------
WITH manh_zones AS (
  SELECT LocationID
  FROM   `caramel-source-455904-v8.Taxi_Data.geo`
  WHERE  borough = 'Manhattan'
),

-- ---------------------------------------------------------------------------
-- 2) CTE: every single hour in the study window
-- ---------------------------------------------------------------------------
hours AS (
  SELECT ts
  FROM UNNEST(
        GENERATE_TIMESTAMP_ARRAY(
          '2024-08-01 00:00:00',
          '2025-01-31 23:00:00',
          INTERVAL 1 HOUR
        )
       ) AS ts
),

-- ---------------------------------------------------------------------------
-- 3) Cartesian product  ➜  full grid  (zone × hour)
-- ---------------------------------------------------------------------------
grid AS (
  SELECT
    z.LocationID       AS PULocationID,
    h.ts               AS pickup_hour
  FROM manh_zones z
  CROSS JOIN hours h
),

-- ---------------------------------------------------------------------------
-- 4) Aggregate real trips to hour level for Manhattan zones
-- ---------------------------------------------------------------------------
agg AS (
  SELECT
    PULocationID,
    TIMESTAMP_TRUNC(tpep_pickup_datetime, HOUR) AS pickup_hour,
    COUNT(*) AS trip_count
  FROM `caramel-source-455904-v8.Taxi_Data.1`
  WHERE PULocationID IN (SELECT LocationID FROM manh_zones)
    AND tpep_pickup_datetime BETWEEN '2024-08-01' AND '2025-01-31 23:59:59'
  GROUP BY 1, 2
),

-- ---------------------------------------------------------------------------
-- 5) Hard-coded list of U.S. federal holidays for 2024 & 2025
--    (add / remove as needed)
-- ---------------------------------------------------------------------------
holidays AS (
  SELECT DATE '2024-01-01'  AS holiday_date UNION ALL
  SELECT DATE '2024-01-15'  UNION ALL  -- MLK
  SELECT DATE '2024-02-19'  UNION ALL  -- Presidents
  SELECT DATE '2024-05-27'  UNION ALL  -- Memorial
  SELECT DATE '2024-06-19'  UNION ALL  -- Juneteenth
  SELECT DATE '2024-07-04'  UNION ALL
  SELECT DATE '2024-09-02'  UNION ALL
  SELECT DATE '2024-10-14'  UNION ALL
  SELECT DATE '2024-11-11'  UNION ALL
  SELECT DATE '2024-11-28'  UNION ALL
  SELECT DATE '2024-12-25'  UNION ALL
  SELECT DATE '2025-01-01'  UNION ALL
  SELECT DATE '2025-01-20'  UNION ALL
  SELECT DATE '2025-02-17'  UNION ALL
  SELECT DATE '2025-05-26'  UNION ALL
  SELECT DATE '2025-06-19'  UNION ALL
  SELECT DATE '2025-07-04'  UNION ALL
  SELECT DATE '2025-09-01'  UNION ALL
  SELECT DATE '2025-10-13'  UNION ALL
  SELECT DATE '2025-11-11'  UNION ALL
  SELECT DATE '2025-11-27'  UNION ALL
  SELECT DATE '2025-12-25'
)

-- ---------------------------------------------------------------------------
-- 6) Final SELECT: join grid ⇢ counts, add calendar features
-- ---------------------------------------------------------------------------
SELECT
  g.PULocationID,
  g.pickup_hour,
  IFNULL(a.trip_count, 0)                                 AS trip_count,

  -- Holiday flag
  CASE
    WHEN DATE(g.pickup_hour) IN (SELECT holiday_date FROM holidays) THEN 1
    ELSE 0
  END                                                     AS is_holiday,

  -- Hour of day
  EXTRACT(HOUR FROM g.pickup_hour)                        AS hour,

  -- Convert BigQuery 1=Sun..7=Sat  ➜ Python 0=Mon..6=Sun
  MOD(EXTRACT(DAYOFWEEK FROM g.pickup_hour) + 5, 7)       AS dayofweek,

  -- Weekend flag (Sat = 5, Sun = 6 in Python numbering)
  CASE
    WHEN MOD(EXTRACT(DAYOFWEEK FROM g.pickup_hour) + 5, 7) IN (5,6) THEN 1
    ELSE 0
  END                                                     AS is_weekend
FROM grid g
LEFT JOIN agg a
USING (PULocationID, pickup_hour)
ORDER BY PULocationID, pickup_hour;   -- ----------------------------------------------------------------------


-- Create a feature table with lag and rolling stats
-- ----------------------------------------------------------------------
CREATE OR REPLACE TABLE
  `caramel-source-455904-v8.Taxi_Data.trips_manhattan_lagged` AS
SELECT
  *,
  -- ──────────────────────────────────────────────────────────────
  -- Lag features (fill NULL with 0, like .fillna(0) in pandas)
  -- ──────────────────────────────────────────────────────────────
  IFNULL(LAG(trip_count,  1) OVER w, 0)  AS lag_1h,
  IFNULL(LAG(trip_count, 24) OVER w, 0)  AS lag_24h,
  IFNULL(LAG(trip_count,168) OVER w, 0)  AS lag_1w,

  -- ──────────────────────────────────────────────────────────────
  -- Rolling 3-hour mean *of the previous 3 hours* (shifted by 1)
  -- pandas logic: mean(i-3 … i-1)
  -- ──────────────────────────────────────────────────────────────
  IFNULL(
    AVG(trip_count) OVER (
        PARTITION BY PULocationID
        ORDER BY pickup_hour
        ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ), 0) AS rolling_avg_3h
FROM `caramel-source-455904-v8.Taxi_Data.trips_manhattan_hourly`
WINDOW w AS (
  PARTITION BY PULocationID
  ORDER BY pickup_hour
);


-- -----------------------------------------------------------------------------
-- Use scripting to AUTO-GENERATE a SELECT with zone_### dummy columns
-- -----------------------------------------------------------------------------
DECLARE zone_array ARRAY<INT64>;

-- 1) Collect all Manhattan zone IDs sorted asc
SET zone_array = (
  SELECT ARRAY_AGG(DISTINCT PULocationID ORDER BY PULocationID)
  FROM `caramel-source-455904-v8.Taxi_Data.trips_manhattan_lagged`
);

-- 2) Build dynamic SELECT that drops the first zone (like drop_first=True)
EXECUTE IMMEDIATE (
  SELECT '''
    CREATE OR REPLACE TABLE
      `caramel-source-455904-v8.Taxi_Data.trips_manhattan_final` AS
    SELECT
      t.*,
''' || STRING_AGG(
        FORMAT(
          '      IF(t.PULocationID = %d, 1, 0) AS zone_%d',
          zone_id, zone_id
        ),
        ',\n'
        -- drop the very first element (index 0)
      ) || '''
    FROM `caramel-source-455904-v8.Taxi_Data.trips_manhattan_lagged` AS t;
  '''
  FROM UNNEST(zone_array) AS zone_id WITH OFFSET pos
  WHERE pos > 0             
);



