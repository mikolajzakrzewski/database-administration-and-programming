-- 8. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor. Usuń wszystkie lokalizacje, w których nie ma żadnego departamentu. W rozwiązaniu wykorzystaj klauzulę WHERE CURRENT OF w odniesieniu do kursora.

-- Postgres
DO $$
DECLARE
    curs CURSOR FOR
        SELECT l.location_id
        FROM locations AS l
        LEFT JOIN departments AS d
            ON d.location_id = l.location_id
        WHERE d.department_id IS NULL
        FOR UPDATE OF l;
loc_id INT;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO loc_id;
        EXIT WHEN NOT FOUND;
        DELETE FROM locations WHERE CURRENT OF curs;
    END LOOP;
    CLOSE curs;
END $$;

-- MSSQL
DECLARE department_cursor CURSOR FOR
    SELECT *
    FROM locations AS l
    LEFT JOIN departments AS d
        ON d.location_id = l.location_id
    WHERE d.department_id IS NULL

OPEN department_cursor

FETCH NEXT FROM department_cursor

WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM locations WHERE CURRENT OF department_cursor
    FETCH NEXT FROM department_cursor
END

CLOSE department_cursor
DEALLOCATE department_cursor;

-- Dodatkowo wymień wszystkie polecenia, z którymi można wykorzystać klauzulę WHERE CURRENT OF w odniesieniu do kursora.

-- Odp: UPDATE, DELETE
