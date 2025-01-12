-- 1.1. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 1.2. Rozpocznij transakcję.
BEGIN;

-- 1.3. Podwyższ o 1000 zł maksymalną pensję na stanowisku Programmer.
UPDATE jobs
SET max_salary = max_salary + 1000
WHERE job_title = 'Programmer';

-- 1.4. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 1.5. Zatwierdź transakcję.
COMMIT;

-- 1.6. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';


-- 2.1. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 2.2. Rozpocznij transakcję.
BEGIN;

-- 2.3. Obniż o 1000 zł maksymalną pensję na stanowisku Programmer.
UPDATE jobs
SET max_salary = max_salary - 1000
WHERE job_title = 'Programmer';

-- 2.4. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer'

-- 2.5. Wycofaj transakcję.
ROLLBACK;

-- 2.6. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';


-- 3.1. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 3.2. Rozpocznij transakcję.
BEGIN;

-- 3.3. Obniż o 1000 zł maksymalną pensję na stanowisku Programmer.
UPDATE jobs
SET max_salary = max_salary - 1000
WHERE job_title = 'Programmer';

-- 3.4. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 3.5. Utwórz punkt zapisu o nazwie new_checkpoint.
SAVEPOINT new_checkpoint;

-- 3.6. Podwyższ o 1000 zł maksymalną pensję na stanowisku Programmer.
UPDATE jobs
SET max_salary = max_salary + 1000
WHERE job_title = 'Programmer';

-- 3.7. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 3.8. Wycofaj transakcję do punktu zapisu new_checkpoint.
ROLLBACK TO SAVEPOINT new_checkpoint;

-- 3.9. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';

-- 3.10. Zatwierdź transakcję.
COMMIT;

-- 3.11. Wyświetl maksymalną pensję na stanowisku Programmer.
SELECT max_salary FROM jobs
WHERE job_title = 'Programmer';


-- 4.1. Wyświetl wszystkie stanowiska.
SELECT * FROM jobs;

-- 4.2. Utwórz zrzut bazy danych HR i zapisz go do pliku o nazwie HR_dump.sql[1].
-- pg_dump -U apbd hr > /hr_dump.sql

-- 4.3. Usuń bazę danych HR.
DROP DATABASE IF EXISTS hr WITH (FORCE);


-- 5.1. Utwórz bazę danych o nazwie HR.
CREATE DATABASE hr;

-- 5.2. Przywróć bazę danych HR na podstawie pliku o nazwie HR_dump.sql[1].
-- psql -U apbd hr < /hr_dump.sql

-- 5.3. Wyświetl wszystkie stanowiska.
SELECT * FROM jobs;


-- 6.1. Wyświetl wszystkie role.
SELECT * FROM pg_roles;

-- 6.2. Utwórz zrzut wszystkich ról z pominięciem haseł i zapisz go do pliku o nazwie roles_dump.sql[1].
-- pg_dumpall -U apbd --roles-only --no-role-passwords > /roles_dump.sql


-- 7.1. Wyświetl listę wszystkich zadań.
SELECT * FROM pgagent.pga_job;

-- 7.2. Utwórz zadanie o nazwie HR_dump_backup[2].
DO $$
DECLARE
    jid integer;
BEGIN
-- Creating a new job
INSERT INTO pgagent.pga_job(
    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
) VALUES (
    1::integer, 'hr_dump_backup'::text, ''::text, ''::text, true
) RETURNING jobid INTO jid;
END
$$;

-- 7.3. Wyświetl listę wszystkich zadań.
SELECT * FROM pgagent.pga_job;


-- 8.1. Utwórz krok zadania o nazwie dump, który utworzy zrzut bazy danych HR i zapisze go do pliku o nazwie HR_dump.sql[2].
-- Inserting a step (jobid: 1)
INSERT INTO pgagent.pga_jobstep (
    jstjobid, jstname, jstenabled, jstkind,
    jstconnstr, jstdbname, jstonerror,
    jstcode, jstdesc
) VALUES (
    1, 'dump'::text, true, 'b'::character(1),
    ''::text, ''::name, 'f'::character(1),
    'pg_dump -U apbd hr > /hr_dump.sql'::text, ''::text
) RETURNING jstid;

-- 8.2. Wyświetl listę wszystkich harmonogramów.
SELECT * FROM pgagent.pga_schedule;

-- 8.3. Utwórz harmonogram zadania o nazwie every_month, który od 1 stycznia 2024 roku będzie wykonywany w każdy pierwszy dzień miesiąca o 1:00[2].
DO $$
DECLARE
    scid integer;
BEGIN
-- Inserting a schedule (jobid: 1)
INSERT INTO pgagent.pga_schedule(
    jscjobid, jscname, jscdesc, jscenabled,
    jscstart,     jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
) VALUES (
    1, 'every_month'::text, ''::text, true,
    '2024-01-01 00:00:00 +01:00'::timestamp with time zone, 
    -- Minutes
    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Hours
    '{f,t,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Week days
    '{f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Month days
    '{t,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Months
    '{f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[]
) RETURNING jscid INTO scid;
END
$$;

-- 8.4. Wyświetl listę wszystkich harmonogramów.
SELECT * FROM pgagent.pga_schedule;


-- 9.1. Dezaktywuj zadanie o nazwie HR_dump_backup[2].
UPDATE pgagent.pga_job
SET jobenabled = false
WHERE jobname = 'hr_dump_backup';


-- [1] Wykorzystaj wiersz poleceń (cmd).
-- [2] Zamieść własne albo wygenerowane przez pgAdmin polecenia SQL (PL/pgSQL).