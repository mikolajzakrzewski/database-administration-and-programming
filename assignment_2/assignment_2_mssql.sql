-- Zadanie 1

-- Utwórz funkcję, która zwróci liczbę pracowników zatrudnionych na określonym stanowisku w określonym dziale
-- w określonym kraju. Nazwa stanowiska, nazwa działu i nazwa kraju są przekazywane do funkcji jako parametry.
-- Wywołaj funkcję z parametrami Sales Manager, Sales i United Kingdom.

-- Microsoft SQL Server
CREATE OR ALTER FUNCTION dbo.GetEmployeesNumberByPositionDepartmentAndCountry (
    @JobTitle VARCHAR(35), @DepartmentName VARCHAR(30), @CountryName VARCHAR(40)
)
RETURNS INTEGER
AS
BEGIN
    RETURN (
        SELECT COUNT(e.employee_id)
        FROM jobs AS j
        JOIN employees AS e
            ON j.job_id = e.job_id
        JOIN departments AS d
            ON e.department_id = d.department_id
        JOIN locations AS l
            ON d.location_id = l.location_id
        JOIN countries AS c
            ON c.country_id = l.country_id
        WHERE j.job_title = @JobTitle
            AND d.department_name = @DepartmentName
            AND c.country_name = @CountryName
    );
END;
GO

SELECT dbo.GetEmployeesNumberByPositionDepartmentAndCountry(
               'Sales Manager', 'Sales', 'United Kingdom'
       ) AS employees_no;


-- Zadanie 2

-- Utwórz wyzwalacz, który przy zmianie stanowiska danego pracownika:
--     – zaktualizuje jego datę zatrudnienia w tabeli employees na dzień jutrzejszy,
--     – zarchiwizuje dane o jego poprzednim stanowisku, tzn. doda odpowiednie informacje do tabeli job_history i ustawi
--       datę końcową na dzień dzisiejszy,
--     – sprawdzi, czy jego aktualne wynagrodzenie należy do zdefiniowanego przedziału wartości wynagrodzeń dla jego
--       nowego stanowiska. Jeżeli jego aktualne wynagrodzenie jest niższe niż minimalna wartość przedziału, to zostanie
--       zaktualizowane do tejże wartości. Dodatkowo zostanie wypisana informacja o imieniu i nazwisku pracownika
--       oraz kwocie jego podwyżki (różnicy pomiędzy nową i starą kwotą wynagrodzenia). Jeżeli jego aktualne
--       wynagrodzenie jest wyższe niż maksymalna wartość przedziału, to maksymalne wynagrodzenie dla jego nowego
--       stanowiska zostanie zaktualizowane do wartości jego aktualnego wynagrodzenia.
-- Potwierdź działanie dla wszystkich przypadków testowych.
-- Uwaga! Wyzwalacz powinien pracować także przy zmianie stanowiska dla wielu pracowników jednocześnie.

-- Microsoft SQL Server
CREATE OR ALTER TRIGGER UpdateEmployeeOnPositionChange
    ON dbo.employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(job_id)
    BEGIN
        UPDATE employees
        SET hire_date = DATEADD(DAY, 1, CAST(CURRENT_TIMESTAMP AS DATE))
        WHERE employee_id IN (
            SELECT i.employee_id
            FROM inserted AS i
        );

        DECLARE
            @EmployeeId NUMERIC(6),
            @StartDate DATE,
            @EndDate DATE,
            @JobId VARCHAR(10),
            @DepartmentId NUMERIC(4);
        DECLARE job_history_cursor CURSOR FOR
            SELECT d.employee_id, d.hire_date, CAST(CURRENT_TIMESTAMP AS DATE), d.job_id, d.department_id
            FROM deleted AS d;
        BEGIN
            OPEN job_history_cursor;
            FETCH NEXT FROM job_history_cursor INTO @EmployeeId, @StartDate, @EndDate, @JobId, @DepartmentId;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                IF NOT EXISTS (SELECT 1
                               FROM job_history AS jh
                               WHERE jh.employee_id = @EmployeeId
                                   AND jh.start_date = @StartDate)
                BEGIN
                    INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
                    VALUES (@EmployeeId,
                            @StartDate,
                            @EndDate,
                            @JobId,
                            @DepartmentId
                    );
                END;
                FETCH NEXT FROM job_history_cursor INTO @EmployeeId, @StartDate, @EndDate, @JobId, @DepartmentId;
            END;

            CLOSE job_history_cursor;
            DEALLOCATE job_history_cursor;
        END;

        DECLARE
            @FirstName VARCHAR(20),
            @LastName VARCHAR(20),
            @NewSalary NUMERIC(8,2),
            @OldSalary NUMERIC(8,2),
            @JobMinSalary NUMERIC(6),
            @JobMaxSalary NUMERIC(6);
        DECLARE salary_cursor CURSOR FOR
            SELECT i.employee_id, i.first_name, i.last_name, i.salary, i.job_id, d.salary, j.min_salary, j.max_salary
            FROM inserted AS i
            JOIN deleted AS d
                ON d.employee_id = i.employee_id
            JOIN jobs AS j
                ON i.job_id = j.job_id;
        BEGIN
            OPEN salary_cursor;
            FETCH NEXT FROM salary_cursor INTO @EmployeeId, @FirstName, @LastName, @NewSalary,
                                               @JobId, @OldSalary, @JobMinSalary, @JobMaxSalary;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                IF @NewSalary < @JobMinSalary
                    BEGIN
                        UPDATE employees
                        SET salary = @JobMinSalary
                        WHERE employee_id = @EmployeeId;

                        PRINT 'Zmiana wynagrodzenia pracownika ' + @FirstName + ' ' + @LastName +
                              ': ' + CAST((@JobMinSalary - @OldSalary) AS VARCHAR);
                    END;
                ELSE
                    IF @NewSalary > @JobMaxSalary
                        BEGIN
                            UPDATE jobs
                            SET max_salary = @NewSalary
                            WHERE job_id = @JobId;
                        END;

                FETCH NEXT FROM salary_cursor INTO @EmployeeId, @FirstName, @LastName, @NewSalary,
                                                   @JobId, @OldSalary, @JobMinSalary, @JobMaxSalary;
            END;

            CLOSE salary_cursor;
            DEALLOCATE salary_cursor;
        END;
    END;
END;
GO


-- Alternative
CREATE OR ALTER TRIGGER UpdateEmployeeOnPositionChange
ON dbo.employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(job_id)
    BEGIN
        UPDATE employees
        SET hire_date = DATEADD(DAY, 1, CAST(CURRENT_TIMESTAMP AS DATE))
        WHERE employee_id IN (
            SELECT i.employee_id
            FROM inserted AS i
        );

        INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
        SELECT d.employee_id, d.hire_date, CAST(CURRENT_TIMESTAMP AS DATE), d.job_id, d.department_id
        FROM deleted AS d
        WHERE NOT EXISTS (SELECT 1
                          FROM job_history AS jh
                          WHERE jh.employee_id = d.employee_id
                              AND jh.start_date = d.hire_date);

        UPDATE e
        SET e.salary = j.min_salary
        FROM employees e
        JOIN inserted AS i
            ON e.employee_id = i.employee_id
        JOIN jobs AS j
            ON i.job_id = j.job_id
        WHERE e.salary < j.min_salary;

        DECLARE
            @FirstName VARCHAR(20),
            @LastName VARCHAR(20),
            @SalaryDiff NUMERIC(8,2);
        DECLARE salary_cursor CURSOR FOR
            SELECT i.first_name, i.last_name, (j.min_salary - d.salary)
            FROM inserted AS i
            JOIN jobs AS j
                ON i.job_id = j.job_id
            JOIN deleted AS d
                ON i.employee_id = d.employee_id
            WHERE i.salary < j.min_salary;

        BEGIN
            OPEN salary_cursor;
            FETCH NEXT FROM salary_cursor INTO @FirstName, @LastName, @SalaryDiff;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                PRINT 'Zmiana wynagrodzenia pracownika ' + @FirstName + ' ' + @LastName + ': ' +
                      CAST(@SalaryDiff AS VARCHAR);
                FETCH NEXT FROM salary_cursor INTO @FirstName, @LastName, @SalaryDiff;
            END;

            CLOSE salary_cursor;
            DEALLOCATE salary_cursor;
        END;

        UPDATE j
        SET j.max_salary = i.salary
        FROM jobs j
        JOIN inserted AS i
            ON j.job_id = i.job_id
        WHERE i.salary > j.max_salary;
    END;
END;
GO


-- Przypadek testowy: - aktualizacja daty zatrudnienia zaktualizowanego pracownika na dzień jutrzejszy,
--                    - archiwizacja danych o poprzednim stanowisku zaktualizowanego pracownika
BEGIN TRANSACTION;

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

ROLLBACK;

-- Przypadek testowy: aktualne wynagrodzenie zaktualizowanego pracownika jest niższe niż minimalna wartość przedziału
--                    wynagrodzenia dla jego nowego stanowiska
BEGIN TRANSACTION;

SELECT e.salary, e.job_id
FROM employees AS e
WHERE e.employee_id = 101;

UPDATE employees
SET job_id = 'AC_ACCOUNT', salary = 1
WHERE employee_id = 101;

SELECT e.salary, e.job_id, j.min_salary
FROM employees AS e
JOIN jobs AS j
    ON e.job_id = j.job_id
WHERE e.employee_id = 101;

ROLLBACK;

-- Przypadek testowy: aktualne wynagrodzenie zaktualizowanego pracownika jest wyższe niż maksymalna wartość przedziału
--                    wynagrodzenia dla jego nowego stanowiska
BEGIN TRANSACTION;

SELECT e.salary, e.job_id
FROM employees AS e
WHERE e.employee_id = 101;

UPDATE employees
SET job_id = 'AC_ACCOUNT', salary = 100000
WHERE employee_id = 101;

SELECT e.salary, e.job_id, j.max_salary
FROM employees AS e
JOIN jobs AS j
    ON e.job_id = j.job_id
WHERE e.employee_id = 101;

ROLLBACK;


-- Zadanie 3

-- Utwórz procedurę, która zmieni stanowisko na podane u pracowników zatrudnionych na określonym stanowisku w określonym
-- kraju i poprzez parametr wyjściowy zwróci liczbę zmodyfikowanych rekordów oraz wyświetli id, imię, nazwisko i nazwę
-- departamentu pracowników, których stanowisko zostało zmienione.
-- Dodatkowo wypisze informacje o wszystkich departamentach z danego kraju razem z listą ich pracowników (id, imię
-- i nazwisko), których stanowisko zostało zmienione. Jeżeli w jakimś departamencie w danym kraju nie pracuje żaden
-- pracownik na danym stanowisku, wywoła jak najwyższy priorytetowo komunikat, który nie przerwie wykonywania kodu
-- i wypisze: "Brak pracowników na stanowisku X w departamencie Y w kraju Z!", gdzie X jest nazwą poprzedniego
-- stanowiska, Y jest nazwą aktualnie sprawdzanego departamentu, Z jest nazwą podanego kraju.
-- Procedura ma także weryfikować podane dane. Jeżeli podany kraj nie istnieje, wywoła wyjątek, który przerwie
-- wykonywanie kodu i wypisze: "Brak kraju X!", gdzie X to nazwa podanego kraju. Jeżeli w podanym kraju nie ma żadnego
-- departamentu, wywoła wyjątek, który przerwie wykonywanie kodu i wypisze: "Brak departamentów w kraju X!", gdzie X to
-- nazwa podanego kraju. Jeżeli w podanym kraju nie pracuje żaden pracownik, wywoła wyjątek, który przerwie wykonywanie
-- kodu i wypisze: "Brak pracowników zatrudnionych w kraju X!", gdzie X to nazwa podanego kraju.
-- W swoim rozwiązaniu wykorzystaj funkcję z zadania 1 oraz wyzwalacz z zadania 2. Wywołaj procedurę z nazwami stanowisk
-- Sales Manager i Sales Representative oraz odpowiednią nazwą kraju, żeby przetestować wszystkie możliwe przypadki.

-- Microsoft SQL Server
CREATE OR ALTER PROCEDURE dbo.UpdatePositionByPositionAndCountry
    @NewJob VARCHAR(35),
    @JobToChange VARCHAR(35),
    @Country VARCHAR(40),
    @ModifiedRowsCount INT OUTPUT
AS
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM countries
            WHERE country_name LIKE @Country
        )
            BEGIN
                DECLARE @CountryErrorMessage VARCHAR(255);
                SET @CountryErrorMessage = CONCAT('Brak kraju ', @Country, '!');
                THROW 50000, @CountryErrorMessage, 1;
            END;

        IF NOT EXISTS (
            SELECT 1
            FROM countries AS c
            JOIN locations AS l
                ON c.country_id = l.country_id
            JOIN departments AS d
                ON l.location_id = d.location_id
            WHERE country_name LIKE @Country
        )
            BEGIN
                DECLARE @DepartmentErrorMessage VARCHAR(255);
                SET @DepartmentErrorMessage = CONCAT(N'Brak departamentów w kraju ', @Country, '!');
                THROW 50001, @DepartmentErrorMessage, 1;
            END;

        IF NOT EXISTS (
            SELECT 1
            FROM countries AS c
            JOIN locations AS l
                ON c.country_id = l.country_id
            JOIN departments AS d
                ON l.location_id = d.location_id
            JOIN employees AS e
                ON d.department_id = e.department_id
            JOIN jobs AS j
                ON e.job_id = j.job_id
            WHERE country_name LIKE @Country
                AND j.job_title LIKE @JobToChange
        )
            BEGIN
                DECLARE @EmployeeErrorMessage VARCHAR(255);
                SET @EmployeeErrorMessage = CONCAT(N'Brak pracowników zatrudnionych w kraju ', @Country, '!');
                THROW 50002, @EmployeeErrorMessage, 1;
            END;
    END TRY

    BEGIN CATCH
        THROW;
    END CATCH;

    DECLARE
        @DepartmentName VARCHAR(30);
    DECLARE
        @ModifiedEmployees TABLE (
            employee_id NUMERIC(6),
            first_name VARCHAR(20),
            last_name VARCHAR(20),
            department_name VARCHAR(30)
        );
    DECLARE department_cursor CURSOR FOR
        SELECT d.department_name
        FROM departments AS d
        JOIN locations AS l
            ON d.location_id = l.location_id
        JOIN countries AS c
            ON l.country_id = c.country_id
        WHERE c.country_name = @Country;

    BEGIN
        OPEN department_cursor;
        FETCH NEXT FROM department_cursor INTO @DepartmentName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (SELECT dbo.GetEmployeesNumberByPositionDepartmentAndCountry(
               @JobToChange, @DepartmentName, @Country
                       )) = 0
                BEGIN
                    RAISERROR (
                        N'Brak pracowników na stanowisku %s w departamencie %s w kraju %s!',
                        10,
                        1,
                        @JobToChange,
                        @DepartmentName,
                        @Country
                    );
                END;
            ELSE
                BEGIN
                    DECLARE
                        @EmployeeId NUMERIC(6),
                        @FirstName VARCHAR(20),
                        @LastName VARCHAR(25);
                    DECLARE employee_cursor CURSOR FOR
                        SELECT e.employee_id, e.first_name, e.last_name
                        FROM employees AS e
                        JOIN jobs AS j
                            ON e.job_id = j.job_id
                        JOIN departments AS d
                            ON e.department_id = d.department_id
                        JOIN locations AS l
                            ON d.location_id = l.location_id
                        JOIN countries AS c
                            ON l.country_id = c.country_id
                        WHERE j.job_title = @JobToChange
                            AND d.department_name = @DepartmentName
                            AND c.country_name = @Country;

                    BEGIN
                        PRINT 'Pracownicy departamentu ' + @DepartmentName + ' w kraju ' + @Country + ': ';

                        OPEN employee_cursor;
                        FETCH NEXT FROM employee_cursor INTO @EmployeeId, @FirstName, @LastName;

                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                            UPDATE employees
                            SET job_id = (SELECT j.job_id FROM jobs AS j WHERE j.job_title = @NewJob)
                            WHERE CURRENT OF employee_cursor;

                            INSERT INTO @ModifiedEmployees VALUES (@EmployeeId, @FirstName, @LastName, @DepartmentName);
                            PRINT 'ID: ' + CAST(@EmployeeId AS VARCHAR(6)) + N', imię: ' + @FirstName + ', nazwisko: ' + @LastName;
                            FETCH NEXT FROM employee_cursor INTO @EmployeeId, @FirstName, @LastName;
                        END;

                        CLOSE employee_cursor;
                        DEALLOCATE employee_cursor;
                    END;
                END;

            FETCH NEXT FROM department_cursor INTO @DepartmentName;
        END;

        CLOSE department_cursor;
        DEALLOCATE department_cursor;

        SET @ModifiedRowsCount = (SELECT COUNT(*) FROM @ModifiedEmployees);
        SELECT * FROM @ModifiedEmployees;
    END;
GO

-- Przypadek testowy: poprawne wywołanie procedury
BEGIN TRANSACTION;

DECLARE @ModifiedRowsCount INT;
EXEC dbo.UpdatePositionByPositionAndCountry 'Sales Manager', 'Sales Representative', 'United Kingdom', @ModifiedRowsCount OUTPUT;
SELECT @ModifiedRowsCount AS modified_rows_count;

ROLLBACK;

-- Przypadek testowy: podany kraj nie istnieje

DECLARE @ModifiedRowsCount INT;
EXEC dbo.UpdatePositionByPositionAndCountry 'Sales Manager', 'Sales Representative', ':>', @ModifiedRowsCount OUTPUT;

-- Przypadek testowy: w podanym kraju nie ma żadnego departamentu

DECLARE @ModifiedRowsCount INT;
EXEC dbo.UpdatePositionByPositionAndCountry 'Sales Manager', 'Sales Representative', 'Nigeria', @ModifiedRowsCount OUTPUT;

-- Przypadek testowy: w podanym kraju nie pracuje żaden pracownik

DECLARE @ModifiedRowsCount INT;
EXEC dbo.UpdatePositionByPositionAndCountry 'Sales Manager', 'Sales Representative', 'United States of America', @ModifiedRowsCount OUTPUT;
