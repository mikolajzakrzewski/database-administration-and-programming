-- 1. Utwórz procedurę proc1, która z wykorzystaniem kursora wypisze nazwy miast, w których realne maksymalne zarobki
--    pracowników są niższe od podanej kwoty.
--    Wywołaj ją z parametrem 10000.

-- PostgreSQL
CREATE OR REPLACE PROCEDURE proc1(max_salary INT)
    LANGUAGE plpgsql AS
$$
DECLARE
    city_name locations.city%TYPE; DECLARE
    city_cursor CURSOR FOR
        SELECT l.city
          FROM locations AS l
                   JOIN departments AS d
                   ON d.location_id = l.location_id
                   JOIN employees AS e
                   ON d.department_id = e.department_id
         GROUP BY l.city
        HAVING MAX(e.salary) < max_salary;
BEGIN
    OPEN city_cursor;

    LOOP
        FETCH NEXT FROM city_cursor INTO city_name;
        EXIT WHEN NOT found;

        RAISE NOTICE '%', city_name;
    END LOOP;

    CLOSE city_cursor;
END;
$$;

CALL proc1(10000);


-- 2. Utwórz procedurę proc2, która dodaje informacje o nowym departamencie do bazy danych.
--    ID nowego departamentu musi być automatycznie wyliczane zgodnie z zasadą nadawania ID dla departamentów.
--    Nazwa departamentu musi być podana jako parametr procedury.
--    ID menadżera domyślnie nie ma wpisywanej wartości, ale można ją podać jako parametr procedury.
--    ID lokalizacji ma domyślnie ustawioną wartość 2000, jednakże można podać także inną wartość jako parametr
--    procedury.
--    Wywołaj procedurę proc2 na wszystkie możliwe sposoby, żeby przetestować działanie parametrów domyślnych.

-- PostgreSQL
CREATE OR REPLACE PROCEDURE proc2(new_department_name departments.department_name%TYPE,
                                  new_manager_id departments.manager_id%TYPE DEFAULT NULL,
                                  new_location_id departments.location_id%TYPE DEFAULT 2000)
    LANGUAGE plpgsql AS
$$
BEGIN
    INSERT INTO departments
    VALUES ((SELECT MAX(department_id) + 10 FROM departments), new_department_name, new_manager_id,
            new_location_id);
END;
$$;

BEGIN;
CALL proc2('Nowy departament');
SELECT *
  FROM departments
 ORDER BY department_id DESC;
ROLLBACK;

BEGIN;
CALL proc2('Nowy departament', new_manager_id := 101);
SELECT *
  FROM departments
 ORDER BY department_id DESC;
ROLLBACK;

BEGIN;
CALL proc2('Nowy departament', new_location_id := 1000);
SELECT *
  FROM departments
 ORDER BY department_id DESC;
ROLLBACK;

BEGIN;
CALL proc2('Nowy departament', 101, 1000);
SELECT *
  FROM departments
 ORDER BY department_id DESC;
ROLLBACK;


-- 3. Utwórz procedurę proc3, która podwyższy prowizję o podaną liczbę punktów procentowych u pracowników zatrudnionych
--    przed podanym rokiem i poprzez parametr wyjściowy zwróci liczbę zmodyfikowanych rekordów.
--    Wywołaj ją z parametrami 2004 oraz 0.05.

-- PostgreSQL
CREATE OR REPLACE PROCEDURE proc3(percentage_points NUMERIC(2, 2), year_limit INT,
                                  OUT modified_records_count INT)
    LANGUAGE plpgsql AS
$$
BEGIN
    UPDATE employees
       SET commission_pct = COALESCE(commission_pct, 0.00) + percentage_points
     WHERE EXTRACT(YEAR FROM hire_date) < year_limit;

    GET DIAGNOSTICS modified_records_count = ROW_COUNT;
END;
$$;

DO
$$
    DECLARE
        modified_rows_count INT;
    BEGIN
        CALL proc3(0.05, 2004, modified_rows_count);
        RAISE NOTICE 'Liczba zmodyfikowanych rekordów: %', modified_rows_count;
        ROLLBACK;
    END;
$$;


-- 4. Utwórz funkcję func4, która zwróci procentowy udział liczby pracowników zatrudnionych w podanym departamencie
--    w łącznej liczbie wszystkich pracowników.
--    Wynik zaokrąglij do części setnych.
--    Wywołaj ją dla wszystkich departamentów wewnątrz zapytania dającego wynik w postaci trzech kolumn: department_id,
--    department_name, percentage.

-- PostgreSQL
CREATE OR REPLACE FUNCTION func4(in_department_name departments.department_name%TYPE) RETURNS NUMERIC(4, 2)
    LANGUAGE plpgsql AS
$$
DECLARE
    total_employee_count         INT;
    in_department_employee_count INT;
BEGIN
    SELECT COUNT(*) INTO total_employee_count FROM employees;

    SELECT COUNT(*)
      INTO in_department_employee_count
      FROM departments AS d
               JOIN employees AS e
               ON d.department_id = e.department_id
     WHERE d.department_name = in_department_name;

    RETURN ROUND((in_department_employee_count * 100.0 / total_employee_count), 2);
END;
$$;


BEGIN;

SELECT d.department_id, d.department_name, func4(d.department_name) AS percentage
  FROM departments AS d;

ROLLBACK;


-- 5. Utwórz funkcję func5, która zwróci wszystkie informacje o departamentach mających siedzibę w podanym kraju.
--    Wywołaj ją z parametrem Canada wewnątrz zapytania dającego wynik w postaci dwóch kolumn: department_id,
--    department_name.

-- PostgreSQL
CREATE OR REPLACE FUNCTION func5(in_country countries.country_name%TYPE)
    RETURNS TABLE
                (
                    department_id departments.department_id%TYPE,
                    department_name departments.department_name%TYPE,
                    manager_id departments.manager_id%TYPE,
                    location_id departments.location_id%TYPE
                )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY (SELECT d.*
                    FROM departments AS d
                             JOIN locations AS l
                             ON d.location_id = l.location_id
                             JOIN countries AS c
                             ON l.country_id = c.country_id
                   WHERE c.country_name = in_country);
END;
$$;


BEGIN;

SELECT department_id, department_name
  FROM func5('Canada');

ROLLBACK;


-- 6. Utwórz funkcję func6, która zwróci kursor z informacjami o pracownikach (imię, nazwisko oraz nazwa stanowiska),
--    których menadżerem jest podany pracownik.
--    Wywołaj ją z parametrami "Matthew" i "Weiss".
--    Następnie wypisz spośród nich tylko tych pracowników (ich imiona i nazwiska), którzy zajmują stanowisko
--    Stock Clerk.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje funkcja zwracająca kursor, wykorzystaj funkcję zwracającą tabelę
--    oraz kursor.

-- PostgreSQL
CREATE OR REPLACE FUNCTION func6(in_first_name employees.first_name%TYPE,
                                 in_last_name employees.last_name%TYPE) RETURNS REFCURSOR
    LANGUAGE plpgsql AS
$$
DECLARE
    employee_cursor REFCURSOR;
BEGIN
    OPEN employee_cursor FOR SELECT e.first_name, e.last_name, j.job_title
                               FROM employees AS e
                                        JOIN jobs AS j
                                        ON e.job_id = j.job_id
                              WHERE e.manager_id = (SELECT employee_id
                                                      FROM employees AS e1
                                                     WHERE e1.first_name = in_first_name
                                                       AND e1.last_name = in_last_name);

    RETURN employee_cursor;
END;
$$;

DO
$$
    DECLARE
        employee_cursor REFCURSOR;
        employee        RECORD;
    BEGIN
        employee_cursor := func6('Matthew', 'Weiss');

        LOOP
            FETCH NEXT FROM employee_cursor INTO employee;
            EXIT WHEN NOT found;
            IF employee.job_title = 'Stock Clerk' THEN
                RAISE INFO '% %', employee.first_name, employee.last_name;
            END IF;
        END LOOP;

        CLOSE employee_cursor;

        ROLLBACK;
    END;
$$;


-- 7. Utwórz wyzwalacz, który przed dodaniem pracownika sprawdzi, czy data zatrudnienia jest przyszłą datą.
--    Jeżeli warunek jest spełniony, to wyświetli tylko komunikat "Niedozwolona operacja!".
--    Jeżeli warunek nie jest spełniony, to doda pracownika.
--    Potwierdź działanie dla dwóch przypadków testowych.
--    Uwaga! W niektórych systemach wymagane jest utworzenie własnej funkcji i/lub widoku tabeli pracownicy.

-- PostgreSQL
CREATE OR REPLACE VIEW employees_view
AS
SELECT *
  FROM employees;

CREATE OR REPLACE FUNCTION check_hire_date() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    IF new.hire_date > CURRENT_TIMESTAMP THEN
        RAISE NOTICE 'Niedozwolona operacja!';
    ELSE
        INSERT INTO employees
        VALUES (new.employee_id, new.first_name, new.last_name, new.email, new.phone_number, new.hire_date, new.job_id,
                new.salary, new.commission_pct, new.manager_id, new.department_id);
    END IF;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE TRIGGER check_hire_date
    INSTEAD OF INSERT
    ON employees_view
    FOR EACH ROW
EXECUTE FUNCTION check_hire_date();


BEGIN;

INSERT INTO employees_view (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (1, 'Jan', 'Kowalski', 'jan.kowalski2@example.com', CURRENT_DATE + INTERVAL '1 day', 'IT_PROG');
SELECT *
  FROM employees
 WHERE employee_id = 1;

ROLLBACK;


BEGIN;

INSERT INTO employees_view (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (2, 'Jan', 'Kowalski', 'jan.kowalski@example.com', CURRENT_DATE, 'IT_PROG');
SELECT *
  FROM employees
 WHERE employee_id = 2;

ROLLBACK;


-- 8. Utwórz wyzwalacz, który po usunięciu jednego lub wielu miast za pomocą pojedynczego polecenia wypisze ich nazwy
--    oraz nazwy ich krajów.
--    Potwierdź działanie poprzez usunięcie wszystkich miast, w których żaden departament nie ma swojej siedziby.
--    Uwaga! W niektórych systemach wymagane jest utworzenie kursora lub własnej funkcji.

-- PostgreSQL
CREATE OR REPLACE FUNCTION print_deleted_country_info() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    RAISE NOTICE '%, %', old.city, (SELECT c.country_name FROM countries AS c WHERE c.country_id = old.country_id);
    RETURN NULL;
END;
$$;

CREATE OR REPLACE TRIGGER print_deleted_country_info
    AFTER DELETE
    ON locations
    FOR EACH ROW
EXECUTE FUNCTION print_deleted_country_info();

BEGIN;
DELETE
  FROM locations AS l
 WHERE (SELECT COUNT(*) FROM departments AS d WHERE d.location_id = l.location_id) = 0;
ROLLBACK;


-- 9. Utwórz wyzwalacz, który przed podwyższeniem prowizji menadżera departamentu sprawdzi jej nową wartość.
--    Jeżeli nowa prowizja jest co najmniej dwukrotnie większa od poprzedniej, to zmniejszy jej nową wartość
--    do dwukrotności poprzedniej wartości. Jeżeli menadżer departamentu nie miał wcześniej przypisanej prowizji,
--    nowa wartość może wynieść maksymalnie 0,1. Potwierdź działanie wyzwalacza aktualizując wybranych pracowników
--    z departamentów o id równym 20 i 80.
--    Uwaga! W niektórych systemach wymagane jest utworzenie własnej funkcji.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje wyzwalacz BEFORE, wykorzystaj wyzwalacz INSTEAD OF.

-- PostgreSQL
CREATE OR REPLACE FUNCTION process_manager_salary_increase() RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    IF EXISTS (SELECT * FROM employees WHERE manager_id = new.employee_id) THEN
        IF new.salary >= old.salary * 2 THEN new.salary := old.salary * 2; END IF;
        IF old.commission_pct IS NULL AND new.commission_pct > 0.1 THEN new.commission_pct := 0.1; END IF;
    END IF;

    RETURN new;
END;
$$;


CREATE OR REPLACE TRIGGER process_manager_salary_increase
    BEFORE UPDATE
    ON employees
    FOR EACH ROW
EXECUTE FUNCTION process_manager_salary_increase();


BEGIN;
SELECT *
  FROM employees
 WHERE department_id = 20;

UPDATE employees
   SET salary = 200000,
       commission_pct = 0.5
 WHERE employee_id = 201;

UPDATE employees
   SET salary = 200000,
       commission_pct = 0.5
 WHERE employee_id = 202;

SELECT *
  FROM employees
 WHERE department_id = 20;
ROLLBACK;


BEGIN;
SELECT *
  FROM employees
 WHERE department_id = 80
   AND (employee_id = 145 OR employee_id = 146);

UPDATE employees
   SET salary = 16000,
       commission_pct = 0.9
 WHERE employee_id = 145;

UPDATE employees
   SET salary = 200000,
       commission_pct = 0.5
 WHERE employee_id = 146;

SELECT *
  FROM employees
 WHERE department_id = 80
   AND (employee_id = 145 OR employee_id = 146);
ROLLBACK;
