CREATE TABLE mart.driver_performance AS 
SELECT
    -- Thông tin cơ bản của tay đua
    d."driverId",
    d.full_name,
    d.nationality,
    d.birth_year,
    
    -- Thống kê tổng quan sự nghiệp bằng những con số đầu tiên khi mọi người nghĩ đến 1 tay đua
    COUNT(DISTINCT r."raceId") AS total_races,
    COUNT(DISTINCT CASE WHEN r."positionOrder" = 1 THEN r."raceId" END) AS total_wins,
    COUNT(DISTINCT CASE WHEN r."positionOrder" <= 3 THEN r."raceId" END) AS total_podiums,
    COUNT(DISTINCT CASE WHEN r."positionOrder" <= 10 THEN r."raceId" END) AS total_top10,
    SUM(r.points) AS total_points,

    -- Tính tỷ lệ phần trăm để tạo công bằng khi so sánh với các tay đua vì mỗi tay đua tham gia số race khác nhau
    ROUND(COUNT(DISTINCT CASE WHEN r."positionOrder" = 1 THEN r."raceId" END) * 100.0 / NULLIF(COUNT(DISTINCT r."raceId"), 0), 2) AS win_rate,
    
    ROUND(COUNT(DISTINCT CASE WHEN r."positionOrder" <= 3 THEN r."raceId" END) * 100.0 / NULLIF(COUNT(DISTINCT r."raceId"), 0), 2) AS podium_rate,

    -- Tính chỉ số nhất quán bởi vì 1 tay đua giỏi không chỉ thắng nhiều mà cần sự ổn định (ít khi về cuối)
    -- avg_finish_position thấp = về đích thứ hạng cao 
    ROUND(AVG(r."positionOrder"), 2) AS avg_finish_position,
    ROUND(AVG(r.grid), 2) AS avg_grid_position,

    -- Tính chỉ số lội ngược dòng đo khả năng Overtake và Race Raft
    ROUND(AVG(r.grid_change), 2) AS avg_grid_change,

    -- Tốc độ tối đa, bởi vì Fastes Lap phản ánh tốc độ thuần túy của tay đua khi ít hoặc không gặp traffic trên đường đua
    ROUND(AVG(r."fastestLapSpeed"), 2) AS avg_fastest_lap_speed,
    ROUND(MAX(r."fastestLapSpeed"), 2) AS max_fastest_lap_speed,

    -- Tỷ lệ hoàn thành race cho biết thấy độ tin cậy của tay đua và tránh bị tai nạn 
    -- Tay đua nhiều DNF = kém ổn định dù có thể rất nhanh
    ROUND(
        COUNT(DISTINCT CASE WHEN r."positionOrder" <= 20 THEN r."raceId" END) * 100.0
        / NULLIF(COUNT(DISTINCT r."raceId"), 0)
    , 2) AS finish_rate,

    -- Khoảng thời gian hoạt động
    MIN(rc.year) AS first_year,
    MAX(rc.year) AS last_year,
    MAX(rc.year) - MIN(rc.year) + 1 AS career_years
FROM staging.drivers d
JOIN staging.results r ON d."driverId" = r."driverId"
JOIN staging.races rc ON r."raceId" = rc. "raceId"
GROUP BY
    d."driverId",
    d.full_name,
    d.nationality,
    d.birth_year;

CREATE INDEX idx_mart_driver_perf_driverId ON mart.driver_performance("driverId");
CREATE INDEX idx_mart_driver_perf_nationality ON mart.driver_performance(nationality);

-- Top 10 tay đua nhiều chiến thắng nhất lịch sử F1
SELECT
    full_name,
    nationality,
    total_races,
    total_wins,
    total_podiums,
    win_rate,
    avg_finish_position,
    avg_grid_change,
    career_years
FROM mart.driver_performance
ORDER BY total_wins DESC
LIMIT 10;