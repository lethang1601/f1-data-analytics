CREATE TABLE staging.results AS
SELECT
    "resultId",
    "raceId",
    "driverId",
    "constructorId",
    "number",
    grid,
    "positionOrder",
    points,
    laps,
    NULLIF(time, '\N') AS time,
    NULLIF(milliseconds, '\N')::bigint AS milliseconds,
    NULLIF("fastestLap", '\N')::integer AS "fastestLap",
    NULLIF("fastestLapTime", '\N') AS "fastestLapTime",
    NULLIF("fastestLapSpeed", '\N')::numeric AS "fastestLapSpeed",
    "statusId",
    grid - "positionOrder" AS grid_change -- Chỉ số đô khả năng lội ngược dòng của tay đua
FROM raw.results;

CREATE INDEX idx_stg_results_driverid ON staging.results("driverId");
CREATE INDEX idx_stg_results_raceid ON staging.results("raceId");
CREATE INDEX idx_stg_results_constructorid ON staging.results("constructorId");

-- Kiểm tra \N đã được xử lý chưa
SELECT
    COUNT(*) AS tong_dong,
    COUNT(*) FILTER (WHERE "fastestLapSpeed" IS NULL) AS fastest_speed_null,
    COUNT(*) FILTER (WHERE grid_change > 0) AS improved_position,
    COUNT(*) FILTER (WHERE grid_change < 0 ) AS lost_position,
    ROUND(AVG("fastestLapSpeed"), 2) AS avg_fastest_speed
FROM staging.results;