import os
import psycopg2
from dotenv import load_dotenv

# 1. Load environment variables from .env
load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")

print("==========================================================================")
print("             CONNECTING TO AWS RDS POSTGRESQL DATABASE                    ")
print("==========================================================================")
print(f"Connecting to Host: {DB_HOST}")
print(f"Database Name:      {DB_NAME}")
print(f"User:               {DB_USER}")

try:
    # 2. Establish connection to AWS RDS
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=10,
        sslmode="prefer"
    )
    conn.autocommit = True
    cursor = conn.cursor()
    print("✅ Connection to AWS RDS PostgreSQL successful!\n")

    # 3. Read the SQL schema file
    schema_path = os.path.join(os.path.dirname(__file__), "schema.sql")
    with open(schema_path, "r") as file:
        schema_sql = file.read()

    print("Executing table partitioning schema...")
    cursor.execute(schema_sql)
    print("✅ Partitioning schema executed successfully!\n")

    # 4. Verify created partition tables in the cloud
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name LIKE 'air_quality_%'
        ORDER BY table_name;
    """)
    tables = cursor.fetchall()

    print("=== CONFIRMED TABLES & PARTITIONS IN AWS RDS ===")
    for idx, (tbl,) in enumerate(tables, 1):
        print(f"  {idx}. {tbl}")

    cursor.close()
    conn.close()
    print("\n==========================================================================")
    print("✅ PHASE 1 & 2 COMPLETE: Cloud Database & Partitions Ready!")
    print("==========================================================================")

except Exception as e:
    print(f"\n❌ CONNECTION / EXECUTION FAILED:")
    print(e)
    print("\nTroubleshooting tips:")
    print("1. Did you set 'Public Access: Yes' on AWS RDS?")
    print("2. In your AWS Security Group, did you add an Inbound Rule for Port 5432 (0.0.0.0/0)?")
    print("3. Check that DB_HOST, DB_NAME, and DB_PASSWORD in your .env are exact.")