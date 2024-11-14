-- 1. Utwórz procedurę proc1, która z wykorzystaniem kursora wypisze nazwy miast,
--    w których realne maksymalne zarobki pracowników są niższe od podanej kwoty.
--    Wywołaj ją z parametrem 10000.


-- PostgreSQL
CREATE OR REPLACE PROCEDURE proc1(salary_limit employees.salary%TYPE)
    LANGUAGE plpgsql
AS $$
    DECLARE
        city_name VARCHAR(30);
        curs CURSOR FOR
            SELECT l.city
            FROM locations AS l
            JOIN departments AS d
                ON l.location_id = d.location_id
            JOIN employees AS e
                ON d.department_id = e.department_id
            GROUP BY l.city
            HAVING MAX(e.salary) < salary_limit;
    BEGIN
        OPEN curs;
        LOOP
            FETCH curs INTO city_name;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE '%', city_name;
        END LOOP;
        CLOSE curs;
    END
$$;

call proc1(10000);


-- Microsoft SQL Server
CREATE OR ALTER PROCEDURE proc1
    @maxSalary DECIMAL(10, 2)
AS
BEGIN
    DECLARE @currCity VARCHAR(255);

    DECLARE curs CURSOR FOR
        SELECT l.city
        FROM locations l
        JOIN departments d ON d.location_id = l.location_id
        JOIN employees e ON e.department_id = d.department_id
        GROUP BY l.city
        HAVING MAX(e.salary) < @maxSalary;

    OPEN curs;

    FETCH NEXT FROM curs INTO @currCity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @currCity;
        FETCH NEXT FROM curs INTO @currCity;
    END;

    CLOSE curs;
    DEALLOCATE curs;
END;

EXEC proc1 10000;
