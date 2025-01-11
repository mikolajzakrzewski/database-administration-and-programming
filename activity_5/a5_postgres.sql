-- 1.1. Wyświetl wszystkich użytkowników.
SELECT * FROM pg_user;

-- 1.2. Utwórz nowego użytkownika o nazwie new_user z hasłem new_password ważnym do końca 2024 roku.
CREATE USER new_user
WITH
	PASSWORD 'new_password'
	VALID UNTIL '2026-01-01';

-- 1.3. Jako new_user wyświetl nazwę użytkownika.
SET ROLE new_user;
SELECT CURRENT_USER;
RESET ROLE;

-- 1.4. Jako new_user wyświetl wszystkie bazy danych.
SET ROLE new_user;
SELECT * FROM pg_database;
RESET ROLE;


-- 2.1. Jako new_user spróbuj utworzyć nową bazę danych.
SET ROLE new_user;
CREATE DATABASE test;
RESET ROLE;

-- 2.2. Nadaj użytkownikowi new_user uprawnienia do tworzenia baz danych.
ALTER USER new_user CREATEDB;

-- 2.3. Jako new_user utwórz nową bazę danych.
SET ROLE new_user;
CREATE DATABASE test;
RESET ROLE;


-- 3.1. Jako new_user spróbuj wyświetlić wszystkie kraje.
SET ROLE new_user;
SELECT * FROM countries;
RESET ROLE;

-- 3.2. Nadaj użytkownikowi new_user uprawnienia do wyświetlania krajów z możliwością dalszego przekazywania uprawnień.
GRANT SELECT ON TABLE countries TO new_user WITH GRANT OPTION;

-- 3.3. Jako new_user wyświetl wszystkie kraje.
SET ROLE new_user;
SELECT * FROM countries;
RESET ROLE;


-- 4.1. Jako new_user spróbuj dodać nowy kraj.
SET ROLE new_user;
INSERT INTO countries (country_id, country_name, region_id)
	VALUES ('PL', 'Poland', 1)
RESET ROLE;

-- 4.2. Wyświetl wszystkie role.
SELECT * FROM pg_roles;

-- 4.3. Utwórz nową rolę o nazwie new_role i uczyń użytkownika new_user jej administratorem.
CREATE ROLE new_role
WITH
	ADMIN new_user;

-- 4.4. Nadaj roli new_role uprawnienia do dodawania i usuwania krajów.
GRANT INSERT, DELETE ON countries TO new_role;

-- 4.5. Jako new_user dodaj nowy kraj.
SET ROLE new_user;
INSERT INTO countries (country_id, country_name, region_id)
	VALUES ('PL', 'Poland', 1)
RESET ROLE;


-- 5.1. Utwórz nowego użytkownika o nazwie new_user2 z hasłem new_password2.
CREATE USER new_user2
WITH
	PASSWORD 'new_password2';

-- 5.2. Wyświetl wszystkie grupy użytkowników.
SELECT * FROM pg_group;

-- 5.3. Utwórz nową grupę użytkowników o nazwie new_group zawierającą użytkownika new_user.
CREATE GROUP new_group
WITH
	USER new_user;

-- 5.4. Dodaj do grupy new_group użytkownika new_user2.
ALTER GROUP new_group
ADD USER new_user2;


-- 6.1. Jako new_user spróbuj nadać użytkownikowi new_user2 uprawnienia do tworzenia baz danych.
SET ROLE new_user;
ALTER USER new_user2 CREATEDB;
RESET ROLE;

-- 6.2. Jako new_user spróbuj nadać użytkownikowi new_user2 uprawnienia do wyświetlania regionów.
SET ROLE new_user;
GRANT SELECT ON TABLE regions TO new_user2;
RESET ROLE;

-- 6.3. Jako new_user nadaj użytkownikowi new_user2 uprawnienia do wyświetlania krajów.
SET ROLE new_user;
GRANT SELECT ON TABLE countries TO new_user2;
RESET ROLE;

-- 6.4. Jako new_user nadaj użytkownikowi new_user2 rolę new_role.
SET ROLE new_user;
GRANT new_role TO new_user2;
RESET ROLE;


-- 7.1. Pozbaw użytkownika new_user roli new_role.
REVOKE new_role FROM new_user CASCADE;

-- 7.2. Jako new_user2 spróbuj usunąć dodany wcześniej kraj.
SET ROLE new_user2;
DELETE FROM countries WHERE country_id = 'PL';
RESET ROLE;

-- 7.3. Pozbaw użytkownika new_user uprawnień do wyświetlania krajów.
REVOKE SELECT ON countries FROM new_user CASCADE;


-- 8.1. Jako new_user2 spróbuj wyświetlić wszystkie kraje.
SET ROLE new_user2;
SELECT * FROM countries;
RESET ROLE;

-- 8.2. Nadaj grupie użytkowników new_group uprawnienia do wyświetlania krajów.
GRANT SELECT ON TABLE countries TO new_group;

-- 8.3. Jako new_user2 wyświetl wszystkie kraje.
SET ROLE new_user2;
SELECT * FROM countries;
RESET ROLE;


-- 9.1. Usuń użytkownika new_user2.
DROP USER new_user2;
