DROP FUNCTION IF EXISTS add_transport_type(VARCHAR(3), VARCHAR(32), INT, INT);
DROP FUNCTION IF EXISTS add_zone(VARCHAR(32), FLOAT);
DROP FUNCTION IF EXISTS add_station(INT, VARCHAR(64), VARCHAR(32), INT, VARCHAR(3));
DROP FUNCTION IF EXISTS add_line(VARCHAR(3), VARCHAR(3));
DROP FUNCTION IF EXISTS add_station_to_line(INT, VARCHAR(3), INT);

DROP VIEW IF EXISTS  view_transport_50_300_users CASCADE ;
DROP VIEW IF EXISTS  view_nb_station_type CASCADE ;
DROP VIEW IF EXISTS  view_line_duration CASCADE ;
DROP VIEW IF EXISTS  view_a_station_capacity CASCADE ;

DROP FUNCTION IF EXISTS list_station_in_line(VARCHAR(3));
DROP FUNCTION IF EXISTS list__type_in_zone(INT);
DROP FUNCTION IF EXISTS get_cost_travel(INT, INT);

CREATE OR REPLACE FUNCTION add_transport_type(code VARCHAR(3), name VARCHAR (32), capacity INT, avg_interval INT)
RETURNS BOOLEAN AS
$$
BEGIN
  IF (add_transport_type.capacity < 0 AND add_transport_type.avg_interval < 0) THEN
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
BEGIN
  IF ( add_zone.price < 0) THEN 
    RETURN false;
  END IF; 
  INSERT INTO zone
  VALUES (DEFAULT, round(cast(add_zone.price as numeric), 2), add_zone.name);
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


CREATE OR REPLACE view view_transport_50_300_users AS

SELECT name FROM type_transport WHERE capacity >= 50 AND capacity <= 300 ORDER BY name;


CREATE OR REPLACE view view_stations_from_villejuif AS

SELECT name_station FROM station WHERE town = 'Villejuif' ORDER BY name_station;


CREATE OR REPLACE view view_stations_zones AS

SELECT name_station, name_zone FROM station JOIN zone ON station.id_zone = zone.id_zone ORDER BY name_zone, name_station;


CREATE OR REPLACE view view_nb_station_type(type, station) AS

SELECT type_transport.name, count(station.id_station) FROM type_transport, station WHERE type_transport.code_transport = station.code_transport GROUP BY type_transport.name ORDER BY count(station.id_station) DESC , type_transport.name;
 
CREATE OR REPLACE view view_line_duration(type, line, minutes) AS

SELECT type_transport.name, line.code_line, count(contained.id_station - 1) * type_transport.avg_interval FROM line
JOIN  type_transport ON type_transport.code_transport = line.code_transport
JOIN contained ON line.code_line = contained.code_line GROUP BY type_transport.name, line.code_line, type_transport.avg_interval;





CREATE OR REPLACE view view_a_station_capacity(station, capacity) AS

SELECT name_station, capacity FROM station, type_transport WHERE LEFT(name_station, 1) = 'r' AND type_transport.code_transport = station.code_transport GROUP BY station.name_station, type_transport.capacity;



CREATE OR REPLACE FUNCTION list_station_in_line(line_code VARCHAR(3))
RETURNS setof VARCHAR(32) AS
$$
DECLARE
  string VARCHAR(32);
BEGIN
for string in SELECT name_station FROM station
JOIN contained ON contained.id_station = station.id_station AND  list_station_in_line.line_code = contained.code_line ORDER BY contained.pos
LOOP
RETURN NEXT string;
END LOOP;
RETURN;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION list_type_in_zone(zone INT)
RETURNS setof VARCHAR(32) AS
$$
DECLARE
  string VARCHAR(32);
BEGIN
for string in SELECT name FROM zone
JOIN station ON station.id_zone = zone.id_zone
JOIN type_transport ON zone.id_zone = list_type_in_zone.zone GROUP BY  station.id_zone, type_transport.name ORDER BY type_transport.name
LOOP
RETURN NEXT string;
END LOOP;
RETURN;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION get_cost_travel(station_start INT, station_end INT)
RETURNS FLOAT AS
$$
DECLARE

  station_end_ FLOAT := (SELECT  zone.price FROM zone
  JOIN station ON station.id_station = get_cost_travel.station_end AND station.id_zone = zone.id_zone);

  station_start_ FLOAT := (SELECT zone.price FROM zone
  JOIN station ON station.id_station = get_cost_travel.station_start AND station.id_zone = zone.id_zone);



BEGIN

IF ($1 != $2) THEN
  RETURN station_start_ + station_end_;
END IF;
  RETURN 0;
EXCEPTION WHEN others THEN
RETURN 0;
END;
$$ language plpgsql;
