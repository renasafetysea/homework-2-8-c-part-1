CREATE TYPE station_status AS ENUM ('active', 'closed', 'moved', 'ACL only');

CREATE TABLE IF NOT EXISTS public.stations
(
  lat FLOAT,
  loc VARCHAR,
  lon FLOAT,
  name VARCHAR,
  station_id smallint PRIMARY KEY,
  status station_status
);

COPY public.stations
FROM '/docker-entrypoint-initdb.d/austin_bikeshare_stations.csv'
CSV HEADER;

ALTER TABLE public.stations DROP COLUMN lat, DROP COLUMN loc, DROP COLUMN lon;

-- Некоторые целочисленные поля сохранены как float.
-- Нужна временная таблица для преобразования типов.
CREATE TABLE IF NOT EXISTS public.trips_etl
(
  bikeid float,
  checkout_time time,
  duration_minutes smallint,
  end_station_id float,
  end_station_name VARCHAR,
  month float,
  start_station_id float,
  start_station_name VARCHAR,
  start_time timestamp,
  subscriber_type VARCHAR,
  trip_id bigint,
  year float
);

COPY public.trips_etl
FROM '/docker-entrypoint-initdb.d/austin_bikeshare_trips.csv'
CSV HEADER;

CREATE TABLE IF NOT EXISTS public.trips
(
  --bikeid smallint,
  --checkout_time time,
  duration_minutes smallint,
  end_station_id smallint,
  --end_station_name VARCHAR,
  --month smallint,
  start_station_id smallint,
  --start_station_name VARCHAR,
  --start_time timestamp,
  --subscriber_type VARCHAR,
  trip_id bigint,
  year smallint
);

INSERT INTO public.trips
SELECT
--  ROUND(bikeid),
--  checkout_time,
  duration_minutes,
  ROUND(end_station_id),
--  end_station_name VARCHAR,
--  ROUND(month),
  ROUND(start_station_id),
--  start_station_name,
--  start_time,
--  subscriber_type,
  trip_id,
  ROUND(year)
FROM public.trips_etl;

DROP TABLE public.trips_etl;