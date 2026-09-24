-- ============================================================================
-- PROJECT: The Niger Delta Environmental Big Data Audit
-- PURPOSE: Declarative Table Partitioning by List (Rivers State LGAs)
-- ============================================================================

-- 1. Clean Slate: Drop Master table if rebuilding
DROP TABLE IF EXISTS air_quality_master_stream CASCADE;

-- 2. CREATE MASTER PARENT TABLE
-- IN POSTGRESQL, Partition key must be the primary key
CREATE TABLE air_quality_master_stream (
    reading_id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    lga VARCHAR(50) NOT NULL,
    sensor_id VARCHAR(50) NOT NULL,
    pm2_5  NUMERIC(6, 2),
    pm10   NUMERIC(6, 2),
    dust   NUMERIC(6, 2),
    aerosol_optical_depth  NUMERIC(5, 3),
    carbon_monoxide      NUMERIC(7, 2),
    nitrogen_dioxide        NUMERIC(6, 2),
    sulphur_dioxide         NUMERIC(6, 2),
    ozone                   NUMERIC(6, 2),
    uv_index                NUMERIC(4, 2),
    us_aqi                  NUMERIC(6, 2),
    european_aqi            NUMERIC(6, 2),
    season                  VARCHAR(25),
    aqi_category            VARCHAR(35),
 -- Composite Primary Key: reading_id + partition key
    PRIMARY KEY (reading_id, lga)
)
PARTITION BY LIST (lga);


-- ============================================================================
-- 3. CREATE INDEPENDENT PHYSICAL CHILD PARTITIONS
-- Each partition physically stores its own data blocks on the cloud SSD.
-- ============================================================================
-- Partition 1: Eleme (Petrochemical & Heavy Refinery Hub)

CREATE TABLE air_quality_stream_eleme
    PARTITION OF air_quality_master_stream
    FOR VALUES IN ('Eleme');


-- Partition 2: Port Harcourt City (Urban Commercial Core)
CREATE TABLE air_quality_stream_phc
    PARTITION OF air_quality_master_stream
    FOR VALUES IN ('Port-Harcourt');


-- Partition 3: Obio-Akpor (Dense Residential & Commercial Corridor)
CREATE TABLE air_quality_stream_obio_akpor
    PARTITION OF air_quality_master_stream
    FOR VALUES IN ('Obio-Akpor');

-- Partition 4: Bonny Island (LNG Terminal & Coastal Maritime)
CREATE TABLE air_quality_stream_bonny
    PARTITION OF air_quality_master_stream
    FOR VALUES IN ('Bonny');


-- Partition 5: Default Partition (Resilience Fail-Safe)
-- Catches any unexpected LGA stream so high-velocity ingestion NEVER crashes.
CREATE TABLE air_quality_stream_default
    PARTITION OF air_quality_master_stream
    DEFAULT;


-- ============================================================================
-- 4. HIGH-PERFORMANCE TIME-SERIES INDEXES
-- PostgreSQL automatically applies these indexes to each child partition!
-- ============================================================================
-- Fast ordering for real-time dashboard telemetry
CREATE INDEX idx_stream_timestamp 
    ON air_quality_master_stream (timestamp DESC);


-- Fast filtered analytics by location and time
CREATE INDEX idx_stream_lga_time 
    ON air_quality_master_stream (lga, timestamp DESC);


-- Fast lookup for soot & pollution alert thresholds
CREATE INDEX idx_stream_aqi_alerts 
    ON air_quality_master_stream (us_aqi DESC);

