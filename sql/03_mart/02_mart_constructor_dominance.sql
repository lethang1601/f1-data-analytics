CREATE TABLE mart.constructor_dominance AS 

-- Tính tổng điểm của tất cả team trong mỗi mùa để tính % thị phần số điểm của từng team
WITH season_totals AS(
    SELECT
        rc.year,
        SUM(r.points) AS total_points_ca_mua
    FROM staging.results r
    JOIN staging.races rc ON r."raceId" = rc."raceId"
    GROUP BY rc.year
)
SELECT
    -- Thông tin cơ bản
    c."constructorId",
    c.name AS team_name,
    c.nationality AS team_nationality,
    rc.year,
    rc.era,

    -- Thống kê trong mùa giải 
    COUNT(DISTINCT r."raceId") AS races_entered,
    SUM(r.points) AS total_points,
    COUNT(DISTINCT CASE WHEN r."positionOrder" = 1 THEN r."raceId" END) AS total_wins,
    COUNT(DISTINCT CASE WHEN r."positionOrder" <= 3 THEN r."raceId" END) AS total_podiums,

    -- Vị trí trung bình trong mùa
    ROUND(AVG(r."positionOrder"), 2) AS avg_finish_position,

    -- Chỉ số thị phần điểm số là thước đo của sự thống trị. Số này càng cao = team đó càng thống trị mùa giải
    ROUND((SUM(r.points) * 100.0 / NULLIF(st.total_points_ca_mua, 0))::numeric, 2) AS points_share_pct,

    -- Số tay đua thi đấu cho team trong mùa đó
    COUNT(DISTINCT r."driverId") AS drivers_count
FROM staging.results r 
JOIN staging.races rc ON r."raceId" = rc."raceId"
JOIN raw.constructors c ON r."constructorId" = c."constructorId"
JOIN season_totals st ON rc.year = st.year
GROUP BY
    c."constructorId",
    c.name,
    c.nationality,
    rc.year,
    rc.era,
    st.total_points_ca_mua;

CREATE INDEX idx_mart_constructor_year ON mart.constructor_dominance(year);
CREATE INDEX idx_mart_constructor_id ON mart.constructor_dominance("constructorId");

-- Chạy kết quả để xem team nào thống trị F1 theo từng giai đoạn
SELECT
    team_name,
    team_nationality,
    year,
    era,
    total_points,
    total_wins,
    points_share_pct
FROM mart.constructor_dominance
WHERE total_wins >= 10
ORDER BY points_share_pct DESC
LIMIT 15;