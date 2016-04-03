CREATE OR REPLACE FUNCTION add_transport_type(code VARCHAR(3), name VARCHAR (32), capacity INT, avg_interval INT)
RETURNS BOOLEAN AS
$$
BEGIN
  IF (add_transport_type.capacity <= 0 OR add_transport_type.avg_interval <= 0) THEN
    RETURN false;
  END IF;
  INSERT INTO type_transport
  VALUES (add_transport_type.code, add_transport_type.name, add_transport_type.capacity, add_transport_type.avg_interval);
  RETURN true;
  EXCEPTION WHEN others THEN
    RETURN false;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_zone(name VARCHAR(32), price FLOAT)
RETURNS BOOLEAN AS
$$
DECLARE
new_price FLOAT := (round(cast(add_zone.price as numeric), 2));
BEGIN

  IF ( new_price <= 0) THEN 
    RETURN false;
  END IF; 
  INSERT INTO zone
  VALUES (DEFAULT, new_price, add_zone.name);
  RETURN true;
  EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION add_station(id INT, name VARCHAR(64), town VARCHAR(32), zone INT, type VARCHAR(3))
RETURNS BOOLEAN AS
$$
BEGIN

  INSERT INTO station
  VALUES (add_station.id, add_station.name, add_station.town, add_station.type, add_station.zone);
  RETURN true;
  EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION add_line(code VARCHAR(3), type VARCHAR(3))
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO line
  VALUES (add_line.code, add_line.type);
  RETURN true;
  EXCEPTION WHEN others THEN
  RETURN false;

END
$$ language plpgsql;

CREATE OR REPLACE FUNCTION add_station_to_line(station INT, line VARCHAR(3), pos INT)
RETURNS BOOLEAN AS
$$
BEGIN
PERFORM * FROM contained 
          WHERE (contained.id_station = add_station_to_line.station
          AND   contained.code_line = add_station_to_line.line)
          OR    (contained.pos = add_station_to_line.pos
          AND   contained.code_line = add_station_to_line.line);
IF (FOUND = true) THEN
  RETURN false;
END IF;
INSERT INTO contained
VALUES (DEFAULT, add_station_to_line.pos, add_station_to_line.line, add_station_to_line.station);
RETURN true;
EXCEPTION WHEN others THEN
  RETURN false;
END
$$ language plpgsql;


CREATE OR REPLACE view view_transport_50_300_users(transport) AS

SELECT name FROM type_transport WHERE capacity >= 50 AND capacity <= 300 ORDER BY name;


CREATE OR REPLACE view view_stations_from_villejuif(station) AS

SELECT name_station FROM station WHERE town = 'Villejuif' ORDER BY name_station;


CREATE OR REPLACE view view_stations_zones(station, zone) AS

SELECT name_station, name_zone FROM station JOIN zone ON station.id_zone = zone.id_zone ORDER BY name_zone, name_station;


CREATE OR REPLACE view view_nb_station_type(type, station) AS

SELECT type_transport.name, count(station.id_station) FROM type_transport 
LEFT JOIN station ON station.code_transport = type_transport.code_transport
GROUP BY type_transport.name 
ORDER BY count(station.id_station) DESC , type_transport.name;
 
CREATE OR REPLACE view view_line_duration(type, line, minutes) AS

SELECT type_transport.name, line.code_line, count(*) * type_transport.avg_interval - type_transport.avg_interval FROM line
LEFT JOIN  type_transport ON type_transport.code_transport = line.code_transport
LEFT JOIN contained ON line.code_line = contained.code_line
GROUP BY type_transport.name, line.code_line, type_transport.avg_interval
ORDER BY type_transport.name, line.code_line;


CREATE OR REPLACE view view_a_station_capacity(station, capacity) AS

SELECT name_station, capacity FROM station, type_transport 
WHERE LEFT(LOWER(name_station), 1) = 't'
AND type_transport.code_transport = station.code_transport 
ORDER BY station.name_station, type_transport.capacity;



CREATE OR REPLACE FUNCTION list_station_in_line(line_code VARCHAR(3))
RETURNS setof VARCHAR(32) AS
$$
DECLARE
  string VARCHAR(32);
BEGIN
for string in SELECT name_station FROM station
JOIN contained ON contained.id_station = station.id_station
AND list_station_in_line.line_code = contained.code_line 
ORDER BY contained.pos
LOOP
RETURN NEXT string;
END LOOP;
RETURN;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION list_types_in_zone(zone INT)
RETURNS setof VARCHAR(32) AS
$$
BEGIN

RETURN QUERY SELECT name FROM type_transport JOIN station
ON type_transport.code_transport = station.code_transport
WHERE station.id_zone = list_types_in_zone.zone
GROUP BY type_transport.name
ORDER BY type_transport.name;

END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION get_cost_travel(station_start INT, station_end INT)
RETURNS FLOAT AS
$$
DECLARE

  station_start_ FLOAT := (SELECT  zone.price FROM zone
  JOIN station ON zone.id_zone = station.id_zone WHERE station.id_station = get_cost_travel.station_start);

  station_end_ FLOAT := (SELECT  zone.price FROM zone
  JOIN station ON zone.id_zone = station.id_zone WHERE station.id_station = get_cost_travel.station_end);


  zone_start_ INT := (SELECT station.id_zone FROM station WHERE get_cost_travel.station_start = station.id_station);

  zone_end_ INT := (SELECT station.id_zone FROM station WHERE get_cost_travel.station_end = station.id_station);

price FLOAT := (SELECT sum(zone.price) FROM zone WHERE zone.id_zone BETWEEN zone_start_ AND zone_end_ OR zone.id_zone BETWEEN zone_end_ AND zone_start_);
BEGIN
IF (station_start_ IS NULL OR station_end_ IS NULL) THEN
  RETURN 0;
END IF;
RETURN price;
END;
$$ language plpgsql;
