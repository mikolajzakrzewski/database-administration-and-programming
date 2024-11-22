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

-- PostgreSQL
SELECT e.first_name, e.last_name,
       CASE WHEN e.commission_pct IS NULL THEN 'Brak prowizji'
            WHEN (SELECT COUNT(e1.commission_pct)
                    FROM employees AS e1
                   WHERE e.department_id = e1.department_id
                     AND e.employee_id != e1.employee_id) = 0 THEN 'Nieznana prowizja'
            WHEN e.commission_pct * (SELECT j.min_salary
                                       FROM jobs AS j
                                                JOIN employees AS e1
                                                ON j.job_id = e1.job_id
                                      WHERE e.employee_id = e1.employee_id) <
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

-- PostgreSQL
SELECT c.country_name, r.region_name, COUNT(d.department_id) AS department_count
  FROM countries AS c
           JOIN regions AS r
           ON c.region_id = r.region_id
           JOIN locations AS l
           ON c.country_id = l.country_id
           JOIN departments AS d
           ON l.location_id = d.location_id
 GROUP BY c.country_name, r.region_name
HAVING COUNT(department_id) > CASE WHEN r.region_name = 'Europe' THEN 1 WHEN r.region_name = 'Americas' THEN 3 END;


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

-- PostgreSQL
DO
$$
    DECLARE
        i INT := 6;
        j INT := 0;

    BEGIN
        LOOP
            i := i - 1;
            EXIT WHEN i < 1;
            RAISE NOTICE '%.', i;
            CONTINUE WHEN i = 5;
            LOOP
                j := j + 1;
                EXIT WHEN j > i;
                CONTINUE WHEN j % 2 = 0;
                RAISE NOTICE '%.%.', i, j;
            END LOOP;
            j := 0;
        END LOOP;
    END
$$;


-- 4. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne.
--    Wypisz nazwy kolejnych miast zaczynając od lokalizacji z ID równym 1500 i kończąc na lokalizacji z ID równym 2500.
--    Załóż, że w bazie danych nie brakuje żadnych wartości ID lokalizacji w powyższym przedziale, gdzie krok
--    wynosi 100.
--    Dla każdego miasta wypisz dodatkowo tyle par nawiasów prostokątnych ( [] ), ile departamentów znajduje się w nim.
--    Uwaga! Jeżeli dany system to umożliwia, wykorzystaj %TYPE przy deklaracji zmiennych.
--    Uwaga! Jeżeli dany system to umożliwia, użyj 1 pętli FOR oraz 1 pętli WHILE.

-- PostgreSQL
DO
$$
    DECLARE
        temp_location_id locations.location_id%TYPE := 1500;
        temp_city        locations.city%TYPE;
        department       departments%ROWTYPE;
        brackets         text;

    BEGIN
        WHILE temp_location_id <= 2500 LOOP
            temp_city = (SELECT l.city FROM locations AS l WHERE l.location_id = temp_location_id);
            FOR department IN SELECT * FROM departments AS d WHERE d.location_id = temp_location_id LOOP
                brackets := CONCAT(brackets, '[]');
            END LOOP;
            RAISE NOTICE '% %', temp_city, brackets;
            brackets := '';
            temp_location_id := temp_location_id + 100;
        END LOOP;
    END
$$;


-- 5. Stwórz blok anonimowy i zadeklaruj w nim zmienne dla sumy wynagrodzeń i kwoty granicznej.
--    Jeżeli suma wynagrodzeń jest mniejsza lub równa określonej kwocie granicznej, wypisz sumę wynagrodzeń
--    wszystkich pracowników. W przeciwnym razie wywołaj tylko swój wyjątek i wypisz adekwatną informację.
--    Wypróbuj swoje rozwiązanie dla kwot granicznych 500 000 i 700 000.
--    Dodatkowo wskaż różnice pomiędzy:
--        – THROW i RAISERROR w Microsoft SQL Server,
--        – RAISE EXCEPTION, RAISE WARNING, RAISE NOTICE i RAISE INFO w PostgreSQL.

-- PostgreSQL
DO
$$
    DECLARE
        salary_sum       employees.salary%TYPE;
        salary_sum_limit employees.salary%TYPE := 500000;

    BEGIN
        salary_sum = (SELECT SUM(e.salary) FROM employees AS e);
        IF salary_sum <= salary_sum_limit THEN
            RAISE NOTICE 'Suma wynagrodzeń wszystkich pracowników: %', salary_sum;
        ELSE
            RAISE EXCEPTION 'Suma wynagrodzeń wszystkich pracowników (%) przekracza sumę graniczną (%)', salary_sum, salary_sum_limit;
        END IF;
    END;
$$;

DO
$$
    DECLARE
        salary_sum       employees.salary%TYPE;
        salary_sum_limit employees.salary%TYPE := 700000;

    BEGIN
        salary_sum = (SELECT SUM(e.salary) FROM employees AS e);
        IF salary_sum <= salary_sum_limit THEN
            RAISE NOTICE 'Suma wynagrodzeń wszystkich pracowników: %', salary_sum;
        ELSE
            RAISE EXCEPTION 'Suma wynagrodzeń wszystkich pracowników (%) przekracza sumę graniczną (%)', salary_sum, salary_sum_limit;
        END IF;
    END;
$$;


-- 6. Stwórz blok anonimowy i zadeklaruj w nim zmienne dla nazwy departamentu i nazwy miasta.
--    Wypisz nazwę departamentu, który znajduje się w wybranym mieście.
--    Złap wyjątki systemowe za pomocą ich nazw w przypadkach, gdy taki departament nie istnieje lub istnieje więcej
--    niż 1 taki departament - wypisz adekwatną informację.
--    Wypróbuj swoje rozwiązanie dla miast Venice, Munich i Seattle.
--    Dodatkowo sprawdź, w jaki sposób zapisywane są wartości do zmiennych przy poleceniu SELECT, które zwraca więcej
--    niż jedną wartość lub nie zwraca nic.
--    Uwaga! Jeżeli w jakimś systemie nie istnieją wyjątki systemowe dotyczące braku wyników lub zbyt dużej liczby
--    wyników, zaproponuj jak najprostsze rozwiązanie, które umożliwi przechwycenie takich błędów.

-- PostgreSQL
DO
$$
    DECLARE
        temp_department_name departments.department_name%TYPE;
        city_name            locations.city%TYPE := 'Seattle';

    BEGIN
        SELECT d.department_name
          INTO STRICT temp_department_name
          FROM departments AS d
                   JOIN locations AS l
                   ON d.location_id = l.location_id
         WHERE l.city = city_name;
        RAISE NOTICE 'Nazwa departamentu w mieście %: %', city_name, temp_department_name;
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN RAISE NOTICE 'W mieście % znajduje się więcej niż 1 departament', city_name;
        WHEN NO_DATA_FOUND THEN RAISE NOTICE 'W mieście % nie ma żadnego departamentu', city_name;
    END;
$$;


-- 7. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor z parametrem odnoszącym się do nazwy
--    kraju.
--    Wypisz numery ID lokalizacji oraz nazwy miast z kraju United States of America, którego nazwa jest przesyłana
--    do kursora.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje kursor z parametrem, zapisz nazwę podanego kraju w zmiennej
--    i wykorzystaj ją w kursorze.

-- PostgreSQL
DO
$$
    DECLARE
        temp_location_id locations.location_id%TYPE;
        temp_city_name   locations.city%TYPE; DECLARE
        location_cursor CURSOR (country_name_cursor VARCHAR(40)) FOR
            SELECT l.location_id, l.city
              FROM locations AS l
                       JOIN countries AS c
                       ON l.country_id = c.country_id
             WHERE c.country_name = country_name_cursor;
    BEGIN
        OPEN location_cursor('United States of America');

        LOOP
            FETCH location_cursor INTO temp_location_id, temp_city_name;
            EXIT WHEN NOT found;

            RAISE NOTICE 'ID lokalizacji: %, nazwa miasta: %', temp_location_id, temp_city_name;
        END LOOP;

        CLOSE location_cursor;
    END;
$$;


-- 8. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor.
--    Usuń wszystkie lokalizacje, w których nie ma żadnego departamentu.
--    W rozwiązaniu wykorzystaj klauzulę WHERE CURRENT OF w odniesieniu do kursora.
--    Dodatkowo wymień wszystkie polecenia, z którymi można wykorzystać klauzulę WHERE CURRENT OF w odniesieniu
--    do kursora.

-- PostgreSQL
DO
$$
    DECLARE
        temp_location_id locations.location_id%TYPE;
        location_cursor CURSOR FOR
            SELECT l.location_id
              FROM locations AS l
                       LEFT JOIN departments AS d
                       ON l.location_id = d.location_id
             WHERE d.department_id IS NULL FOR UPDATE OF l;
    BEGIN
        OPEN location_cursor;

        LOOP
            FETCH location_cursor INTO temp_location_id;
            EXIT WHEN NOT found;

            DELETE FROM locations WHERE CURRENT OF location_cursor;
        END LOOP;

        CLOSE location_cursor;
    END;
$$;


-- 9. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne.
--    Dla każdej lokalizacji, wypisz wszystkie dane na jej temat razem z dodanymi opisami.
--    Kolejność danych w jednej wiadomości to: ID lokalizacji, adres, kod pocztowy, miasto, stan/prowincja oraz
--    id kraju. Zwróć uwagę, żeby nie wyświetlać poszczególnych opisów w przypadku braku podanej wartości.
--    Uwaga! Jeżeli dany system to umożliwia, wykorzystaj kursor z FOR LOOP.
--    Uwaga! Jeżeli dany system to umożliwia, użyj %ROWTYPE przy deklaracji zmiennej.

-- PostgreSQL
DO
$$
    DECLARE
        temp_location locations%ROWTYPE;
        location_info TEXT := '';
    BEGIN
        FOR temp_location IN SELECT * FROM locations AS l LOOP
            IF temp_location.location_id IS NOT NULL THEN
                location_info := location_info || 'ID lokalizacji: ' || temp_location.location_id || E'\n';
            END IF;

            IF temp_location.street_address IS NOT NULL THEN
                location_info := location_info || 'Adres: ' || temp_location.street_address || E'\n';
            END IF;

            IF temp_location.postal_code IS NOT NULL THEN
                location_info := location_info || 'Kod pocztowy: ' || temp_location.postal_code || E'\n';
            END IF;

            IF temp_location.city IS NOT NULL THEN
                location_info := location_info || 'Miasto: ' || temp_location.city || E'\n';
            END IF;

            IF temp_location.state_province IS NOT NULL THEN
                location_info := location_info || 'Stan/prowincja: ' || temp_location.state_province || E'\n';
            END IF;

            IF temp_location.country_id IS NOT NULL THEN
                location_info := location_info || 'ID kraju: ' || temp_location.country_id || E'\n';
            END IF;

            RAISE NOTICE '%', location_info;
        END LOOP;
    END;
$$;
