-- 1. Wyświetl imiona i nazwiska pracowników zatrudnionych w departamencie o nazwie IT. Wyniki posortuj malejąco
--    według wynagrodzenia oraz alfabetycznie według nazwiska.

-- Microsoft SQL Server
SELECT e.first_name, e.last_name
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.department_id
WHERE d.department_name = 'IT'
ORDER BY e.salary DESC, e.last_name;

-- 2. Wyświetl nazwy departamentów, których pierwsza litera jest taka sama jak ostatnia litera nazwy kraju, w którym
--    mieści się ich siedziba.

-- Microsoft SQL Server
SELECT d.department_name
FROM departments AS d
JOIN locations AS l
    ON d.location_id = l.location_id
JOIN countries AS c
    ON l.country_id = c.country_id
WHERE LEFT(d.department_name, 1) = RIGHT(c.country_name, 1);

-- 3. Wyświetl imiona i nazwiska pracowników oraz nazwę dnia tygodnia, w którym zostali zatrudnieni na obecnym
--    stanowisku (nazwij tę kolumnę hired_weekday). Uwzględnij tylko tych pracowników, którzy zostali zatrudnieni
--    w poniedziałek albo piątek.

-- Microsoft SQL Server
SELECT *
FROM
(
    SELECT e.first_name, e.last_name, DATENAME(weekday, e.hire_date) AS hired_weekday
    FROM employees AS e
) AS inner_table
WHERE hired_weekday IN ('Monday', 'Friday');


-- 4. Wyświetl nazwy stanowisk, na których nie jest zatrudniony żaden pracownik.

-- Microsoft SQL Server
SELECT j.job_title
FROM jobs AS j
LEFT JOIN employees AS e
    ON j.job_id = e.job_id
WHERE e.employee_id IS NULL;

-- 5. Dla każdego pracownika wyświetl jego imię i nazwisko oraz liczbę bezpośrednio podległych mu współpracowników.
--    Uwzględnij również tych pracowników, którzy nie mają podwładnych.

-- Microsoft SQL Server
SELECT e.first_name, e.last_name, COUNT(e1.employee_id) AS no_subordinates
FROM employees AS e
LEFT JOIN employees AS e1
    ON e.employee_id = e1.manager_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY no_subordinates DESC;

-- 6. Wyświetl nazwy miast, w których swoją siedzibę ma więcej niż jeden departament.

-- Microsoft SQL Server
SELECT l.city
FROM locations AS l
JOIN departments AS d
    ON l.location_id = d.location_id
GROUP BY l.location_id, l.city
HAVING COUNT(d.department_id) > 1;

-- 7. Wyświetl imiona i nazwiska pracowników, którzy zarabiają więcej niż średnie wynagrodzenie pracowników
--    zatrudnionych rocznikowo co najmniej 20 lat temu.

-- Microsoft SQL Server
SELECT e.first_name, e.last_name
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e1.salary)
    FROM employees AS e1
    WHERE DATEDIFF(year, e1.hire_date, CURRENT_TIMESTAMP) >= 20
    );

-- 8. Wyświetl nazwy departamentów, w których zatrudnionych jest najwięcej pracowników.

-- Microsoft SQL Server
SELECT d.department_name
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) = (
    SELECT TOP 1 COUNT(e1.employee_id)
    FROM departments AS d1
    JOIN employees AS e1
        ON d1.department_id = e1.department_id
    GROUP BY d1.department_id
    ORDER BY COUNT(e1.employee_id) DESC
    );

-- 9. Dla każdego stanowiska wyświetl jego nazwę oraz imiona i nazwiska obecnych pracowników, którzy są na nim
--    najkrócej zatrudnieni. Uwzględnij również te stanowiska, na których nie jest zatrudniony żaden pracownik.

-- Microsoft SQL Server
SELECT j.job_title, e.first_name, e.last_name
FROM jobs AS j
LEFT JOIN employees AS e
    ON j.job_id = e.job_id
WHERE e.hire_date = (
    SELECT MAX(e1.hire_date)
    FROM employees AS e1
    WHERE e1.job_id = j.job_id
    )
    OR e.hire_date IS NULL
ORDER BY j.job_title;
