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

    engine = create_db_engine()

    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))
        conn.commit()
    
    success = 0
    failed = 0

    csv_files = raw_data_path.glob('*.csv')

    for file_path in csv_files:
        try:
            table_name = file_path.stem
            load_csv_to_postgres(file_path, table_name, engine)
            success += 1
        except Exception as e:
            failed += 1
            logger.error(f'Lỗi khi load {file_path.stem}: {e}')
    logger.info(f"✓ Thành công: {success} bảng")
    logger.info(f"✗ Thất bại:   {failed} bảng")

if __name__ == "__main__":
    main()