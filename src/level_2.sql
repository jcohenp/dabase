DROP FUNCTION IF EXISTS add_person(VARCHAR(32), VARCHAR(32), VARCHAR(128), VARCHAR(10), TEXT, VARCHAR(32), VARCHAR(5));
DROP FUNCTION IF EXISTS add_offer(VARCHAR(5), VARCHAR(32), FLOAT, INT, INT, INT);
DROP FUNCTION IF EXISTS add_subscription(INT, VARCHAR(128), VARCHAR(5), DATE);



CREATE OR REPLACE FUNCTION add_person(firstname VARCHAR(32), lastname VARCHAR(32), email VARCHAR(128), phone VARCHAR(10), address TEXT, town VARCHAR(32), zipcode VARCHAR(5))
RETURNS BOOLEAN AS
$$
BEGIN
  INSERT INTO person
  VALUES (add_person.email, add_person.firstname, add_person.lastname, add_person.phone, add_person.address, add_person.town, DEFAULT);
  RETURN true;
  EXCEPTION WHEN others THEN
    RETURN false;
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


CREATE OR REPLACE FUNCTION add_subscription(num INT, email VARCHAR(32), code VARCHAR(5), date_sub DATE)
RETURNS BOOLEAN AS
$$
DECLARE
  register_ INT := (SELECT register from subscription WHERE subscription.id_subscription = add_subscription.num);
BEGIN
  IF (register_ = 1 OR register_ = 2 ) THEN
    RETURN false;
  END IF;
  INSERT INTO subscription
  VALUES (add_subscription.num, 2, add_subscription.date_sub, add_subscription.email, add_subscription.code);
  RETURN true;
  EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;
