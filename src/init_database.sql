DROP TABLE IF EXISTS type_transport CASCADE;
DROP TABLE IF EXISTS line CASCADE;
DROP TABLE IF EXISTS station CASCADE;
DROP TABLE IF EXISTS zone CASCADE;
DROP TABLE IF EXISTS bill CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS journey CASCADE;
DROP TABLE IF EXISTS offer CASCADE;
DROP TABLE IF EXISTS contrat CASCADE;
DROP TABLE IF EXISTS service CASCADE;
DROP TABLE IF EXISTS contained CASCADE;
DROP TABLE IF EXISTS subscription CASCADE;
DROP TABLE IF EXISTS offer_t CASCADE;
DROP TABLE IF EXISTS status_t CASCADE;


CREATE TABLE type_transport (
  code_transport      VARCHAR(3) NOT NULL UNIQUE,
  name                VARCHAR(32) NOT NULL UNIQUE,
  capacity            INTEGER NOT NULL,
  avg_interval        INTEGER NOT NULL,
  PRIMARY KEY (code_transport)
);
CREATE TABLE zone (
  id_zone             SERIAL NOT NULL UNIQUE,
  price               FLOAT NOT NULL,
  name_zone           VARCHAR(32) NOT NULL UNIQUE,
  PRIMARY KEY (id_zone)
);
CREATE TABLE person (
  email               VARCHAR(128) NOT NULL UNIQUE,
  firstname            VARCHAR(32) NOT NULL,
  lastname            VARCHAR(32) NOT NULL,
  phone               VARCHAR(10) NOT NULL,
  address             TEXT NOT NULL,
  town                VARCHAR(32) NOT NULL,
  login               VARCHAR(8),
  PRIMARY KEY (email)
);

CREATE TABLE line (
  code_line           VARCHAR(3) NOT NULL UNIQUE,
  code_transport      VARCHAR(3) NOT NULL,
  PRIMARY KEY (code_line),
  FOREIGN KEY (code_transport) REFERENCES type_transport (code_transport)
);
CREATE TABLE station (
  id_station          INTEGER NOT NULL UNIQUE,
  name_station        VARCHAR(64) NOT NULL,
  town                VARCHAR(32) NOT NULL,
  code_transport      VARCHAR(3) NOT NULL,
  id_zone             INTEGER,
  PRIMARY KEY (id_station),
  FOREIGN KEY (code_transport) REFERENCES type_transport(code_transport),
  FOREIGN KEY (id_zone) REFERENCES zone(id_zone)
);
CREATE TABLE bill (
  id_bill             SERIAL NOT NULL UNIQUE,
  year                INTEGER NOT NULL,
  month               INTEGER NOT NULL,
  paid                INTEGER NOT NULL, --0 if paid 1 otherwise
  amount              FLOAT NOT NULL,
  email               VARCHAR(128) NOT NULL,
  PRIMARY KEY (id_bill),
  FOREIGN KEY (email) REFERENCES person(email) on update cascade
);
CREATE TABLE journey (
  id_journey          SERIAL,
  time_start          TIMESTAMP  NOT NULL,
  time_end            TIMESTAMP  NOT NULL,
  station_start       INT NOT NULL,
  station_end         INT NOT NULL,
  email               VARCHAR(128) NOT NULL,
  PRIMARY KEY (id_journey),
  FOREIGN KEY (station_start) REFERENCES station(id_station),
  FOREIGN KEY (email) REFERENCES person(email)
);
CREATE TABLE offer (
  code_offer          VARCHAR(5) NOT NULL UNIQUE,
  name_offer          VARCHAR(32) NOT NULL UNIQUE,
  price               FLOAT NOT NULL,
  nb_month            INTEGER NOT NULL,
  id_zone             INTEGER,
  PRIMARY KEY (code_offer),
  FOREIGN KEY (id_zone) REFERENCES zone(id_zone)
);
CREATE TABLE service (
  id_service          SERIAL NOT NULL,
  name_service        VARCHAR(32) NOT NULL UNIQUE,
  discount            FLOAT NOT NULL,
  PRIMARY KEY (id_service)
);
CREATE TABLE contrat (
  id_contrat          SERIAL NOT NULL,
  hire_date           DATE NOT NULL,
  departure_date      DATE,
  email               VARCHAR(128) NOT NULL,
  id_service          SERIAL NOT NULL,
  PRIMARY KEY (id_contrat),
  FOREIGN KEY (email) REFERENCES person(email) on update cascade,
  FOREIGN KEY (id_service) REFERENCES service(id_service)
);

CREATE TABLE contained (
  id_contained        SERIAL NOT NULL,
  pos                 INTEGER NOT NULL,
  code_line           VARCHAR(5) NOT NULL,
  id_station          INTEGER NOT NULL,
  PRIMARY KEY (id_contained),
  FOREIGN KEY (code_line) REFERENCES line (code_line),
  FOREIGN KEY (id_station) REFERENCES station (id_station)
);
CREATE TABLE subscription (
  id_subscription     SERIAL NOT NULL UNIQUE,
  register            VARCHAR(32),
  date_hire           DATE NOT NULL,
  email               VARCHAR(128) NOT NULL,
  code_offer          VARCHAR(5) NOT NULL,
  PRIMARY KEY (id_subscription),
  FOREIGN KEY (email) REFERENCES person(email) on update cascade,
  FOREIGN KEY (code_offer) REFERENCES offer(code_offer)
);

CREATE TABLE offer_t(
  id_offer_t    SERIAL,
  code_offer_t  VARCHAR(5) NOT NULL,
  date_t        timestamp NOT NULL,
  old_price_t   FLOAT NOT NULL,
  new_price_t   FLOAT NOT NULL,
  PRIMARY KEY (id_offer_t)
);

CREATE TABLE status_t(
  id_status_t           SERIAL,
  email                 VARCHAR(128) NOT NULL,
  subscription_code_t   VARCHAR(5) NOT NULL,
  date_t                TIMESTAMP NOT NULL,
  old_status_t          VARCHAR(32) NOT NULL,
  new_status_t          VARCHAR(32) NOT NULL,
  PRIMARY KEY (id_status_t)
);
