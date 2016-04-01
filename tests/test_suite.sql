DROP FUNCTION IF EXISTS check_add_transport_type();

DROP FUNCTION IF EXISTS check_add_zone();

DROP FUNCTION IF EXISTS check_add_station();

DROP FUNCTION IF EXISTS check_add_line();

DROP FUNCTION IF EXISTS check_add_station_to_line();

DROP FUNCTION IF EXISTS check_add_person();

DROP FUNCTION IF EXISTS check_add_offer();

DROP FUNCTION IF EXISTS check_add_subscription();

DROP FUNCTION IF EXISTS check_update_status();

DROP FUNCTION IF EXISTS check_update_offer_price();

DROP FUNCTION IF EXISTS check_add_service();

DROP FUNCTION IF EXISTS check_add_contract();

DROP FUNCTION IF EXISTS check_update_service();

DROP FUNCTION IF EXISTS check_update_employee_mail();

DROP FUNCTION IF EXISTS check_add_journey();

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


CREATE OR REPLACE FUNCTION check_add_line()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_line('00A', '001') AND
  true = add_line('00B', '001') AND
  true = add_line('00C', '001') AND
  true = add_line('00D', '002') AND
  true = add_line('00E', '002') AND
  true = add_line('00F', '002') AND
  false = add_line('00A', '001') AND -- '00A ALREADY EXISTS'
  false = add_line('00G', '009') AND -- '009' NOT EXISTS
  false = add_line('00A', '009') -- '009' NOT EXISTS AND '00A ALREADY EXISTS'
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION check_add_station_to_line()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_station_to_line(1, '00A', 1) AND
  true = add_station_to_line(2, '00A', 2) AND
  true = add_station_to_line(3, '00A', 3) AND
  true = add_station_to_line(4, '00A', 5) AND
  true = add_station_to_line(4, '00B', 1) AND
  true = add_station_to_line(5, '00B', 2) AND
  true = add_station_to_line(6, '00B', 3) AND
  true = add_station_to_line(1, '00B', 4) AND
  false = add_station_to_line(1, '00A', 4) AND --station 1 already exists in 00A line
  false = add_station_to_line(5, '00A', 1) AND --position 1  already exists in 00A line
  false = add_station_to_line(42, '00A', 1) AND    --station 42 don't exists 
  false = add_station_to_line(5, '007', 1)    --line 007 don't exists 
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION check_add_person()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_person('julien', 'COHEN', 'julien.cohen@epita.fr', '0123243541', '101 avenues des amandier', 'Saint-Brice', '128B0') AND
  true = add_person('francois', 'GREBOT', 'francois.grebot@epita.fr', '0123234354', '101 avenues de gaulles', 'Paris', '198U0') AND
  true = add_person('alexandre', 'allexandre', 'alexandre.allexandre@epita.fr', '0122143541', '101 avenues pereire', 'Paris', '198B0') AND
  true = add_person('tung', 'VO', 'tung.vo@epita.fr', '0193243541', '101 avenues des asiates', 'Paris', '18B0') AND
  true = add_person('coco', 'LA Fontaine', 'coco.lafontaine@epita.fr', '0193243541', '101 avenues des asiates', 'Paris', '18B0') AND

  true = add_person('coco', 'LA Fontaine', 'coco.lafontaine2@epita.fr', '3581096785', '101 avenues des rerf', 'Saint-Brice', '129B0') AND--num tel to much long
  true = add_person('coco', 'LA Fontaine', 'coco.lafontaine3@epita.fr', '3581096785', '101 avenues des rerf', 'Saint-Brice', '129B0') AND--num tel to much long
  true = add_person('coco', 'LA Fontaine', 'coco.lafontaine4@epita.fr', '3581096785', '101 avenues des rerf', 'Saint-Brice', '129B0') AND--num tel to much long
  true = add_person('coco', 'LA Fontaine', 'coco.lafontaine5@epita.fr', '3581096785', '101 avenues des rerf', 'Saint-Brice', '129B0') AND--num tel to much long
  ufalse = add_person('julien1', 'COHEN1', 'julien.cohen@epita.fr', '0123243581', '101 avenues des rerf', 'Saint-Brice', '129B0') AND  -- email already exists
  false = add_person('julien', 'COHEN', 'julien.cohen2@epita.fr', '0123243581096785', '101 avenues des rerf', 'Saint-Brice', '129B0') --num tel to much long
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION check_add_offer()
RETURNS VOID AS
$$
BEGIN
IF
  true = add_offer('RATP1', 'etudiant', 20, 12, 1, 3) AND
  true = add_offer('RATP2', 'Militaire', 30, 12, 5, 5) AND
  true = add_offer('RATP3', 'Navigo', 50, 24, 1, 1) AND
  true = add_offer('RATP4', 'Navigo', 70.0001, 36, 1, 2) AND
  false = add_offer('RATP1', 'efze',40, 12, 1, 2) AND -- RATP1  already exists
  false = add_offer('RATP5', 'gratis', 0, 12, 2, 3) AND -- offer cannot be 0
  false = add_offer('RATP5', 'Navigo', -50, 12, 1, 1) AND -- price cannot be negatif
  false = add_offer('RATP5', 'Navigo', 50, -12, 1, 1) AND -- month cannot be negatif
  false = add_offer('RATP5', 'Navigo', 50, 12, 18, 1) AND -- zone_from has to exist
  false = add_offer('RATP5', 'Navigo', 50, -12, 1, 8)  -- zone_to has to exist
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;



CREATE OR REPLACE FUNCTION check_add_subscription()
RETURNS VOID AS
$$
BEGIN
IF
  true = add_subscription(1, 'julien.cohen@epita.fr', 'RATP1', '2016-04-01') AND
  true = add_subscription(2, 'francois.grebot@epita.fr', 'RATP1', '2016-04-01') AND
  true = add_subscription(3, 'alexandre.allexandre@epita.fr', 'RATP2', '2016-01-01') AND
  true  = add_subscription(4, 'tung.vo@epita.fr', 'RATP2', '2016-02-01') AND
  false = add_subscription(5, 'je_nexistepas@epita.fr', 'RATP2', '2016-02-01') AND -- email dont exists
  false = add_subscription(1, 'julien.cohen@epita.fr', 'RATP2', '2016-02-01') AND -- id already exists
  false = add_subscription(5, 'julien.cohen@epita.fr', 'RATP6', '2016-04-01') -- offer code don't exists
  
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql ;

CREATE OR REPLACE FUNCTION check_update_status()
RETURNS VOID AS
$$
BEGIN
IF 
  true = update_status(1, 'Registred') AND
  true = update_status(1, 'Incomplete') AND
  true = update_status(2, 'Pending') AND
  false = update_status(3, 'Nimp!') AND -- Nimp not exists
  false = update_status(10, 'Pending') -- id = 10 not exists
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION check_update_offer_price()
RETURNS VOID AS
$$
BEGIN
IF 
  true = update_offer_price('RATP1', 30) AND
  true = update_offer_price('RATP2', 100) AND
  false = update_offer_price('RATP9', 40) AND -- RATP9 dosent exists
  false = update_offer_price('RATP3', -30) AND -- price negatif
  false = update_offer_price('RATP4', 0) -- price = 0
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION check_add_service()
RETURNS VOID AS
$$
BEGIN
IF
  true = add_service('Driving', 30) AND
  true = add_service('Cleanning', 10) AND
  true = add_service('Rh', 20) AND
  false = add_service('Driving', 40) AND -- Drinving already exists
  false = add_service('computer sciences', -10) AND -- discount < 0
  false = add_service('computer sciences', 110) -- discount > 100
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END
$$ language plpgsql;

CREATE OR REPLACE FUNCTION check_add_contract()
RETURNS VOID AS
$$
BEGIN
IF
  true = add_contract('julien.cohen@epita.fr', '2014-01-01', 'Driving') AND
  true = add_contract('francois.grebot@epita.fr', '2015-01-01', 'Rh') AND
  true = add_contract('alexandre.allexandre@epita.fr', '2015-01-01', 'Cleanning') AND
  true = end_contract('julien.cohen@epita.fr', '2015-01-01') AND
  false = add_contract('julien.cohen@epita.fr', '2013-01-01', 'Driving') AND -- impossible to add a contract withn a date new contract < date old contract
  true = add_contract('julien.cohen@epita.fr', '2015-01-02', 'Driving') AND
  false = add_contract('julien.cohen@epita.fr', '2015-03-01', 'Driving')AND -- last contract has to finish before add a new contract
  true = add_contract('coco.lafontaine@epita.fr', '2015-01-01', 'Cleanning') AND
  true = add_contract('coco.lafontaine5@epita.fr', '2015-01-01', 'Cleanning') AND
  true = add_contract('coco.lafontaine2@epita.fr', '2015-01-01', 'Cleanning') AND
  true = add_contract('coco.lafontaine3@epita.fr', '2015-01-01', 'Cleanning') AND
  true = add_contract('coco.lafontaine4@epita.fr', '2015-01-01', 'Cleanning') AND
  false = end_contract('tung.vo@epita.fr', '2015-01-01') AND -- contract dosent exists
  false = end_contract('coco.lafontaine@epita.fr', '2014-01-01') -- contract dosent exists
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION check_update_service()
RETURNS VOID AS
$$
BEGIN
IF 
  true = update_service('Driving', 50) AND
  true = update_service('Cleanning', 20) AND
  true = update_service('Rh', 30) AND
  false = update_service('Rh', -30) AND -- discount < 0
  false = update_service('Rh', 120) AND-- discount > 100
  false = update_service('jenexistepas', 60) -- name service dosent exists
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION check_update_employee_mail()
RETURNS VOID AS
$$
BEGIN
IF
  true = update_employee_mail('cohen_j', 'jujubgdu93poto@tuglife.com') AND
  true = update_employee_mail('lafont_a', 'lafontaine@tuglife.com') AND
  false = update_employee_mail('lafont_b', 'jujubgdu93poto@tuglife.com') AND --email already exists
  false = update_employee_mail('lafont_z', 'lafont@tuglife.com') --login dosent exists
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION check_add_journey()
RETURNS VOID AS
$$
BEGIN
IF 
  true = add_journey('julien.cohen@epita.fr', '2016-03-29 15:00:00', '2016-03-29 16:00:00', 1, 2) AND
  false = add_journey('julien.cohen@epita.fr', '2016-03-29 16:00:00', '2016-03-29 15:00:00', 1, 2) AND
  false = add_journey('julien.cohen@epita.fr', '2016-03-29 15:00:00', '2016-03-29 16:00:00', 4, 5) AND -- time already use
  false = add_journey('julien.cohen@epita.fr', '2016-03-29 15:30:00', '2016-03-29 15:45:00', 4, 5) AND -- time already use
  true = add_journey('julien.cohen@epita.fr', '2016-03-29 17:30:00', '2016-03-29 18:45:00', 4, 5) AND
  false = add_journey('juliencoco.cohen@epita.fr', '2016-03-29 17:30:00', '2016-03-29 18:45:00', 4, 5) AND -- email dosent exists
  false = add_journey('julien.cohen@epita.fr', '2016-03-29 17:30:00', '2016-03-29 18:45:00', 9, 10) -- stations dosent exists
THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE NOTICE 'Fail';
END IF;
END;
$$ language plpgsql;
