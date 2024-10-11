-- 2. Wyświetl nazwy departamentów, których pierwsza litera jest taka sama jak ostatnia litera nazwy kraju, w którym mieści się ich siedziba.

-- Postgres
SELECT de.department_name
FROM departments AS de
JOIN locations AS lo
    ON de.location_id = lo.location_id
JOIN countries AS co
    ON lo.country_id = co.country_id
WHERE LOWER(LEFT(de.department_name, 1)) = LOWER(RIGHT(co.country_name, 1));

-- MSSQL
SELECT d.department_name AS name FROM departments AS d
JOIN locations AS l ON d.location_id = l.location_id
JOIN countries AS c ON l.country_id = c.country_id
WHERE LEFT(d.department_name,1) = RIGHT(c.country_name,1);