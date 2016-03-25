DROP FUNCTION IF EXISTS add_service(VARCHAR(32), INT);
DROP FUNCTION IF EXISTS add_contract(VARCHAR(128), DATE, VARCHAR(32));

CREATE OR REPLACE FUNCTION add_service(name VARCHAR(32), discount INT) 
RETURNS BOOLEAN AS
$$
BEGIN
  IF (add_service.discount < 0 OR add_service.discount > 100) THEN
    RETURN false;
  END IF;
  INSERT INTO service
  VALUES(DEFAULT, add_service.name, add_service.discount);
  RETURN true;
  EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION add_contract(email VARCHAR(128), date_beginning DATE, service VARCHAR(32))
RETURNS BOOLEAN AS

$$
DECLARE
iterator INT := 97;
lastname_ VARCHAR(6) := (SELECT LEFT(lastname, 6) from person WHERE person.email = add_contract.email);
firstname_ VARCHAR(1) := (SELECT LEFT(firstname, 1) from person WHERE person.email = add_contract.email);
login_ VARCHAR(8) := (lastname_ || '_' || firstname_);
id_service_ INT := (SELECT id_service from service WHERE add_contract.service = service.name_service);
BEGIN

PERFORM * from contrat JOIN service ON add_contract.service = service.name_service
                       JOIN person  ON person.email = add_contract.email
                             AND((extract(year from age(add_contract.date_beginning, contrat.departure_date)) >= 0 AND contrat.email = add_contract.email)
                             OR (extract(month from age(add_contract.date_beginning, contrat.departure_date)) >= 0 AND contrat.email = add_contract.email)
                             OR (extract(day from age(add_contract.date_beginning, contrat.departure_date)) >= 0 AND contrat.email = add_contract.email)
                             OR contrat.departure_date IS NULL AND contrat.email = add_contract.email)
                             OR person.email NOT IN (SELECT contrat.email from contrat WHERE contrat.email = add_contract.email)
                             AND(extract(year from age(add_contract.date_beginning,now())) >= 0);
  
IF (FOUND = true) THEN
PERFORM * FROM contrat where id_contrat IN (SELECT id_contrat FROM contrat WHERE departure_date IS NULL) AND contrat.email = add_contract.email;
  IF (FOUND = true) THEN
    RETURN false;
  END IF;
PERFORM * FROM person WHERE person.login = login_;
  IF (FOUND = false) THEN
    UPDATE  person
    SET login = login_
    WHERE person.email = add_contract.email AND person.login IS NULL;
    INSERT INTO contrat
    VALUES(DEFAULT, add_contract.date_beginning, DEFAULT, add_contract.email, id_service_);
    RETURN true;
  ELSE
    LOOP
    firstname_ := (CAST(chr(iterator) AS VARCHAR(1)));
    login_ = lastname_ || '_' || firstname_;
    PERFORM * FROM person WHERE person.login = login_;
    IF (FOUND = true) THEN
      iterator := iterator + 1;
      CONTINUE;
    END IF;
    UPDATE  person
    SET login = login_
    WHERE add_contract.email = person.email AND person.login IS NULL;
    INSERT INTO contrat
    VALUES(DEFAULT, add_contract.date_beginning, DEFAULT, add_contract.email, id_service_);
    RETURN true;
    END LOOP;
  END IF;
  RETURN true;
END IF;
RETURN false;
EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;
