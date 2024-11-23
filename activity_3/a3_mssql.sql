-- 1. Dla każdego pracownika, wyświetl jego imię, nazwisko oraz informację o prowizji:
--        – "Brak prowizji" w przypadku, gdy pracownik nie ma podanej prowizji,
--        – "Nieznana prowizja" w przypadku, gdy prowizja pracownika nie może być porównana względem pozostałych
--          pracowników z tego samego działu,
--        – "Niska prowizja" w przypadku, gdy iloczyn prowizji i minimalnego wynagrodzenia dla stanowiska pracownika
--          jest mniejszy niż średnie wynagrodzenie wszystkich pracowników z działu tego pracownika pomniejszone o 5000,
--        – "Wysoka prowizja" w pozostałych przypadkach.
--    Kolumnę z informacją o prowizji nazwij commission_info.
--    Wynik posortuj według ostatniej informacji.
--    W rozwiązaniu wykorzystaj instrukcję warunkową.

-- Microsoft SQL Server
SELECT e.first_name, e.last_name,
       CASE WHEN (e.commission_pct IS NULL) THEN 'Brak prowizji'
            WHEN (SELECT COUNT(e1.commission_pct)
                    FROM dbo.employees AS e1
                   WHERE e1.employee_id != e.employee_id
                     AND e1.department_id = e.department_id) = 0 THEN 'Nieznana prowizja'
            WHEN e.commission_pct * (SELECT j.min_salary FROM jobs AS j WHERE j.job_id = e.job_id) <
                 (SELECT AVG(e1.salary) FROM employees AS e1 WHERE e1.department_id = e.department_id) - 5000
                THEN 'Niska prowizja'
            ELSE 'Wysoka prowizja' END AS commission_info
  FROM employees AS e
 ORDER BY commission_info;


-- 2. Wyświetl nazwy krajów, nazwy regionów oraz liczby departamentów znajdujących się w każdym kraju.
--    Wyniki ogranicz w zależności od liczby departamentów w następujący sposób:
--        – uwzględnij tylko te kraje z regionu Europe, które mają więcej niż 1 departament,
--        – uwzględnij tylko te kraje z regionu Americas, które mają więcej niż 3 departamenty,
--        – nie uwzględniaj krajów z pozostałych regionów.
--    W rozwiązaniu wykorzystaj instrukcję warunkową CASE w klauzuli HAVING.
--    Dodatkowo wskaż pozostałe klauzule, w których także można wykorzystać instrukcję warunkową CASE.

-- Microsoft SQL Server
SELECT c.country_name, r.region_name, COUNT(d.department_id) AS department_count
  FROM countries AS c
           JOIN regions AS r
           ON c.region_id = r.region_id
           JOIN locations AS l
           ON c.country_id = l.country_id
           JOIN departments AS d
           ON l.location_id = d.location_id
 GROUP BY c.country_name, r.region_name
HAVING COUNT(d.department_id) > CASE WHEN r.region_name = 'Europe' THEN 1 WHEN r.region_name = 'Americas' THEN 3 END;


-- 3. Przeanalizuj poniższy ciąg wartości i znajdź zależności:
--      5.
--      4.
--      4.1.
--      4.3.
--      4.4.
--      3.
--      3.1.
--      3.3.
--      2.
--      2.1.
--      1.
--      1.1.
--    Napisz blok anonimowy, który wypisze powyższe wartości.
--    W rozwiązaniu wykorzystaj pętlę LOOP oraz funkcje wyjścia, kontynuowania i/lub przerwania iteracji.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje pętla LOOP, wykorzystaj inny, dostępny rodzaj pętli.

-- Microsoft SQL Server
DECLARE @i INT = 6, @j INT = 0;

WHILE @i > 1 BEGIN
    SET @j = 0;
    SET @i = @i - 1;

    PRINT CAST(@i AS VARCHAR(1)) + '.';

    IF @i = 5 CONTINUE

    WHILE @j < @i BEGIN
        SET @j = @j + 1;

        IF @j = 2 CONTINUE

        PRINT CAST(@i AS VARCHAR(1)) + '.' + CAST(@j AS VARCHAR(1)) + '.';
    END;
END;
GO


-- 4. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne.
--    Wypisz nazwy kolejnych miast zaczynając od lokalizacji z ID równym 1500 i kończąc na lokalizacji z ID równym 2500.
--    Załóż, że w bazie danych nie brakuje żadnych wartości ID lokalizacji w powyższym przedziale, gdzie krok
--    wynosi 100.
--    Dla każdego miasta wypisz dodatkowo tyle par nawiasów prostokątnych ( [] ), ile departamentów znajduje się w nim.
--    Uwaga! Jeżeli dany system to umożliwia, wykorzystaj %TYPE przy deklaracji zmiennych.
--    Uwaga! Jeżeli dany system to umożliwia, użyj 1 pętli FOR oraz 1 pętli WHILE.

-- Microsoft SQL Server
DECLARE @location_id NUMERIC(4) = 1500, @braces VARCHAR(255) = '', @city VARCHAR(30), @department_count INT;

WHILE @location_id <= 2500 BEGIN
    SELECT @city = l.city FROM locations AS l WHERE l.location_id = @location_id;
    SELECT @department_count = COUNT(d.department_id)
      FROM departments AS d
               JOIN locations AS l
               ON d.location_id = l.location_id
     WHERE l.location_id = @location_id;

    WHILE @department_count > 0 BEGIN
        SET @braces = @braces + '[]';
        SET @department_count = @department_count - 1;
    END;

    PRINT @city + ' ' + @braces;
    SET @braces = '';

    SET @location_id = @location_id + 100;
END;
GO


-- 5. Stwórz blok anonimowy i zadeklaruj w nim zmienne dla sumy wynagrodzeń i kwoty granicznej.
--    Jeżeli suma wynagrodzeń jest mniejsza lub równa określonej kwocie granicznej, wypisz sumę wynagrodzeń
--    wszystkich pracowników. W przeciwnym razie wywołaj tylko swój wyjątek i wypisz adekwatną informację.
--    Wypróbuj swoje rozwiązanie dla kwot granicznych 500 000 i 700 000.
--    Dodatkowo wskaż różnice pomiędzy:
--        – THROW i RAISERROR w Microsoft SQL Server,
--        – RAISE EXCEPTION, RAISE WARNING, RAISE NOTICE i RAISE INFO w PostgreSQL.

-- Microsoft SQL Server
DECLARE @salary_sum NUMERIC(8, 2), @salary_sum_limit NUMERIC(8, 2) = 500000;

BEGIN
    SELECT @salary_sum = SUM(e.salary) FROM employees AS e;
    IF @salary_sum <= @salary_sum_limit
        PRINT N'Suma wynagrodzeń wszystkich pracowników: ' + CAST(@salary_sum AS VARCHAR(10));
    ELSE
        BEGIN
            DECLARE @error_message VARCHAR(255);
            SET @error_message =
                    CONCAT(N'Suma wynagrodzeń wszystkich pracowników (', @salary_sum, N') przekracza kwotę graniczną (',
                           @salary_sum_limit, ')');
            THROW 50000, @error_message, 1;
        END;
END;
GO

DECLARE @salary_sum NUMERIC(8, 2), @salary_sum_limit NUMERIC(8, 2) = 700000;

BEGIN
    SELECT @salary_sum = SUM(e.salary) FROM employees AS e;
    IF @salary_sum <= @salary_sum_limit
        PRINT N'Suma wynagrodzeń wszystkich pracowników: ' + CAST(@salary_sum AS VARCHAR(10));
    ELSE
        BEGIN
            DECLARE @error_message VARCHAR(255);
            SET @error_message =
                    CONCAT(N'Suma wynagrodzeń wszystkich pracowników (', @salary_sum, N') przekracza kwotę graniczną (',
                           @salary_sum_limit, ')');
            THROW 50000, @error_message, 1;
        END;
END;
GO


-- 6. Stwórz blok anonimowy i zadeklaruj w nim zmienne dla nazwy departamentu i nazwy miasta.
--    Wypisz nazwę departamentu, który znajduje się w wybranym mieście.
--    Złap wyjątki systemowe za pomocą ich nazw w przypawdkach, gdy taki departament nie istnieje lub istnieje więcej
--    niż 1 taki departament - wypisz adekwatną informację.
--    Wypróbuj swoje rozwiązanie dla miast Venice, Munich i Seattle.
--    Dodatkowo sprawdź, w jaki sposób zapisywane są wartości do zmiennych przy poleceniu SELECT, które zwraca więcej
--    niż jedną wartość lub nie zwraca nic.
--    Uwaga! Jeżeli w jakimś systemie nie istnieją wyjątki systemowe dotyczące braku wyników lub zbyt dużej liczby
--    wyników, zaproponuj jak najprostsze rozwiązanie, które umożliwi przechwycenie takich błędów.

-- Microsoft SQL Server
DECLARE @department_name VARCHAR(30), @city_name VARCHAR(30) = 'Venice', @found_departments_count INT;

BEGIN
    SELECT @department_name = d.department_name
      FROM departments AS d
               JOIN locations AS l
               ON d.location_id = l.location_id
     WHERE l.city = @city_name;

    SET @found_departments_count = @@ROWCOUNT;
    IF @found_departments_count = 0 PRINT N'W mieście ' + @city_name + N' nie ma żadnego departamentu';
    IF @found_departments_count > 1
        PRINT N'W mieście ' + @city_name + N' znajduje się więcej niż 1 departament';
    ELSE
        PRINT @department_name;
END;
GO

DECLARE @department_name VARCHAR(30), @city_name VARCHAR(30) = 'Munich', @found_departments_count INT;

BEGIN
    SELECT @department_name = d.department_name
      FROM departments AS d
               JOIN locations AS l
               ON d.location_id = l.location_id
     WHERE l.city = @city_name;

    SET @found_departments_count = @@ROWCOUNT;
    IF @found_departments_count = 0 PRINT N'W mieście ' + @city_name + N' nie ma żadnego departamentu';
    IF @found_departments_count > 1
        PRINT N'W mieście ' + @city_name + N' znajduje się więcej niż 1 departament';
    ELSE
        PRINT @department_name;
END;
GO

DECLARE @department_name VARCHAR(30), @city_name VARCHAR(30) = 'Seattle', @found_departments_count INT;

BEGIN
    SELECT @department_name = d.department_name
      FROM departments AS d
               JOIN locations AS l
               ON d.location_id = l.location_id
     WHERE l.city = @city_name;

    SET @found_departments_count = @@ROWCOUNT;
    IF @found_departments_count = 0 PRINT N'W mieście ' + @city_name + N' nie ma żadnego departamentu';
    IF @found_departments_count > 1
        PRINT N'W mieście ' + @city_name + N' znajduje się więcej niż 1 departament';
    ELSE
        PRINT @department_name;
END;
GO


-- 7. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor z parametrem odnoszącym się do nazwy
--    kraju.
--    Wypisz numery ID lokalizacji oraz nazwy miast z kraju United States of America, którego nazwa jest przesyłana
--    do kursora.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje kursor z parametrem, zapisz nazwę podanego kraju w zmiennej
--    i wykorzystaj ją w kursorze.

-- Microsoft SQL Server
DECLARE @location_id NUMERIC(4), @city_name VARCHAR(30), @country_name VARCHAR(40) = 'United States of America';
DECLARE location_cursor CURSOR FOR SELECT l.location_id, l.city
                                     FROM locations AS l
                                              JOIN countries AS c
                                              ON l.country_id = c.country_id
                                    WHERE c.country_name = @country_name;

BEGIN
    OPEN location_cursor;
    FETCH NEXT FROM location_cursor INTO @location_id, @city_name;

    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT 'ID lokalizacji: ' + CAST(@location_id AS VARCHAR(4)) + ', nazwa miasta: ' + @city_name;
        FETCH NEXT FROM location_cursor INTO @location_id, @city_name;
    END;

    CLOSE location_cursor;
    DEALLOCATE location_cursor;
END;
GO


-- 8. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor.
--    Usuń wszystkie lokalizacje, w których nie ma żadnego departamentu.
--    W rozwiązaniu wykorzystaj klauzulę WHERE CURRENT OF w odniesieniu do kursora.
--    Dodatkowo wymień wszystkie polecenia, z którymi można wykorzystać klauzulę WHERE CURRENT OF w odniesieniu
--    do kursora.

-- Microsoft SQL Server
DECLARE @location_id NUMERIC(4);
DECLARE location_cursor CURSOR FOR SELECT l.location_id
                                     FROM locations AS l;

BEGIN
    OPEN location_cursor;
    FETCH NEXT FROM location_cursor INTO @location_id;

    WHILE @@FETCH_STATUS = 0 BEGIN
        DELETE FROM locations WHERE CURRENT OF location_cursor;
        FETCH NEXT FROM location_cursor INTO @location_id;
    END;

    CLOSE location_cursor;
    DEALLOCATE location_cursor;
END;
GO


-- 9. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne.
--    Dla każdej lokalizacji, wypisz wszystkie dane na jej temat razem z dodanymi opisami.
--    Kolejność danych w jednej wiadomości to: ID lokalizacji, adres, kod pocztowy, miasto, stan/prowincja oraz
--    id kraju. Zwróć uwagę, żeby nie wyświetlać poszczególnych opisów w przypadku braku podanej wartości.
--    Uwaga! Jeżeli dany system to umożliwia, wykorzystaj kursor z FOR LOOP.
--    Uwaga! Jeżeli dany system to umożliwia, użyj %ROWTYPE przy deklaracji zmiennej.

-- Microsoft SQL Server
DECLARE @location_id NUMERIC(4), @street_address VARCHAR(40), @postal_code VARCHAR(12), @city VARCHAR(30), @state_province VARCHAR(25), @country_id CHAR(2), @location_info VARCHAR(1000) = '';
DECLARE location_cursor CURSOR FOR SELECT location_id, street_address, postal_code, city, state_province, country_id
                                     FROM locations;

BEGIN
    OPEN location_cursor;
    FETCH NEXT FROM location_cursor INTO @location_id, @street_address, @postal_code, @city, @state_province, @country_id;

    WHILE @@FETCH_STATUS = 0 BEGIN
        IF @location_id IS NOT NULL
            SET @location_info = @location_info + 'ID lokalizacji: ' + CAST(@location_id AS VARCHAR(4)) + CHAR(13);

        IF @street_address IS NOT NULL SET @location_info = @location_info + 'Adres: ' + @street_address + CHAR(13);

        IF @postal_code IS NOT NULL SET @location_info = @location_info + 'Kod pocztowy: ' + @postal_code + CHAR(13);

        IF @city IS NOT NULL SET @location_info = @location_info + 'Miasto: ' + @city + CHAR(13);

        IF @state_province IS NOT NULL
            SET @location_info = @location_info + 'Stan/prowincja: ' + @state_province + CHAR(13);

        IF @country_id IS NOT NULL SET @location_info = @location_info + 'ID kraju: ' + @country_id + CHAR(13);

        PRINT @location_info;
        SET @location_info = '';

        FETCH NEXT FROM location_cursor INTO @location_id, @street_address, @postal_code, @city, @state_province, @country_id;
    END;

    CLOSE location_cursor;
    DEALLOCATE location_cursor;
END;
GO
