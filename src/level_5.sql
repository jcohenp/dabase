DROP FUNCTION IF EXISTS store_offer_updates() CASCADE;
DROP FUNCTION IF EXISTS store_status_updates() CASCADE;

CREATE OR REPLACE FUNCTION store_offer_updates()
RETURNS TRIGGER AS
$$
BEGIN 
INSERT INTO offer_t
VALUES (DEFAULT, NEW.code_offer, now(), OLD.price, NEW.price);
RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER store_offer_updates
  AFTER UPDATE ON offer
  FOR EACH ROW
  WHEN (OLD.price IS DISTINCT FROM NEW.price)
  EXECUTE PROCEDURE store_offer_updates();



CREATE OR REPLACE FUNCTION store_status_updates()
RETURNS TRIGGER AS
$$
BEGIN 
INSERT INTO status_t
VALUES (DEFAULT, NEW.email, NEW.code_offer, now(), OLD.register, NEW.register);
RETURN NEW;
END;
$$ language plpgsql;

CREATE  TRIGGER store_status_updates
  AFTER UPDATE ON subscription
  FOR EACH ROW
  WHEN (OLD.register IS DISTINCT FROM NEW.register)
  EXECUTE PROCEDURE store_status_updates();

CREATE OR REPLACE VIEW view_offer_updates(subscription, modification, old_price, new_price) AS
SELECT offer_t.code_offer_t, to_char(offer_t.date_t,'DD/MM/YYYY HH12:MI:SS'), offer_t.old_price_t, offer_t.new_price_t from offer_t;

CREATE OR REPLACE VIEW view_status_updates(email, sub, modification, old_status, new_status) AS
SELECT status_t.email, status_t.subscription_code_t, to_char(status_t.date_t,'DD/MM/YYYY HH12:MI:SS'), status_t.old_status_t, status_t.new_status_t from status_t;
