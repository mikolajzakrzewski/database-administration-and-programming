-- 5. Wyświetl:
-- – liczbę unikalnych departamentów, w których są zatrudnieni pracownicy,
-- – liczbę unikalnych departamentów, w których są zatrudnieni pracownicy wykluczając departament Human Resources.

SELECT COUNT(DISTINCT d.department_name) AS unique_department_count,
COUNT(DISTINCT NULLIF(d.department_name, 'Human Resources')) AS unique_department_count_no_hr
FROM departments AS d
JOIN employees AS e ON e.department_id = d.department_id;