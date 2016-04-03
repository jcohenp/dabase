CREATE OR REPLACE FUNCTION add_journey(email VARCHAR(128), time_start TIMESTAMP, time_end TIMESTAMP, station_start INT, station_end INT)
RETURNS BOOLEAN AS
$$
DECLARE
  time_start_ TIMESTAMP := (SELECT max(journey.time_start) FROM journey WHERE journey.email = add_journey.email);
  time_end_ TIMESTAMP := (SELECT max(journey.time_end) FROM journey WHERE journey.email = add_journey.email);
BEGIN
PERFORM * FROM person WHERE person.email = add_journey.email;
  IF (FOUND = true
      AND (add_journey.station_start != add_journey.station_end
      AND add_journey.time_start < add_journey.time_end
      AND add_journey.time_end - add_journey.time_start < interval '24 hours'))
    THEN

  PERFORM * FROM journey WHERE add_journey.email IN( SELECT journey.email FROM journey);
  IF (FOUND = false) THEN
    INSERT INTO journey
    VALUES(DEFAULT, add_journey.time_start, add_journey.time_end, add_journey.station_start, add_journey.station_end, add_journey.email);
    RETURN true;
    
  ELSIF (add_journey.time_start > time_end_)
  THEN
      INSERT INTO journey
      VALUES(DEFAULT, add_journey.time_start, add_journey.time_end, add_journey.station_start, add_journey.station_end, add_journey.email);
      RETURN true;
    END IF;
  END IF;
  RETURN false;
END;
$$ language plpgsql;
