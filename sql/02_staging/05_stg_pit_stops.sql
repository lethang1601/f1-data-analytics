CREATE TABLE staging.pit_stops AS 
SELECT
    "raceId",
    "driverId",
    stop,
    lap,
    time,
    duration,
    milliseconds,
    CASE
        WHEN milliseconds < 25000 THEN 'Fast'
        WHEN milliseconds < 35000 THEN 'Normal'
        ELSE 'Slow'
    END AS stop_category
FROM raw.pit_stops;

CREATE INDEX idx_stg_pit_stops_raceid ON staging.pit_stops("raceId");
CREATE INDEX idx_stg_pit_stops_driverid ON staging.pit_stops("driverId");