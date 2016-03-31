DROP FUNCTION IF EXISTS check_add_transport_type();

DROP FUNCTION IF EXISTS check_add_zone();

DROP FUNCTION IF EXISTS check_add_station();

--DROP FUNCTION IF EXISTS add_line(VARCHAR(3), VARCHAR(3));
--DROP FUNCTION IF EXISTS add_station_to_line(INT, VARCHAR(3), INT);

CREATE OR REPLACE FUNCTION check_add_transport_type()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_transport_type('001', 'subway', 70, 1) AND
  true = add_transport_type('002', 'tramway', 50, 3) AND
  true = add_transport_type('003', 'bus', 40, 6) AND
  true = add_transport_type('004', 'boat', 200, 20) AND
  false = add_transport_type('005', 'bus', 40, 6) AND  -- bus already exist
  false = add_transport_type('004', 'Velib', 1, 2) AND --004 already exist
  false = add_transport_type('005', 'taxi', -10, 4) AND -- CAPACITY negative
  false = add_transport_type('005', 'tgv', 120, -200) AND -- minutes negative
  false = add_transport_type('005', 'place', -300, -500) -- minutes AND capacity negative

THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION check_add_zone()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_zone('zone1', 30) AND
  true = add_zone('zone2', 0.001) AND
  true = add_zone('zone3', 20.00) AND
  true = add_zone('zone4', 25.01) AND
  true = add_zone('zone5', 30.5555) AND
  false = add_zone('zone1', 30) AND -- name zone duplaceted
  false = add_zone('zone6', -30) AND -- price negative
  false = add_zone('zone1', -30) -- name zone duplaceted and price negative
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION check_add_station()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_station(1, 'Porte Dorée', 'Paris', 1, '001') AND
  true = add_station(2, 'Michel Bizot', 'Paris', 1, '001') AND
  true = add_station(3, 'Daumesnil', 'Paris', 1, '001') AND
  true = add_station(4, 'Geoges V', 'Paris', 2, '001') AND
  true = add_station(5, 'Franklin Roosvelt', 'Paris', 2, '001') AND
  true = add_station(6, 'Charles de gaule étoile', 'Paris', 2, '001') AND
  true = add_station(7, 'Charles de gaule étoile', 'Paris', 2, '003') AND
  false = add_station(7, 'Charles de gaule étoile', 'Paris', 2, '003') AND -- id already exists
  false = add_station(7, 'Charles de gaule étoile', 'Paris', 7, '003') AND -- zone don-t exists
  false = add_station(8, 'Chales de gaule étoile', 'Paris', 2, '009') AND -- type transport don't exists
  false = add_station(7, 'Chales de gaule étoile', 'Paris', 2, '009') -- id already exists and type transport don't exists
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;
