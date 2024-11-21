-- 1. Utwórz funkcję, która zwróci liczbę pracowników zatrudnionych na określonym stanowisku
-- w określonym dziale w określonym kraju. Nazwa stanowiska, nazwa działu i nazwa kraju są
-- przekazywane do funkcji jako parametry. Wywołaj funkcję z parametrami Sales Manager, Sales
-- i United Kingdom.

CREATE OR REPLACE FUNCTION function1(varchar(35), varchar(30), varchar(40)) RETURNS integer AS $$
	BEGIN
		RETURN (
			SELECT COUNT(e.employee_id) FROM employees e
			JOIN departments d ON d.department_id = e.department_id
			JOIN jobs j ON j.job_id = e.job_id
			JOIN locations l ON l.location_id = d.location_id
			JOIN countries c ON c.country_id = l.country_id
			WHERE LOWER(j.job_title) = LOWER($1)
			AND LOWER(d.department_name) = LOWER($2)
			AND LOWER(c.country_name) = LOWER($3)
		);
	END; $$
	LANGUAGE plpgsql;

select * from function1('Sales Manager', 'Sales', 'United Kingdom');

/* 2. Utwórz wyzwalacz, który przy zmianie stanowiska danego pracownika:
– zaktualizuje jego datę zatrudnienia w tabeli employees na dzień jutrzejszy,
– zarchiwizuje dane o jego poprzednim stanowisku, tzn. doda odpowiednie informacje do tabeli job_history
i ustawi datę końcową na dzień dzisiejszy,
– sprawdzi, czy jego aktualne wynagrodzenie należy do zdefiniowanego przedziału wartości wynagrodzeń dla
jego nowego stanowiska. Jeżeli jego aktualne wynagrodzenie jest niższe niż minimalna wartość przedziału,
to zostanie zaktualizowane do tejże wartości. Dodatkowo zostanie wypisana informacja o imieniu i nazwisku
pracownika oraz kwocie jego podwyżki (różnicy pomiędzy nową i starą kwotą wynagrodzenia). Jeżeli jego
aktualne wynagrodzenie jest wyższe niż maksymalna wartość przedziału, to maksymalne wynagrodzenie dla
jego nowego stanowiska zostanie zaktualizowane do wartości jego aktualnego wynagrodzenia.
Potwierdź działanie dla wszystkich przypadków testowych.
Uwaga! Wyzwalacz powinien pracować także przy zmianie stanowiska dla wielu pracowników jednocześnie.*/

CREATE OR REPLACE FUNCTION job_update() RETURNS TRIGGER
AS
$$
DECLARE
    min_s NUMERIC(10, 2);
    max_s NUMERIC(10, 2);
BEGIN
    IF NEW.job_id <> OLD.job_id THEN
        UPDATE employees SET hire_date = NOW() + INTERVAL '1 DAY'
        WHERE employee_id = NEW.employee_id;

		IF NOT EXISTS (SELECT 1
					   FROM job_history AS jh
					   WHERE jh.employee_id = OLD.employee_id
						   AND jh.start_date = OLD.hire_date)

		THEN INSERT INTO job_history
        (employee_id, start_date, end_date, job_id, department_id)
        VALUES
            (OLD.employee_id, OLD.hire_date, NOW(), OLD.job_id, OLD.department_id);
		END IF;

        SELECT jobs.min_salary, jobs.max_salary INTO min_s, max_s FROM jobs
		WHERE jobs.job_id LIKE NEW.job_id;
        IF NEW.salary < min_s THEN
            UPDATE employees SET salary = min_s
            WHERE employee_id = NEW.employee_id;
            RAISE NOTICE 'Pracownik % % otrzymał podwyżkę o %', OLD.first_name, OLD.last_name, min_s - OLD.salary;
        ELSIF NEW.salary > max_s THEN
            UPDATE jobs SET max_salary = NEW.salary WHERE job_id = NEW.job_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_update_job
    AFTER UPDATE
        OF job_id ON employees
    FOR EACH ROW EXECUTE FUNCTION job_update();

-- TESTY

SELECT e.hire_date, e.job_id
FROM employees AS e
WHERE e.employee_id = 101;

SELECT jh.start_date, jh.end_date, jh.job_id
FROM job_history AS jh
WHERE employee_id = 101;

UPDATE employees
SET job_id = 'AC_ACCOUNT'
WHERE employee_id = 101;

SELECT e.hire_date, e.job_id
FROM employees AS e
WHERE e.employee_id = 101;

SELECT jh.start_date, jh.end_date, jh.job_id
FROM job_history AS jh
WHERE employee_id = 101;

/* 3. Utwórz procedurę, która zmieni stanowisko na podane u pracowników zatrudnionych na określonym
stanowisku w określonym kraju i poprzez parametr wyjściowy zwróci liczbę zmodyfikowanych rekordów oraz
wyświetli id, imię, nazwisko i nazwę departamentu pracowników, których stanowisko zostało zmienione.
Dodatkowo wypisze informacje o wszystkich departamentach z danego kraju razem z listą ich pracowników
(id, imię i nazwisko), których stanowisko zostało zmienione. Jeżeli w jakimś departamencie w danym kraju
nie pracuje żaden pracownik na danym stanowisku, wywoła jak najwyższy priorytetowo komunikat, który nie
przerwie wykonywania kodu i wypisze: "Brak pracowników na stanowisku X w departamencie Y w kraju Z!", gdzie
X jest nazwą poprzedniego stanowiska, Y jest nazwą aktualnie sprawdzanego departamentu, Z jest nazwą
podanego kraju.
Procedura ma także weryfikować podane dane. Jeżeli podany kraj nie istnieje, wywoła wyjątek, który
przerwie wykonywanie kodu i wypisze: "Brak kraju X!", gdzie X to nazwa podanego kraju. Jeżeli w podanym
kraju nie ma żadnego departamentu, wywoła wyjątek, który przerwie wykonywanie kodu i wypisze: "Brak
departamentów w kraju X!", gdzie X to nazwa podanego kraju. Jeżeli w podanym kraju nie pracuje żaden
pracownik, wywoła wyjątek, który przerwie wykonywanie kodu i wypisze: "Brak pracowników zatrudnionych
w kraju X!", gdzie X to nazwa podanego kraju.
W swoim rozwiązaniu wykorzystaj funkcję z zadania 1 oraz wyzwalacz z zadania 2. Wywołaj procedurę z
nazwami stanowisk Sales Manager i Sales Representative oraz odpowiednią nazwą kraju, żeby przetestować
wszystkie możliwe przypadki. */

CREATE OR REPLACE PROCEDURE modify_role(target_job_title varchar(35), previous_job_title varchar(35),
country varchar(40), OUT modified_count int)
AS $$
DECLARE
    employees_cursor CURSOR FOR
        SELECT e.employee_id, e.first_name, e.last_name, d.department_name
		FROM employees AS e
        JOIN departments AS d ON e.department_id = d.department_id
        JOIN locations AS l ON d.location_id = l.location_id
        JOIN countries AS c ON l.country_id = c.country_id
		JOIN jobs AS j ON e.job_id = j.job_id
        WHERE LOWER(c.country_name) LIKE LOWER(country)
		AND LOWER(j.job_title) LIKE LOWER(previous_job_title);

	departments_cursor CURSOR FOR
		SELECT DISTINCT d.department_name FROM departments AS d
		JOIN locations AS l ON d.location_id = l.location_id
		JOIN countries AS c ON l.country_id = c.country_id
		JOIN employees AS e ON e.department_id = d.department_id
		JOIN jobs AS j ON j.job_id = e.job_id
		WHERE LOWER(c.country_name) LIKE LOWER(country);

    employee_record RECORD;
	dep_name varchar(30);
	emp_count int;
	target_job_id varchar(35);
    previous_job_id varchar(35);
	country_exists boolean;
    department_exists boolean;
    employee_exists boolean;
BEGIN
    SELECT job_id INTO target_job_id
    FROM jobs
    WHERE LOWER(job_title) = LOWER(target_job_title);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Stanowisko docelowe % nie istnieje!', target_job_title;
    END IF;

    SELECT job_id INTO previous_job_id
    FROM jobs
    WHERE LOWER(job_title) = LOWER(previous_job_title);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Stanowisko poprzednie % nie istnieje!', previous_job_title;
    END IF;

	SELECT EXISTS (
        SELECT 1
        FROM countries
        WHERE LOWER(country_name) LIKE LOWER(country)
    ) INTO country_exists;

    IF NOT country_exists THEN
        RAISE EXCEPTION 'Brak kraju %!', country;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM departments AS d
        JOIN locations AS l ON d.location_id = l.location_id
        JOIN countries AS c ON l.country_id = c.country_id
        WHERE LOWER(c.country_name) LIKE LOWER(country)
    ) INTO department_exists;

    IF NOT department_exists THEN
        RAISE EXCEPTION 'Brak departamentów w kraju %!', country;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM employees AS e
        JOIN departments AS d ON e.department_id = d.department_id
        JOIN locations AS l ON d.location_id = l.location_id
        JOIN countries AS c ON l.country_id = c.country_id
        WHERE LOWER(c.country_name) LIKE LOWER(country)
    ) INTO employee_exists;

    IF NOT employee_exists THEN
        RAISE EXCEPTION 'Brak pracowników zatrudnionych w kraju %!', country;
    END IF;

	OPEN departments_cursor;
		LOOP
			FETCH departments_cursor INTO dep_name;
	        EXIT WHEN NOT FOUND;
			emp_count := function1(previous_job_title, dep_name, country);

			IF emp_count = 0 THEN
	            RAISE WARNING 'Brak pracowników na stanowisku % w departamencie % w kraju %!',
	                previous_job_title, dep_name, country;
	        END IF;
		END LOOP;
	CLOSE departments_cursor;

	modified_count = 0;

	OPEN employees_cursor;
	    LOOP
	        FETCH employees_cursor INTO employee_record;
	        EXIT WHEN NOT FOUND;
			UPDATE employees
				SET job_id = target_job_id
				WHERE employee_id = employee_record.employee_id;

	        modified_count = modified_count + 1;
	        RAISE NOTICE 'ID: % imie: %, nazwisko %, nazwa departamentu: %', employee_record.employee_id,
	            employee_record.first_name, employee_record.last_name, employee_record.department_name;
	    END LOOP;
	CLOSE employees_cursor;
END;
$$ LANGUAGE plpgsql;


-- TESTY

-- Przypadek: Kraj istnieje, pracownicy i departamenty istnieją, następuje zmiana stanowisk
DO $$
DECLARE
    records_count int;
BEGIN
    CALL modify_role('Sales Manager', 'Sales Representative', 'United Kingdom', records_count);
    RAISE NOTICE 'Liczba zmienionych rekordów: %', records_count;
    ROLLBACK;
END $$;

-- Przypadek: Brak kraju %
DO $$
DECLARE
    records_count int;
BEGIN
    CALL modify_role('Sales Manager', 'Sales Representative', 'Nonexistent Country', records_count);
    RAISE NOTICE 'Liczba zmienionych rekordów: %', records_count;
    ROLLBACK;
END $$;

-- Przypadek: Brak departamentów w kraju %
DO $$
DECLARE
    records_count int;
BEGIN
    CALL modify_role('Sales Manager', 'Sales Representative', 'Japan', records_count);
    RAISE NOTICE 'Liczba zmienionych rekordów: %', records_count;
    ROLLBACK;
END $$;

-- Przypadek: Brak pracowników na stanowisku % w departamencie % w kraju %!
DO $$
DECLARE
    records_count int;
BEGIN
    CALL modify_role('Sales Manager', 'Sales Representative', 'Germany', records_count);
    RAISE NOTICE 'Liczba zmienionych rekordów: %', records_count;
    ROLLBACK;
END $$;

-- Przypadek: Stanowisko docelowe % nie istnieje!
DO $$
DECLARE
    records_count int;
BEGIN
    CALL modify_role('Data Scientist', 'Sales Representative', 'Germany', records_count);
    RAISE NOTICE 'Liczba zmienionych rekordów: %', records_count;
    ROLLBACK;
END $$;

-- Przypadek: Stanowisko poprzednie % nie istnieje!
DO $$
DECLARE
    records_count int;
BEGIN
    CALL modify_role('Sales Manager', 'Data Scientist', 'Germany', records_count);
    RAISE NOTICE 'Liczba zmienionych rekordów: %', records_count;
    ROLLBACK;
END $$;