CREATE TABLE staging.drivers AS
SELECT
    "driverId",
    "driverRef",
    number,
    code,
    forename,
    surname,
    dob::date AS dob,
    nationality,
    url,
    forename || ' ' || surname AS full_name,
    EXTRACT(YEAR FROM dob::date)::integer AS birth_year -- Tính tuổi của tay đua tại thời điểm race
FROM raw.drivers;

CREATE INDEX idx_stg_drivers_driverID ON staging.drivers("driverId");
CREATE INDEX idx_stg_drivers_nationality ON staging.drivers(nationality);
