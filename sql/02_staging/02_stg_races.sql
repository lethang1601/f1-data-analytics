CREATE TABLE staging.races AS
SELECT
    "raceId",
    year,
    round,
    "circuitId",
    name,
    date::date as date,
    NULLIF(time, '\N') AS time,
    NULLIF(url, '\N') AS url,
    (FLOOR(year / 10) * 10)::integer AS decade, -- Phân tích theo từng thập kỉ
    
    -- F1 thay đổi luật kỹ thuật theo từng kỹ nguyên
    -- Mỗi kỷ nguyên xe được thiết kế với đặc điểm, công nghệ khác nhau nên chia theo từng kỷ nguyên
    CASE
        WHEN year BETWEEN 1950 AND 1979 THEN 'Early Era'
        WHEN year BETWEEN 1980 AND 1999 THEN 'Turbo & Slick Era'
        WHEN year BETWEEN 2000 AND 2013 THEN 'V10/V8 Era'
        WHEN year BETWEEN 2014 AND 2021 THEN 'Hybrid Era'
        WHEN year >= 2022 THEN 'Ground Effect Era'
    END AS era 
FROM raw.races;

CREATE INDEX idx_stg_races_year ON staging.races(year);
CREATE INDEX idx_stg_races_circuitid ON staging.races("circuitId");