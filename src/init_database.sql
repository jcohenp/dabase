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


CREATE TABLE type_transport (
  code_transport      VARCHAR(3) NOT NULL UNIQUE,
  name                VARCHAR(32) NOT NULL UNIQUE,
  capacity            INTEGER NOT NULL,
  avg_interval        INTEGER NOT NULL,
  PRIMARY KEY (code_transport)
);
CREATE TABLE zone (
  id_zone             SERIAL NOT NULL,
  price               FLOAT NOT NULL,
  name_zone           VARCHAR(32),
  PRIMARY KEY (id_zone)
);
CREATE TABLE person (
  email               VARCHAR(128) NOT NULL UNIQUE,
  firsname            VARCHAR(32) NOT NULL,
  lastname            VARCHAR(32) NOT NULL,
  phone               VARCHAR(10) NOT NULL,
  address             TEXT NOT NULL,
  town                VARCHAR(32) NOT NULL,
  login               VARCHAR(8),
  PRIMARY KEY (email)
);

CREATE TABLE line (
  code_line           VARCHAR(5) NOT NULL UNIQUE,
  code_transport      VARCHAR(3) NOT NULL,
  PRIMARY KEY (code_line),
  FOREIGN KEY (code_transport) REFERENCES type_transport (code_transport)
);
CREATE TABLE station (
  id_station          INTEGER NOT NULL UNIQUE,
  name_station        VARCHAR(64) NOT NULL,
  town                VARCHAR(32) NOT NULL,
  code_transport      VARCHAR(3) NOT NULL,
  id_zone             SERIAL NOT NULL,
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
  FOREIGN KEY (email) REFERENCES person(email)
);
CREATE TABLE journey (
  time_start          DATE  NOT NULL,   --date_stamp
  time_end            DATE  NOT NULL,   --date_stamp
  id_station          INTEGER NOT NULL,
  PRIMARY KEY (time_start),
  FOREIGN KEY (id_station) REFERENCES station(id_station)
);
CREATE TABLE offer (
  code_offer          VARCHAR(5) NOT NULL UNIQUE,
  name_offer          VARCHAR(32) NOT NULL,
  price               FLOAT NOT NULL,
  nb_month            INTEGER NOT NULL,
  id_zone             SERIAL NOT NULL,
  PRIMARY KEY (code_offer),
  FOREIGN KEY (id_zone) REFERENCES zone(id_zone)
);
CREATE TABLE contrat (
  id_contrat          SERIAL NOT NULL,
  hire_date           DATE NOT NULL,
  departure_date      DATE,
  email               VARCHAR(128) NOT NULL,
  PRIMARY KEY (id_contrat),
  FOREIGN KEY (email) REFERENCES person(email)
);
CREATE TABLE service (
  id_service          SERIAL NOT NULL,
  name_service        VARCHAR(32) NOT NULL,
  discount            FLOAT NOT NULL,
  id_contrat          SERIAL NOT NULL,
  PRIMARY KEY (id_service),
  FOREIGN KEY (id_contrat) REFERENCES contrat(id_contrat)
);
CREATE TABLE contained (
  pos                 INTEGER NOT NULL,
  code_line           VARCHAR(5) NOT NULL,
  id_station          INTEGER NOT NULL,
  PRIMARY KEY (pos),
  FOREIGN KEY (code_line) REFERENCES line (code_line),
  FOREIGN KEY (id_station) REFERENCES station (id_station)
);
CREATE TABLE subscription (
  register            INTEGER NOT NULL,
  date_hire           DATE NOT NULL,
  email               VARCHAR(128) NOT NULL,
  code_offer          VARCHAR(5) NOT NULL,
  PRIMARY KEY (register),
  FOREIGN KEY (email) REFERENCES person(email),
  FOREIGN KEY (code_offer) REFERENCES offer(code_offer)
);
