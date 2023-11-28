WITH trips_ended AS(
SELECT
  tr."year",
  tr.end_station_id,
  COUNT (DISTINCT tr.trip_id) AS trip_count,
  AVG(tr.duration_minutes) AS avg_dur_ended
FROM public.trips AS tr
WHERE tr."year" IS NOT NULL AND tr.end_station_id IS NOT NULL
GROUP BY tr."year", tr.end_station_id
ORDER BY tr."year", tr.end_station_id),

trips_started AS(
SELECT
  tr."year",
  tr.start_station_id,
  COUNT (DISTINCT tr.trip_id) AS trip_count,
  AVG(tr.duration_minutes) AS avg_dur_started
FROM public.trips AS tr
WHERE tr."year" IS NOT NULL AND tr.start_station_id IS NOT NULL
GROUP BY tr."year", tr.start_station_id
ORDER BY tr."year", tr.start_station_id),

round_trips AS(
SELECT
  tr."year",
  tr.start_station_id AS station_id,
  COUNT (DISTINCT tr.trip_id)  AS trip_count
FROM public.trips AS tr
WHERE tr.start_station_id = tr.end_station_id
GROUP BY tr."year", tr.start_station_id
ORDER BY tr."year", tr.start_station_id)

SELECT
  te."year",
  te.end_station_id,
  te.trip_count AS trips_ended,
  ts.trip_count AS trips_started,
  te.trip_count + ts.trip_count - COALESCE(rt.trip_count, 0) AS trips_total,
  ROUND(ts.avg_dur_started) AS avg_dur_started,
  ROUND(te.avg_dur_ended) AS avg_dur_ended
FROM trips_ended AS te
FULL JOIN trips_started AS ts
  ON te."year" = ts."year" 
  AND te.end_station_id = ts.start_station_id
LEFT JOIN round_trips AS rt
  ON rt."year" = ts."year" 
  AND rt.station_id = ts.start_station_id
JOIN public.stations AS st
  ON te.end_station_id = st.station_id
WHERE st.status = 'active'
ORDER BY te."year", avg_dur_started DESC