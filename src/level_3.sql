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
lastname_ VARCHAR(32);
firstname_ VARCHAR(1) := (SELECT LOWER(LEFT(firstname, 1)) from person WHERE person.email = add_contract.email);
login_ VARCHAR(8);
id_service_ INT := (SELECT id_service from service WHERE add_contract.service = service.name_service);
name_service_ VARCHAR(32):= (SELECT service.name_service FROM service WHERE service.name_service = add_contract.service);
email_ VARCHAR(32):= (SELECT person.email FROM person WHERE person.email = add_contract.email);

max_ DATE := (SELECT max(contrat.departure_date) FROM contrat WHERE add_contract.email = contrat.email); 
BEGIN

PERFORM * from contrat WHERE name_service_ IS  NULL 
                          OR email_ IS  NULL;
IF (FOUND = true) THEN
  RETURN false;
END IF;

lastname_ := (SELECT LOWER(lastname) from person WHERE person.email = add_contract.email);

PERFORM * from person WHERE person.email = add_contract.email;
  IF (FOUND = true AND strpos(lastname_, ' ') != 0) THEN
    lastname_ := (select LOWER(replace(lastname_, ' ', '')));
  END IF; 
  lastname_ := LEFT(lastname_, 6);
  login_ := (lastname_ || '_' || firstname_);

PERFORM * from contrat WHERE contrat.email = add_contract.email;
IF (FOUND = false) THEN
    PERFORM * FROM person WHERE person.login = login_;
    IF (FOUND = false) THEN
      INSERT INTO contrat
      VALUES(DEFAULT, add_contract.date_beginning, DEFAULT, add_contract.email, id_service_);
      UPDATE  person
      SET login = login_

      WHERE person.email = add_contract.email AND person.login IS NULL;
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
      RETURN true;
      END IF;
ELSE
PERFORM * from contrat WHERE(add_contract.date_beginning >= max_ AND contrat.email = add_contract.email)
                          OR (contrat.departure_date IS  NULL AND contrat.email = add_contract.email);
 IF (FOUND = true) THEN
  PERFORM * FROM contrat WHERE id_contrat IN (SELECT id_contrat FROM contrat WHERE departure_date IS NULL) AND contrat.email = add_contract.email;
    IF (FOUND = true) THEN
      RETURN false;
    END IF;
    INSERT INTO contrat
    VALUES(DEFAULT, add_contract.date_beginning, DEFAULT, add_contract.email, id_service_);
    RETURN true;
  END IF;
END IF;
RETURN false;
EXCEPTION WHEN others THEN
RETURN false;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION end_contract(email VARCHAR(128), date_end DATE)

RETURNS boolean AS
$$
DECLARE
hire_date_ DATE := (SELECT hire_date from contrat WHERE contrat.email = end_contract.email AND contrat.departure_date IS NULL);
BEGIN
  PERFORM * FROM contrat WHERE end_contract.email = contrat.email;
  IF (FOUND = true AND end_contract.date_end >= hire_date_) THEN
    UPDATE contrat
    SET departure_date = end_contract.date_end
    WHERE end_contract.email = contrat.email AND contrat.departure_date IS NULL;
    RETURN true;
  END IF;
  RETURN false;
  EXCEPTION WHEN others THEN
    RETURN false;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION update_service(name VARCHAR(32), discount INT)
RETURNS BOOLEAN AS
$$
BEGIN
PERFORM * from service WHERE name_service = update_service.name;
IF (FOUND = true AND (update_service.discount >= 0 AND update_service.discount <= 100)) THEN
  UPDATE service
  SET discount = update_service.discount
  WHERE service.name_service = update_service.name;
  RETURN true;
END IF;
RETURN false;
EXCEPTION WHEN others THEN
RETURN false;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION update_employee_mail(login VARCHAR(8),email VARCHAR(128))
RETURNS BOOLEAN AS
$$
DECLARE
email_ VARCHAR(128) := (SELECT person.email from person WHERE update_employee_mail.login = person.login);
BEGIN
PERFORM * FROM person WHERE person.login = update_employee_mail.login;
IF (FOUND = true) THEN
  UPDATE person
  SET email = update_employee_mail.email
  WHERE person.login = update_employee_mail.login;
  RETURN true;
END IF;
RETURN false;
EXCEPTION WHEN others THEN
RETURN false;
END;
$$ language plpgsql;

CREATE OR REPLACE view view_employees(lastname, firstname, login, service) AS

SELECT lastname, firstname, login, name_service FROM contrat 
JOIN service ON contrat.id_service = service.id_service join person on contrat.email = person.email
WHERE contrat.hire_date <= current_date AND (contrat.departure_date >= current_date OR contrat.departure_date IS NULL)
GROUP BY lastname, firstname, login, name_service
ORDER BY lastname;


CREATE OR REPLACE view view_nb_employees_per_service(service,nb) AS

SELECT name_service, count(contrat.email) FROM service LEFT JOIN contrat on contrat.id_service = service.id_service AND (contrat.departure_date >= current_date OR contrat.departure_date IS NULL) AND contrat.hire_date <= current_date GROUP BY name_service ORDER BY name_service;


CREATE OR REPLACE FUNCTION list_login_employee(date_service DATE)
RETURNS setof VARCHAR(8) AS

$$
DECLARE
login_ VARCHAR(8);
BEGIN
for login_ IN SELECT login from person JOIN contrat ON person.email = contrat.email WHERE contrat.hire_date <= list_login_employee.date_service
AND (contrat.departure_date >= list_login_employee.date_service OR departure_date IS NULL)
GROUP BY person.login
ORDER BY person.login
LOOP
RETURN NEXT login_;
END LOOP;
RETURN; 
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION list_not_employee(date_service DATE)
RETURNS TABLE(lastname VARCHAR(32), firstname VARCHAR(32), has_worked TEXT) AS
$$
BEGIN

IF (list_not_employee.date_service IS NULL) THEN
  RETURN QUERY SELECT person.lastname, person.firstname, TEXT 'NO' as has_worked from person WHERE person.login IS NULL ORDER BY has_worked DESC, person.lastname, person.firstname;
ELSE
  RETURN QUERY SELECT person.lastname, person.firstname,
                CASE WHEN person.login IS NULL
                  THEN 'NO'
                  ELSE 'YES'
                END AS has_worked
                FROM person
                WHERE person.email
                NOT IN (SELECT contrat.email from contrat 
                WHERE list_not_employee.date_service >= contrat.hire_date
                AND(list_not_employee.date_service <= contrat.departure_date 
                OR contrat.departure_date IS NULL))
                ORDER BY has_worked DESC, person.lastname, person.firstname;
END IF;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION list_subscription_history(email VARCHAR(128))
RETURNS TABLE(type TEXT, name VARCHAR, start_date DATE, duration INTERVAL) AS
$$
BEGIN
RETURN QUERY SELECT TEXT 'sub', offer.name_offer, subscription.date_hire as start_date , (subscription.date_hire + (offer.nb_month || 'month')::interval) - subscription.date_hire
FROM subscription
JOIN offer ON subscription.code_offer = offer.code_offer
WHERE subscription.email = list_subscription_history.email 
AND subscription.register = 'Registered'

UNION
SELECT TEXT 'ctr', service.name_service, contrat.hire_date, (contrat.departure_date - contrat.hire_date || 'day')::interval + '1 day'
FROM contrat
JOIN service ON service.id_service = contrat.id_service
WHERE contrat.email = list_subscription_history.email
ORDER BY start_date;

END;
$$ language plpgsql





