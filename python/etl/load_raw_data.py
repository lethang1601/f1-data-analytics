import pandas as pd
from sqlalchemy import create_engine,text
from pathlib import Path
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def create_db_engine():
    connection_string = (
        "postgresql+psycopg2://"
        "f1admin:"
        "f1password@"
        "localhost:"
        "5433/"
        "f1db"
    )
    engine = create_engine(connection_string)
    logger.info("Kết nối PostgreSQL thành công!")
    return engine

def load_csv_to_postgres(file_path, table_name, engine):
    logger.info(f"Đang load: {table_name}...")
    df = pd.read_csv(file_path)
    logger.info(f"  → Đọc được {len(df):,} dòng, {len(df.columns)} cột")
    df.to_sql(
        name=table_name,
        con=engine,
        schema='raw',
        if_exists='replace',
        index=False
    )
    logger.info(f"  ✓ Load {table_name} thành công!")

def main():
    raw_data_path = Path(__file__).parent.parent.parent / 'data' / 'raw'

    csv_files = {
        'circuits.csv':               'circuits',
        'constructor_results.csv':    'constructor_results',
        'constructor_standings.csv':  'constructor_standings',
        'constructors.csv':           'constructors',
        'driver_standings.csv':       'driver_standings',
        'drivers.csv':                'drivers',
        'lap_times.csv':              'lap_times',
        'pit_stops.csv':              'pit_stops',
        'qualifying.csv':             'qualifying',
        'races.csv':                  'races',
        'results.csv':                'results',
        'seasons.csv':                'seasons',
        'sprint_results.csv':         'sprint_results',
        'status.csv':                 'status'
    }

    engine = create_db_engine()

    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))
        conn.commit()
    
    success = 0
    failed = 0

    for filename, table_name in csv_files.items():
        file_path = raw_data_path / filename
        if file_path.exists():
            load_csv_to_postgres(file_path, table_name, engine)
            success += 1
        else:
            logger.warning(f"Không tìm thấy file: {filename}")
            failed += 1
    
    logger.info(f"✓ Thành công: {success} bảng")
    logger.info(f"✗ Thất bại:   {failed} bảng")

if __name__ == "__main__":
    main()