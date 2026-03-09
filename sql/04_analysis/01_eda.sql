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
SELECT MIN(year) AS nam_dau_tien,
    MAX(year) AS nam_cuoi_cung,
    COUNT(DISTINCT year) AS tong_so_mua_giai,
    COUNT(*) AS tong_so_chang
FROM raw.races;

-- ===================================
-- KIỂM TRA GIÁ TRỊ BỊ THIẾU (NULL)
-- ===================================
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE "positionOrder" IS NULL) AS thieu_vi_tri,
    COUNT(*) FILTER (WHERE points IS NULL) AS thieu_diem,
    COUNT(*) FILTER (WHERE grid IS NULL) AS thieu_gird,
    COUNT(*) FILTER (WHERE milliseconds IS NULL) AS thieu_thoi_gian
FROM raw.results;

-- Kiểm tra bảng drivers
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE dob IS NULL) AS thieu_ngay_sinh,
    COUNT(*) FILTER (WHERE nationality IS NULL) AS thieu_quoc_tich
FROM raw.drivers;

-- ===================================
-- KIỂM TRA GIÁ TRỊ "\N" (NULL GIẢ)
-- ===================================

SELECT
    COUNT(*) FILTER (WHERE time = '\N') AS thoi_gian_null_gia,
    COUNT(*) FILTER (WHERE "fastestLap" = '\N') AS fastest_lap_null_gia,
    COUNT(*) FILTER (WHERE "fastestLapTime" = '\N') AS fastest_lap_time_null_gia,
    COUNT(*) FILTER (WHERE "fastestLapSpeed" = '\N') AS fastest_lap_speed_null_gia
FROM raw.results;

-- Kiểm tra bảng races
SELECT
    COUNT(*) FILTER (WHERE time = '\N') AS gio_race_null_gia,
    COUNT(*) FILTER (WHERE url = '\N') AS url_null_gia
FROM raw.races;

-- Kiểm tra bảng lap_times
-- (bảng lớn nhất, quan trọng nhất)
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE time = '\N') AS time_null_gia,
    COUNT(*) FILTER (WHERE milliseconds IS NULL) AS milliseconds_null_gia
FROM raw.lap_times;

