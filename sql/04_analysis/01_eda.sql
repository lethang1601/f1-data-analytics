-- ===================================
-- TỔNG QUAN SỐ LƯỢNG DỮ LIỆU
-- ===================================

SELECT 'races' AS table_name, COUNT(*) AS total_rows FROM raw.races
UNION ALL
SELECT 'drivers', COUNT(*) FROM raw.drivers
UNION ALL
SELECT 'constructors',COUNT(*) FROM raw.constructors
UNION ALL
SELECT 'results', COUNT(*) FROM raw.results
UNION ALL
SELECT 'lap_times',COUNT(*) FROM raw.lap_times
UNION ALL
SELECT 'pit_stops',COUNT(*) FROM raw.pit_stops
UNION ALL
SELECT 'qualifying',COUNT(*) FROM raw.qualifying
UNION ALL
SELECT 'circuits', COUNT(*) FROM raw.circuits
UNION ALL
SELECT 'driver_standings', COUNT(*) FROM raw.driver_standings
UNION ALL
SELECT 'constructor_standings',COUNT(*) FROM raw.constructor_standings
ORDER BY total_rows DESC;

-- ===================================
-- KHOẢNG THỜI GIAN DỮ LIỆU
-- ===================================
SELECT MIN(year) AS first_year,
    MAX(year) AS last_year,
    COUNT(DISTINCT year) AS total_seasons,
    COUNT(*) AS total_races
FROM raw.races;

-- ===================================
-- KIỂM TRA GIÁ TRỊ BỊ THIẾU (NULL)
-- ===================================
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE "positionOrder" IS NULL) AS missing_position,
    COUNT(*) FILTER (WHERE points IS NULL) AS missing_points,
    COUNT(*) FILTER (WHERE grid IS NULL) AS missing_grid,
    COUNT(*) FILTER (WHERE milliseconds IS NULL) AS missing_time_ms
FROM raw.results;

-- Kiểm tra bảng drivers
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE dob IS NULL) AS missing_dob,
    COUNT(*) FILTER (WHERE nationality IS NULL) AS missing_nationality
FROM raw.drivers;

-- ===================================
-- KIỂM TRA GIÁ TRỊ "\N" (NULL GIẢ)
-- ===================================

SELECT
    COUNT(*) FILTER (WHERE time = '\N') AS fake_null_time,
    COUNT(*) FILTER (WHERE "fastestLap" = '\N') AS fake_null_fastest_lap,
    COUNT(*) FILTER (WHERE "fastestLapTime" = '\N') AS fake_null_fastest_lap_time,
    COUNT(*) FILTER (WHERE "fastestLapSpeed" = '\N') AS fake_null_fastest_lap_speed
FROM raw.results;

-- Kiểm tra bảng races
SELECT
    COUNT(*) FILTER (WHERE time = '\N') AS fake_null_time,
    COUNT(*) FILTER (WHERE url = '\N') AS fake_null_url
FROM raw.races;

-- Kiểm tra bảng lap_times
-- (bảng lớn nhất, quan trọng nhất)
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE time = '\N') AS fake_null_time,
    COUNT(*) FILTER (WHERE milliseconds IS NULL) AS missing_milliseconds
FROM raw.lap_times;

-- Check dữ liệu của từng cột của bất kì bảng, thay giá trị muốn tìm kiếm vào
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
AND table_name IN ('results', 'races', 'lap_times', 'drivers')
ORDER BY table_name, ordinal_position;