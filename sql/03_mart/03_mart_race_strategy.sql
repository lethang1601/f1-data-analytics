CREATE TABLE mart.race_strategy AS

-- Tổng hợp pit stop của mỗi tay đua thành 1 dòng duy nhất, vì mỗi tay đua có thẻ pit nhiều lần trong 1 race, cần gộp lại để so sánh kết quả cuối
WITH pit_summary AS(
    SELECT
        "raceId",
        "driverId",
        COUNT(*) AS pit_stop_count,
        SUM(milliseconds) AS total_pit_time_ms,
        MIN(lap) AS first_pit_lap,
        MAX(lap) AS last_pit_lap,

        -- Tính thời gian pit trung bình cho mỗi lần pit stop để đo hiệu quả của Pit crew. Pit creaw nhanh = mất ít thời gian hơn so với đối thủ
        ROUND(AVG(milliseconds)::numeric, 0) AS avg_pit_time_ms,

        -- Tính Pit stop nhanh nhất trong race để phản ánh tốc độ Pit stop tối đa của Pit crew
        MIN(milliseconds) AS fastest_pit_ms
    FROM staging.pit_stops
    GROUP BY
        "raceId",
        "driverId"
)
SELECT
    -- Thông tin nhận diện race
    r."raceId",
    r."driverId",
    r."constructorId",
    rc.year,
    rc.name AS race_name,
    rc.era,

    -- Kết quả Race
    r.grid AS grd_position,
    r."positionOrder" AS finish_position,
    r.grid_change,
    r.points,

    -- Thông tin từ pit_summary
    COALESCE(ps.pit_stop_count, 0) AS pit_stop_count,
    COALESCE(ps.total_pit_time_ms, 0) AS total_pit_time_ms,
    ps.first_pit_lap,
    ps.avg_pit_time_ms,

    -- Phân loại Strategy vì có nhiều Strategy về Pit stop: 1 Stop, 2 Stop,...
    CASE
        WHEN COALESCE(ps.pit_stop_count, 0) = 0 THEN 'No Stop'
        WHEN ps.pit_stop_count = 1 THEN 'One Stop'
        WHEN ps.pit_stop_count = 2 THEN 'Two Stop'
        WHEN ps.pit_stop_count = 3 THEN 'Three Stop'
        ELSE 'FOUR Stop+'
    END AS strategy_type,

    -- Timming của pit đầu tiên xảy ra sớm hay muộn
    -- Undercut (pit sớm hơn đối thủ) là một trong những chiến thuật pit stop phổ biến nhất F1
    -- Pit 20 lap đầu = aggressive/undercut strategy
    CASE
        WHEN ps.first_pit_lap IS NULL THEN 'No Stop'
        WHEN ps.first_pit_lap <= 20 THEN 'Early Stop'
        WHEN ps.first_pit_lap <= 40 THEN 'Mid Stop'
        ELSE 'Late Stop'
    END AS pit_timing
FROM staging.results r 
JOIN staging.races rc ON r."raceId" = rc."raceId"

-- Các race trước 2011 không có dữ liệu pit stop nên dùng LEFT JOIN để giữ lại tất cả, chỗ nào không có pit data thì NULL
-- Nếu dùng INNER JOIN toàn bộ data race trước 2011 sẽ biến mất
LEFT JOIN pit_summary ps ON r."raceId" = ps."raceId" AND r."driverId" = ps."driverId";

CREATE INDEX idx_mart_strategy_raceid ON mart.race_strategy("raceId");
CREATE INDEX idx_mart_strategy_driverid ON mart.race_strategy("driverId");
CREATE INDEX idx_mart_strategy_type ON mart.race_strategy(strategy_type);

SELECT
    strategy_type,
    COUNT(*) AS total_cases,
    ROUND(AVG(finish_position)::numeric, 2) AS avg_finish_position,
    ROUND(AVG(grid_change)::numeric, 2) AS avg_grid_change,
    ROUND(AVG(points)::numeric, 2) AS avg_points
FROM mart.race_strategy
WHERE pit_stop_count > 0
GROUP BY strategy_type
ORDER BY avg_finish_position ASC;