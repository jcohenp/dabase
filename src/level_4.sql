DROP FUNCTION IF EXISTS add_journey(VARCHAR(128), TIMESTAMP, TIMESTAMP, INT, INT);

CREATE OR REPLACE FUNCTION add_journey(email VARCHAR(128), time_start TIMESTAMP, time_end TIMESTAMP, station_start INT, station_end INT)
RETURNS BOOLEAN AS
$$
DECLARE
station_start_ INT := (SELECT id_station FROM station WHERE id_station = add_journey.station_start);
station_end_ INT := (SELECT id_station FROM station WHERE id_station = add_journey.station_end);
BEGIN
PERFORM * FROM journey WHERE journey.time_start = add_journey.time_start
                          OR journey.time_end = add_journey.time_end;
IF (FOUND = true) THEN
  RETURN false;
END IF;
PERFORM * FROM person WHERE person.email = add_journey.email;
IF (FOUND = true) THEN
  PERFORM * from station WHERE 
            add_journey.station_start = station_start_ 
            AND add_journey.station_end = station_end_ 
            AND add_journey.station_start != add_journey.station_end 
            AND add_journey.time_start < add_journey.time_end
            AND add_journey.time_end - add_journey.time_start < interval '24 hours';
  IF (FOUND = true) THEN
    INSERT INTO journey
    VALUES(DEFAULT, add_journey.time_start, add_journey.time_end, add_journey.station_start, add_journey.station_end, add_journey.email);
    RETURN true;
  END IF;
END IF;
RETURN false;
END;
$$ language plpgsql;
