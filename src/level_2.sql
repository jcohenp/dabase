DROP FUNCTION IF EXISTS add_person(VARCHAR(32), VARCHAR(32), VARCHAR(128), VARCHAR(10), TEXT, VARCHAR(32), VARCHAR(5));
DROP FUNCTION IF EXISTS add_offer(VARCHAR(5), VARCHAR(32), FLOAT, INT, INT, INT);
DROP FUNCTION IF EXISTS add_subscription(INT, VARCHAR(128), VARCHAR(5), DATE);
DROP FUNCTION IF EXISTS update_status(INT, VARCHAR(128), VARCHAR(32));
DROP FUNCTION IF EXISTS update_offer_price(VARCHAR(5), FLOAT);

DROP VIEW IF EXISTS view_user_small_name CASCADE; 
DROP VIEW IF EXISTS view_user_subscription CASCADE; 
DROP VIEW IF EXISTS view_unloved_offer CASCADE;
DROP VIEW IF EXISTS view_old_subscription;

DROP FUNCTION IF EXISTS list_station_near_user(VARCHAR(128));
DROP FUNCTION IF EXISTS list_subscribers(VARCHAR(5));
DROP FUNCTION IF EXISTS list_subscription(VARCHAR(128), DATE);

CREATE OR REPLACE FUNCTION add_person(firstname VARCHAR(32), lastname VARCHAR(32), email VARCHAR(128), phone VARCHAR(10), address TEXT, town VARCHAR(32), zipcode VARCHAR(5))
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO person
  VALUES (add_person.email, add_person.firstname, add_person.lastname, add_person.phone, add_person.address, add_person.town, DEFAULT);
  RETURN true;
  --EXCEPTION WHEN others THEN
  --  RETURN false;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION add_offer(code VARCHAR(5), name VARCHAR(32), price FLOAT, nb_month INT, zone_from INT, zone_to INT)
RETURNS BOOLEAN AS
$$
BEGIN

PERFORM * FROM zone  WHERE zone.id_zone = add_offer.zone_from;
IF (FOUND = false) THEN
  RETURN false;
END IF;

PERFORM * FROM zone WHERE zone.id_zone = add_offer.zone_to;
IF (FOUND = false) THEN
  RETURN false;
END IF;

IF (add_offer.nb_month > 0) THEN
  INSERT INTO offer
  VALUES(add_offer.code, add_offer.name, add_offer.price, add_offer.nb_month, DEFAULT);
    RETURN true;
END IF;
  EXCEPTION WHEN others THEN
    RETURN false;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION add_subscription(num INT, email VARCHAR(128), code VARCHAR(5), date_sub DATE)
RETURNS BOOLEAN AS
$$
DECLARE
  register_ VARCHAR(32) := (SELECT register from subscription WHERE subscription.id_subscription = add_subscription.num);
  status_ VARCHAR(32);
BEGIN

for status_ in SELECT register FROM subscription WHERE subscription.email = add_subscription.email 
LOOP
  IF (status_ = 'Incomplete' OR status_ = 'Pending') THEN
    RETURN false;
  END IF;
END LOOP;

  INSERT INTO subscription
  VALUES (add_subscription.num, 'Incomplete', add_subscription.date_sub, add_subscription.email, add_subscription.code);
  RETURN true;
  EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION update_status(num INT, email VARCHAR(128), new_status VARCHAR(32))
RETURNS BOOLEAN AS
$$
DECLARE
  status_ VARCHAR(32) := (SELECT register FROM subscription WHERE subscription.id_subscription = update_status.num AND subscription.email = update_status.email);
BEGIN
    IF (update_status.new_status = 'Registred' OR  update_status.new_status = 'Incomplete' OR update_status.new_status = 'Pending') THEN
    UPDATE subscription
    SET register = update_status.new_status
    WHERE subscription.id_subscription = update_status.num;
    RETURN true;
  END IF;
  RETURN false;
  EXCEPTION WHEN others THEN
  RETURN false;
END
$$ language plpgsql;

CREATE OR REPLACE FUNCTION update_offer_price(offer_code VARCHAR(5), price FLOAT)
RETURNS BOOLEAN AS
$$
BEGIN

PERFORM * FROM offer WHERE offer.code_offer = update_offer_price.offer_code;
IF (FOUND = false) THEN
  RETURN false;
END IF;
IF (update_offer_price.price > 0) THEN
  UPDATE offer
  SET price = update_offer_price.price
  WHERE offer.code_offer = update_offer_price.offer_code;
  RETURN true;
END IF;
RETURN false;
EXCEPTION WHEN others THEN
RETURN false;
END;
$$ language plpgsql;


CREATE OR REPLACE VIEW view_user_small_name(lastname, firstname) AS

SELECT lastname, firstname FROM person WHERE LENGTH(lastname) <= 4 AND LENGTH(firstname) <= 4 ORDER BY lastname, firstname;

CREATE OR REPLACE VIEW view_user_subscription AS 

SELECT lastname || ' ' || firstname as user, name_offer as offer FROM subscription
JOIN offer ON offer.code_offer = subscription.code_offer
JOIN person ON person.email = subscription.email GROUP BY name_offer, person.lastname, person.firstname  ORDER BY person.lastname, person.firstname;


CREATE OR REPLACE VIEW view_unloved_offer AS

SELECT name_offer FROM offer WHERE offer.code_offer NOT IN (SELECT code_offer FROM subscription) GROUP BY name_offer ORDER BY name_offer;


CREATE OR REPLACE VIEW view_pending_subscriptions(lastname, firstname) AS

SELECT lastname, firstname FROM person
JOIN subscription ON subscription.register = 'Pending' AND subscription.email = person.email  GROUP BY person.lastname, person.firstname, subscription.date_hire  ORDER BY date_hire;

CREATE OR REPLACE VIEW view_old_subscription AS
SELECT lastname, firstname, name_offer, register from subscription
JOIN offer ON subscription.code_offer = offer.code_offer AND (subscription.register ='Pending' OR subscription.register ='Incomplete') AND extract(years from age(date_hire)) >= 1
JOIN person ON subscription.email = person.email ORDER BY lastname, firstname, name_offer;

CREATE OR REPLACE FUNCTION list_station_near_user(user_ VARCHAR(128))
RETURNS SETOF VARCHAR(65) AS
$$
DECLARE
string VARCHAR(64);
BEGIN
for string in SELECT lower(station.name_station) from station JOIN person ON station.town = person.town AND list_station_near_user.user_ = person.email GROUP BY station.name_station
LOOP
  RETURN NEXT string;
END LOOP;
RETURN;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION list_subscribers(code_offer VARCHAR(5))
RETURNS SETOF VARCHAR(65) AS
$$
DECLARE
lastname_ VARCHAR(32);
firstname_ VARCHAR(32);
BEGIN
for lastname_, firstname_ IN SELECT lastname, firstname FROM person JOIN offer on offer.code_offer = list_subscribers.code_offer GROUP BY lastname, firstname ORDER BY lastname, firstname
LOOP
RETURN NEXT lastname_ || ' ' || firstname_;
END LOOP;
RETURN;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION list_subscription(email VARCHAR(128), date DATE)
RETURNS SETOF VARCHAR(5) AS
$$
DECLARE
string VARCHAR(5);
BEGIN
for string IN SELECT code_offer FROM subscription WHERE subscription.register = 'Registred' AND subscription.email = list_subscription.email AND list_subscription.date = subscription.date_hire GROUP BY code_offer ORDER BY code_offer
LOOP
RETURN NEXT string;
END LOOP;
RETURN;
END
$$ language plpgsql;
