-- 1. Utwórz nową tabelę dotyczącą stażystów o nazwie interns, która będzie zawierać wymienione pola:
--      – employee_id – klucz główny oraz klucz obcy do tabeli pracowników odwołujący się do danych stażysty,
--      – supervisor_id – klucz obcy do tabeli pracowników odwołujący się do danych opiekuna stażysty,
--      – university – nazwa uczelni stażysty,
--      – student_number – numer albumu stażysty,
--      – avg_grade – średnia ocen stażysty z ostatniego semestru,
--      – end_date – data zakończenia stażu.
--    Dodatkowo zadbaj o:
--      – konieczność podania wartości w polu supervisor_id,
--      – ustawienie domyślnej wartości "TUL" w polu university,
--      – zapewnienie unikalności wartości w polu student_number,
--      – wprowadzenie takiego ograniczenia wartości w polu avg_grade, że musi być ona większa albo równa 3,5 oraz
--        mniejsza albo równa 5,0.
--    Dodaj dane o stażyście:
--      – imię i nazwisko: Mike Thompson,
--      – e-mail: I_MTHOMP,
--      – okres stażu: 01/07-30/09/2022,
--      – departament: IT,
--      – stanowisko: Programmer,
--      – wynagrodzenie: połowa minimalnego wynagrodzenia dla stanowiska Programmer,
--      – menedżer: menedżer departamentu IT,
--      – opiekun: Bruce Ernst,
--      – numer albumu: 200654,
--      – średnia ocen: 4,35.
--    Zadbaj o poprawnie wyliczony identyfikator stażysty.
--    Dodaj pole birth_date do tabeli stażystów przechowujące ich datę urodzenia.
--    Wprowadź datę urodzenia Mike'a Thompsona przy założeniu, że rozpoczął staż w dniu swoich 20. urodzin.
--    Usuń wszystkie informacje o Mike'u Thompsonie.
--    Usuń tabelę stażystów.

-- Microsoft SQL Server
CREATE TABLE interns (
    employee_id NUMERIC(6),
    supervisor_id NUMERIC(6) NOT NULL,
    university VARCHAR(50) DEFAULT 'TUL',
    student_number NUMERIC(6) UNIQUE,
    avg_grade NUMERIC(3,2),
    end_date DATE,
    CONSTRAINT employee_id_pk PRIMARY KEY (employee_id),
    CONSTRAINT employee_id_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT supervisor_id_fk FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id),
    CONSTRAINT avg_grade_limit CHECK (avg_grade >= 3.5 AND avg_grade <= 5.0)
);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary, manager_id, department_id)
VALUES (
        (SELECT MAX(e.employee_id) + 1 FROM employees AS e),
        'Mike',
        'Thompson',
        'I_MTHOMP',
        '2022-07-01',
        (SELECT j.job_id FROM jobs AS j WHERE j.job_title = 'Programmer'),
        (SELECT (j.min_salary / 2) FROM jobs AS j WHERE j.job_title = 'Programmer'),
        (SELECT d.manager_id FROM departments AS d WHERE d.department_name = 'IT'),
        (SELECT d.department_id FROM departments AS d WHERE d.department_name = 'IT')
        );

INSERT INTO interns (employee_id, supervisor_id, student_number, avg_grade, end_date)
VALUES (
        (SELECT e.employee_id FROM employees AS e WHERE e.first_name = 'Mike' AND e.last_name = 'Thompson'),
        (SELECT e.employee_id FROM employees AS e WHERE e.first_name = 'Bruce' AND e.last_name = 'Ernst'),
        200654,
        4.35,
        '2022-09-30'
       );

ALTER TABLE interns
ADD birth_date DATE;

UPDATE interns
SET birth_date = DATEADD(YEAR,
                         -20,
                         (SELECT e.hire_date
                          FROM employees AS e
                          WHERE first_name = 'Mike'
                            AND last_name = 'Thompson'))
WHERE employee_id = (SELECT employee_id
                     FROM employees
                     WHERE first_name = 'Mike'
                        AND last_name = 'Thompson');

DELETE FROM interns WHERE employee_id = (SELECT employee_id
                                         FROM employees
                                         WHERE first_name = 'Mike'
                                            AND last_name = 'Thompson');
DELETE FROM employees WHERE first_name = 'Mike' AND last_name = 'Thompson';

DROP TABLE interns;


-- 2. Wyświetl aktualną datę (nazwij tę kolumnę date) oraz aktualną godzinę bez podawania milisekund (nazwij tę kolumnę
--    time).

-- Microsoft SQL Server
SELECT CAST(CURRENT_TIMESTAMP AS DATE) AS date, FORMAT(CURRENT_TIMESTAMP, 'HH:mm:ss') AS time


-- 3. Wyświetl informacje o wszystkich pracownikach w czterech wymienionych kolumnach:
--      – imię i nazwisko pracownika oddzielone od siebie spacją,
--      – nazwa stanowiska pracownika (jeżeli jej członem jest wyraz Clerk, to zamień go na Assistant),
--      – wynagrodzenie pracownika z dopisanym na początku symbolem waluty ($),
--      – numer telefonu pracownika ze znakami myślnika (-) zamiast kropek (.).
--    Nazwij te kolumny name, job, salary oraz phone_number. W rozwiązaniu wykorzystaj tylko jeden select.

-- Microsoft SQL Server
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
       REPLACE(j.job_title, 'Clerk', 'Assistant') AS job,
       CONCAT('$', e.salary) AS salary,
       REPLACE(e.phone_number, '.', '-') AS phone_number
FROM employees AS e
JOIN jobs AS j
    ON e.job_id = j.job_id;


-- 4. Wyświetl:
--      – najmniejszą wartość prowizji pracowników,
--      – najmniejszą wartość prowizji pracowników biorąc pod uwagę, że brak podanej wartości oznacza, że prowizja
--        pracownika wynosi 0.
--    W rozwiązaniu wykorzystaj odpowiednią funkcję oraz tylko jeden select.

-- Microsoft SQL Server
SELECT MIN(e.commission_pct) AS min_nonzero_commission_pct,
       MIN(COALESCE(e.commission_pct, 0)) AS min_commission_pct
FROM employees AS e;


-- 5. Wyświetl:
--      – liczbę unikalnych departamentów, w których są zatrudnieni pracownicy,
--      – liczbę unikalnych departamentów, w których są zatrudnieni pracownicy wykluczając departament Human Resources.
--    W rozwiązaniu wykorzystaj odpowiednią funkcję oraz tylko jeden select.

-- Microsoft SQL Server
SELECT COUNT(DISTINCT d.department_name) AS distinct_departments_count,
       COUNT(DISTINCT NULLIF(d.department_name, 'Human Resources')) AS distinct_departments_count_no_hr
FROM departments AS d
JOIN employees AS e
    ON d.department_id = e.department_id;


-- 6. Wyświetl nazwy miast, w których swoją siedzibę ma więcej departamentów niż wynosi średnia liczba departamentów
--    we wszystkich miastach. W rozwiązaniu wykorzystaj klauzulę with.

-- Microsoft SQL Server
WITH department_counts_by_city (city, department_count) AS (
    SELECT l.city, COUNT(d.department_id)
    FROM locations AS l
    LEFT JOIN departments AS d
        ON l.location_id = d.location_id
    GROUP BY l.city
),
avg_department_count (avg_department_count) AS (
    SELECT AVG(department_count)
    FROM department_counts_by_city
)
SELECT dcbc.city
FROM department_counts_by_city AS dcbc
WHERE dcbc.department_count > (SELECT avg_department_count
                               FROM avg_department_count);


-- 7. Dla każdego departamentu wyświetl jego nazwę oraz informację o liczbie zatrudnionych w nim pracowników:
--      – "none" w przypadku, gdy w danym departamencie nie pracuje żaden pracownik,
--      – "X employee(s)" w przypadku, gdy w danym departamencie pracuje X pracowników (wartość X należy zamienić
--        na rzeczywistą liczbę).
--    W rozwiązaniu wykorzystaj operator sumy zbiorów.

-- Microsoft SQL Server
SELECT d.department_name, 'none' AS employees_no
FROM departments AS d
LEFT JOIN employees AS e
    on d.department_id = e.department_id
WHERE e.employee_id IS NULL

UNION

SELECT d2.department_name, CONCAT(COUNT(e2.employee_id), ' employee(s)') AS employees_no
FROM departments AS d2
JOIN employees AS e2
    ON d2.department_id = e2.department_id
GROUP BY d2.department_name;


-- 8. Wyświetl imiona i nazwiska pracowników, którzy co najmniej raz zmienili stanowisko w trakcie swojego zatrudnienia
--    w firmie. Wyniki posortuj alfabetycznie według nazwiska oraz imienia. W rozwiązaniu wykorzystaj operator
--    przecięcia zbiorów.

-- Microsoft SQL Server
SELECT e.first_name, e.last_name
FROM employees AS e

INTERSECT

SELECT e2.first_name, e2.last_name
FROM employees AS e2
JOIN job_history AS jh
    ON e2.employee_id = jh.employee_id

ORDER BY last_name, first_name;


-- 9. Wyświetl nazwy miast, w których swojej siedziby nie ma żaden departament. W rozwiązaniu wykorzystaj operator
--    różnicy zbiorów.

-- Microsoft SQL Server
SELECT l.city
FROM locations AS l

EXCEPT

SELECT l2.city
FROM locations AS l2
JOIN departments AS d
    ON l2.location_id = d.location_id;
