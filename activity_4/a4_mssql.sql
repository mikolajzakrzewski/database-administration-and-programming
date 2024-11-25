-- 1. Utwórz procedurę proc1, która z wykorzystaniem kursora wypisze nazwy miast, w których realne maksymalne zarobki
--    pracowników są niższe od podanej kwoty.
--    Wywołaj ją z parametrem 10000.

-- Microsoft SQL Server
CREATE OR ALTER PROCEDURE proc1 @max_salary NUMERIC(8, 2) AS
DECLARE @temp_city VARCHAR(30);
DECLARE
    location_cursor CURSOR FOR SELECT l.city
                                 FROM locations AS l
                                          JOIN departments AS d
                                          ON l.location_id = d.location_id
                                          JOIN employees AS e
                                          ON d.department_id = e.department_id
                                GROUP BY l.city
                               HAVING MAX(e.salary) < @max_salary;
BEGIN
    OPEN location_cursor;
    FETCH NEXT FROM location_cursor INTO @temp_city;

    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT @temp_city;
        FETCH NEXT FROM location_cursor INTO @temp_city;
    END;

    CLOSE location_cursor;
    DEALLOCATE location_cursor;
END;
GO


BEGIN TRANSACTION;

EXECUTE proc1 @max_salary = 10000;

ROLLBACK;


-- 2. Utwórz procedurę proc2, która dodaje informacje o nowym departamencie do bazy danych.
--    ID nowego departamentu musi być automatycznie wyliczane zgodnie z zasadą nadawania ID dla departamentów.
--    Nazwa departamentu musi być podana jako parametr procedury.
--    ID menadżera domyślnie nie ma wpisywanej wartości, ale można ją podać jako parametr procedury.
--    ID lokalizacji ma domyślnie ustawioną wartość 2000, jednakże można podać także inną wartość jako parametr
--    procedury.
--    Wywołaj procedurę proc2 na wszystkie możliwe sposoby, żeby przetestować działanie parametrów domyślnych.

-- Microsoft SQL Server
CREATE OR ALTER PROCEDURE proc2 @department_name VARCHAR(30), @manager_id NUMERIC(6) = NULL,
                                @location_id NUMERIC(4) = 2000 AS
BEGIN
    INSERT INTO departments
    VALUES ((SELECT MAX(department_id) + 10 FROM departments), @department_name, @manager_id, @location_id)
END;
GO


BEGIN TRANSACTION;

EXECUTE proc2 @department_name = 'Nowy departament';
SELECT *
  FROM departments
 ORDER BY department_id DESC;

ROLLBACK;


BEGIN TRANSACTION;

EXECUTE proc2 @department_name = 'Nowy departament', @manager_id = 101;
SELECT *
  FROM departments
 ORDER BY department_id DESC;

ROLLBACK;


BEGIN TRANSACTION;

EXECUTE proc2 @department_name = 'Nowy departament', @location_id = 1000;
SELECT *
  FROM departments
 ORDER BY department_id DESC;

ROLLBACK;


BEGIN TRANSACTION;

EXECUTE proc2 @department_name = 'Nowy departament', @manager_id = 101, @location_id = 1000;
SELECT *
  FROM departments
 ORDER BY department_id DESC;

ROLLBACK;


-- 3. Utwórz procedurę proc3, która podwyższy prowizję o podaną liczbę punktów procentowych u pracowników zatrudnionych
--    przed podanym rokiem i poprzez parametr wyjściowy zwróci liczbę zmodyfikowanych rekordów.
--    Wywołaj ją z parametrami 2004 oraz 0.05.

-- Microsoft SQL Server
CREATE OR ALTER PROCEDURE proc3 @percentage_points NUMERIC(2, 2), @year_limit INT, @modified_records_count INT OUT AS
BEGIN
    UPDATE employees
       SET commission_pct = COALESCE(commission_pct, 0) + @percentage_points
     WHERE DATEPART(YEAR, hire_date) < @year_limit;

    SET @modified_records_count = @@ROWCOUNT;
END;
GO


BEGIN TRANSACTION;

DECLARE @modified_records_count INT;
EXECUTE proc3 @percentage_points = 0.05, @year_limit = 2004, @modified_records_count = @modified_records_count OUTPUT;
PRINT N'Liczba zmodyfikowanych rekordów: ' + CAST(@modified_records_count AS VARCHAR);

ROLLBACK;


-- 4. Utwórz funkcję func4, która zwróci procentowy udział liczby pracowników zatrudnionych w podanym departamencie
--    w łącznej liczbie wszystkich pracowników.
--    Wynik zaokrąglij do części setnych.
--    Wywołaj ją dla wszystkich departamentów wewnątrz zapytania dającego wynik w postaci trzech kolumn: department_id,
--    department_name, percentage.

-- Microsoft SQL Server
CREATE OR ALTER FUNCTION func4(@department_name VARCHAR(30)) RETURNS NUMERIC(4, 2) AS
BEGIN
    DECLARE @department_employees_count INT, @total_employees_count INT;

    SELECT @department_employees_count = COUNT(*)
      FROM employees AS e
               JOIN departments AS d
               ON e.department_id = d.department_id
     WHERE d.department_name = @department_name;

    SELECT @total_employees_count = COUNT(*) FROM employees;

    RETURN ROUND(@department_employees_count * 100.0 / @total_employees_count, 2);
END;
GO


BEGIN TRANSACTION;

SELECT department_id, department_name, dbo.func4(department_name) AS percentage
  FROM departments;

ROLLBACK;


-- 5. Utwórz funkcję func5, która zwróci wszystkie informacje o departamentach mających siedzibę w podanym kraju.
--    Wywołaj ją z parametrem Canada wewnątrz zapytania dającego wynik w postaci dwóch kolumn: department_id,
--    department_name.

-- Microsoft SQL Server
CREATE OR ALTER FUNCTION func5(@country_name VARCHAR(40))
    RETURNS TABLE AS RETURN(SELECT d.*
                              FROM departments AS d
                                       JOIN locations AS l
                                       ON d.location_id = l.location_id
                                       JOIN countries AS c
                                       ON l.country_id = c.country_id
                             WHERE c.country_name = @country_name);
GO


BEGIN TRANSACTION;

SELECT department_id, department_name
  FROM func5('Canada')

ROLLBACK;


-- 6. Utwórz funkcję func6, która zwróci kursor z informacjami o pracownikach (imię, nazwisko oraz nazwa stanowiska),
--    których menadżerem jest podany pracownik.
--    Wywołaj ją z parametrami "Matthew" i "Weiss".
--    Następnie wypisz spośród nich tylko tych pracowników (ich imiona i nazwiska), którzy zajmują stanowisko
--    Stock Clerk.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje funkcja zwracająca kursor, wykorzystaj funkcję zwracającą tabelę
--    oraz kursor.

-- Microsoft SQL Server
CREATE OR ALTER FUNCTION func6(@first_name VARCHAR(20), @last_name VARCHAR(25))
    RETURNS TABLE AS RETURN(SELECT e.first_name, e.last_name, j.job_title
                              FROM employees AS e
                                       JOIN jobs AS j
                                       ON e.job_id = j.job_id
                             WHERE e.manager_id = (SELECT e1.employee_id
                                                     FROM employees AS e1
                                                    WHERE e1.first_name = @first_name AND e1.last_name = @last_name));
GO

DECLARE @first_name VARCHAR(20), @last_name VARCHAR(25), @job_title VARCHAR(35);
DECLARE employee_cursor CURSOR FOR SELECT *
                                     FROM func6('Matthew', 'Weiss');

BEGIN
    OPEN employee_cursor;
    FETCH NEXT FROM employee_cursor INTO @first_name, @last_name, @job_title;

    WHILE @@FETCH_STATUS = 0 BEGIN
        IF @job_title = 'Stock Clerk' PRINT @first_name + ' ' + @last_name;

        FETCH NEXT FROM employee_cursor INTO @first_name, @last_name, @job_title;
    END;

    CLOSE employee_cursor;
    DEALLOCATE employee_cursor;
END;
GO


-- 7. Utwórz wyzwalacz, który przed dodaniem pracownika sprawdzi, czy data zatrudnienia jest przyszłą datą.
--    Jeżeli warunek jest spełniony, to wyświetli tylko komunikat "Niedozwolona operacja!".
--    Jeżeli warunek nie jest spełniony, to doda pracownika.
--    Potwierdź działanie dla dwóch przypadków testowych.
--    Uwaga! W niektórych systemach wymagane jest utworzenie własnej funkcji i/lub widoku tabeli pracownicy.

-- Microsoft SQL Server
CREATE OR ALTER TRIGGER check_hire_date
    ON employees
    INSTEAD OF INSERT AS
BEGIN
    IF (SELECT hire_date FROM inserted) > GETDATE()
        PRINT 'Niedozwolona operacja!'
    ELSE
        INSERT INTO employees SELECT * FROM inserted
END;
GO


BEGIN TRANSACTION;

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (1, 'Jan', 'Kowalski', 'jan.kowalski2@example.com', DATEADD(DAY, 1, GETDATE()), 'IT_PROG');

SELECT *
  FROM employees
 WHERE employee_id = 1;

ROLLBACK;


BEGIN TRANSACTION;

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (2, 'Jan', 'Kowalski', 'jan.kowalski@example.com', GETDATE(), 'IT_PROG');

SELECT *
  FROM employees
 WHERE employee_id = 2;

ROLLBACK;


-- 8. Utwórz wyzwalacz, który po usunięciu jednego lub wielu miast za pomocą pojedynczego polecenia wypisze ich nazwy
--    oraz nazwy ich krajów.
--    Potwierdź działanie poprzez usunięcie wszystkich miast, w których żaden departament nie ma swojej siedziby.
--    Uwaga! W niektórych systemach wymagane jest utworzenie kursora lub własnej funkcji.

-- Microsoft SQL Server
CREATE OR ALTER TRIGGER print_deleted_country_info
    ON locations
    AFTER DELETE AS
BEGIN
    DECLARE @city_name VARCHAR(30), @country_name VARCHAR(40);
    DECLARE location_cursor CURSOR FOR SELECT d.city, c.country_name
                                         FROM deleted AS d
                                                  JOIN countries AS c
                                                  ON d.country_id = c.country_id;

    OPEN location_cursor;
    FETCH NEXT FROM location_cursor INTO @city_name, @country_name;

    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT @city_name + ', ' + @country_name;

        FETCH NEXT FROM location_cursor INTO @city_name, @country_name;
    END

    CLOSE location_cursor;
    DEALLOCATE location_cursor;
END;
GO


BEGIN TRANSACTION;

DELETE
  FROM locations
 WHERE location_id IN (SELECT l.location_id
                         FROM locations AS l
                                  LEFT JOIN departments AS d
                                  ON l.location_id = d.location_id
                        WHERE d.department_id IS NULL)

ROLLBACK;


-- 9. Utwórz wyzwalacz, który przed podwyższeniem prowizji menadżera departamentu sprawdzi jej nową wartość.
--    Jeżeli nowa prowizja jest co najmniej dwukrotnie większa od poprzedniej, to zmniejszy jej nową wartość
--    do dwukrotności poprzedniej wartości. Jeżeli menadżer departamentu nie miał wcześniej przypisanej prowizji,
--    nowa wartość może wynieść maksymalnie 0,1. Potwierdź działanie wyzwalacza aktualizując wybranych pracowników
--    z departamentów o id równym 20 i 80.
--    Uwaga! W niektórych systemach wymagane jest utworzenie własnej funkcji.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje wyzwalacz BEFORE, wykorzystaj wyzwalacz INSTEAD OF.

-- Microsoft SQL Server
CREATE OR ALTER TRIGGER process_manager_salary_increase
    ON employees
    INSTEAD OF UPDATE AS
BEGIN
    DECLARE @employee_id NUMERIC(6), @first_name VARCHAR(20), @last_name VARCHAR(25), @email VARCHAR(25), @phone_number VARCHAR(20), @hire_date DATE, @job_id VARCHAR(10), @manager_id NUMERIC(6), @department_id NUMERIC(4), @old_salary NUMERIC(8, 2), @old_commission_pct NUMERIC(2, 2), @new_salary NUMERIC(8, 2), @new_commission_pct NUMERIC(2, 2);
    DECLARE employee_cursor CURSOR FOR SELECT i.employee_id, i.first_name, i.last_name, i.email, i.phone_number,
                                              i.hire_date, i.job_id, i.manager_id, i.department_id, d.salary,
                                              d.commission_pct, i.salary, i.commission_pct
                                         FROM deleted AS d
                                                  JOIN inserted AS i
                                                  ON d.employee_id = i.employee_id;

    OPEN employee_cursor;
    FETCH NEXT FROM employee_cursor INTO @employee_id, @first_name, @last_name, @email, @phone_number, @hire_date, @job_id, @manager_id, @department_id, @old_salary, @old_commission_pct, @new_salary, @new_commission_pct;

    WHILE @@FETCH_STATUS = 0 BEGIN
        IF EXISTS (SELECT * FROM employees WHERE manager_id = @employee_id)
            BEGIN
                IF @new_salary > 2 * @old_salary SET @new_salary = 2 * @old_salary;

                IF @old_commission_pct IS NULL AND @new_commission_pct > 0.1 SET @new_commission_pct = 0.1;
            END;

        UPDATE employees
           SET first_name = @first_name,
               last_name = @last_name,
               email = @email,
               phone_number = @phone_number,
               hire_date = @hire_date,
               job_id = @job_id,
               salary = @new_salary,
               commission_pct = @new_commission_pct,
               manager_id = @manager_id,
               department_id = @department_id
         WHERE employee_id = @employee_id;

        FETCH NEXT FROM employee_cursor INTO @employee_id, @first_name, @last_name, @email, @phone_number, @hire_date, @job_id, @manager_id, @department_id, @old_salary, @old_commission_pct, @new_salary, @new_commission_pct;
    END;

    CLOSE employee_cursor;
    DEALLOCATE employee_cursor;
END;
GO


BEGIN TRANSACTION;
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


BEGIN TRANSACTION;
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
