--1.1. Wyświetl wszystkie loginy.
SELECT * FROM sys.sql_logins;

--1.2. Utwórz nowy login o nazwie new_login z hasłem new_password, które musi zostać zmienione po pierwszym logowaniu oraz domyślną bazą danych HR.
CREATE LOGIN new_login
WITH PASSWORD = 'new_password' MUST_CHANGE,
CHECK_EXPIRATION = ON,
DEFAULT_DATABASE = hr;
GO

--1.3. Wyświetl informację o tym, czy włączony jest mieszany tryb uwierzytelniania. Jeżeli nie, to włącz go.
EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
N'Software\Microsoft\MSSQLServer\MSSQLServer',
N'LoginMode';
GO

EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
N'Software\Microsoft\MSSQLServer\MSSQLServer',
N'LoginMode', REG_DWORD, 2;
GO


--2.1. Wyświetl wszystkich użytkowników w bazie danych HR.
USE hr;
SELECT * FROM sys.database_principals WHERE TYPE IN ('S', 'U');

--2.2. Utwórz nowego użytkownika w bazie danych HR o nazwie new_user przypisanego do loginu new_login.
USE hr;
CREATE USER new_user FOR LOGIN new_login;
GO

--2.3. Jako new_user wyświetl nazwę loginu oraz nazwę użytkownika.
EXECUTE AS USER = 'new_user';
SELECT SUSER_SNAME() AS login, USER_NAME() AS username;
REVERT;
GO

--2.4. Jako new_user wyświetl wszystkie bazy danych.
EXECUTE AS USER = 'new_user';
SELECT * FROM sys.databases;
REVERT;
GO


--3.1. Jako new_user spróbuj zmienić kontekst bazodanowy na bazę danych model.
EXECUTE AS USER = 'new_user';
USE model;
REVERT;
GO

--3.2. Jako new_user spróbuj wyświetlić wszystkich pracowników.
USE hr;
EXECUTE AS USER = 'new_user';
SELECT * FROM employees;
REVERT;
GO

--3.3. Nadaj użytkownikowi new_user role systemowe db_datareader i db_ddladmin.
USE hr;
ALTER ROLE db_datareader ADD MEMBER new_user;
ALTER ROLE db_ddladmin ADD MEMBER new_user;
GO

--3.4. Jako new_user wyświetl wszystkich pracowników.
USE hr;
EXECUTE AS USER = 'new_user';
SELECT * FROM employees;
REVERT;
GO


--4.1. Jako new_user spróbuj dodać nowe stanowisko.
USE hr;
EXECUTE AS USER = 'new_user';
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
	VALUES ('Test', 'Test', 1000, 10000);
REVERT;
GO

--4.2. Nadaj użytkownikowi new_user uprawnienia do dodawania i usuwania stanowisk z możliwością dalszego przekazywania uprawnień.
GRANT INSERT, DELETE ON jobs
	TO new_user WITH GRANT OPTION;
GO

--4.3. Jako new_user dodaj nowe stanowisko.
EXECUTE AS USER = 'new_user';
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
	VALUES ('Test', 'Test', 1000, 10000);
REVERT;


--5.1. Jako new_user spróbuj zmodyfikować dodane wcześniej stanowisko.
EXECUTE AS USER = 'new_user';
UPDATE jobs
SET max_salary = 20000
WHERE job_id = 'Test';
REVERT;

--5.2. Utwórz nową rolę o nazwie new_role i uczyń użytkownika new_user jej właścicielem.
CREATE ROLE new_role AUTHORIZATION new_user;
GO

--5.3. Nadaj roli new_role uprawnienia do modyfikowania stanowisk.
GRANT UPDATE ON jobs TO new_role;

--5.4. Nadaj użytkownikowi new_user rolę new_role.
ALTER ROLE new_role ADD MEMBER new_user;

--5.5. Jako new_user zmodyfikuj dodane wcześniej stanowisko.
EXECUTE AS USER = 'new_user';
UPDATE jobs
SET max_salary = 20000
WHERE job_id = 'Test';
REVERT;


--6.1. Utwórz nowy login o nazwie new_login2 z hasłem new_password2 oraz domyślną bazą danych HR.
CREATE LOGIN new_login2
WITH PASSWORD = 'new_password2',
DEFAULT_DATABASE = hr;

--6.2. Utwórz nowego użytkownika w bazie danych HR o nazwie new_user2 przypisanego do loginu new_login2.
USE hr;
CREATE USER new_user2 FOR LOGIN new_login2;

--6.3. Nadaj użytkownikowi new_user2 rolę systemową db_datareader.
ALTER ROLE db_datareader
ADD MEMBER new_user2;


--7.1. Jako new_user spróbuj nadać użytkownikowi new_user2 rolę systemową db_ddladmin.
EXECUTE AS USER = 'new_user';
ALTER ROLE db_ddladmin ADD MEMBER new_user2;
REVERT;

--7.2. Jako new_user nadaj użytkownikowi new_user2 rolę new_role.
EXECUTE AS USER = 'new_user';
ALTER ROLE new_role ADD MEMBER new_user2;
REVERT;

--7.3. Jako new_user spróbuj nadać użytkownikowi new_user2 uprawnienia do dodawania i usuwania pracowników.
EXECUTE AS USER = 'new_user';
GRANT INSERT, DELETE ON employees TO new_user2;
REVERT;

--7.4. Jako new_user nadaj użytkownikowi new_user2 uprawnienia do dodawania i usuwania stanowisk.
EXECUTE AS USER = 'new_user';
GRANT INSERT, DELETE ON jobs TO new_user2;
REVERT;


--8.1. Pozbaw użytkownika new_user uprawnień do usuwania stanowisk.
REVOKE DELETE ON jobs FROM new_user CASCADE;

--8.2. Jako new_user2 spróbuj usunąć dodane wcześniej stanowisko.
EXECUTE AS USER = 'new_user2';
DELETE FROM jobs
WHERE job_id = 'Test';
REVERT;


--9.1. Dezaktywuj login new_login2.
ALTER LOGIN new_login2 DISABLE;

--9.2. Zmień nazwę loginu new_login2 na disabled_login2.
ALTER LOGIN new_login2
WITH NAME = disabled_login_2;
