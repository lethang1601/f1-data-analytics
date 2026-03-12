CREATE TABLE staging.lap_times AS 
SELECT
    "raceId",
    "driverId",
    lap,
    position,
    time,
    milliseconds,
    ROUND(milliseconds / 1000.0, 3) AS lap_time_seconds -- Chuyến milliseconds sang seconds cho dễ đọc
FROM raw.lap_times;

CREATE INDEX idx_stg_lap_times_raceid ON staging.lap_times("raceId");
CREATE INDEX idx_stg_lap_times_driverid ON staging.lap_times("driverId");