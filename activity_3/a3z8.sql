-- 8. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor. Usuń wszystkie lokalizacje, w których nie ma żadnego departamentu. W rozwiązaniu wykorzystaj klauzulę WHERE CURRENT OF w odniesieniu do kursora.

-- PostgreSQL
DO $$
DECLARE
	loc_id INT;
	curs CURSOR FOR
		SELECT l.location_id
		FROM locations AS l
		LEFT JOIN departments AS d
			ON d.location_id = l.location_id
		WHERE d.department_id IS NULL
		FOR UPDATE OF l;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO loc_id;
		EXIT WHEN NOT FOUND;
		DELETE FROM locations WHERE CURRENT OF curs;
	END LOOP;
	CLOSE curs;
END $$;

-- Microsoft SQL Server
DECLARE
	@location_id NUMERIC(4);
DECLARE department_cursor CURSOR FOR
	SELECT l.location_id
	FROM locations AS l
	LEFT JOIN departments AS d
		ON d.location_id = l.location_id
	WHERE d.department_id IS NULL;
BEGIN
	OPEN department_cursor;
	FETCH NEXT FROM department_cursor INTO @location_id;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE FROM locations WHERE CURRENT OF department_cursor;
		FETCH NEXT FROM department_cursor INTO @location_id;
	END;
	CLOSE department_cursor;
	DEALLOCATE department_cursor;
END;

-- Dodatkowo wymień wszystkie polecenia, z którymi można wykorzystać klauzulę WHERE CURRENT OF w odniesieniu do kursora.
-- Odp: UPDATE, DELETE