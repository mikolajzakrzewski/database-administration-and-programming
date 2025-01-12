--1.1. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--1.2. Wyświetl pensję pracownika o identyfikatorze równym 100.
USE hr;
SELECT salary FROM employees
WHERE employee_id = 100;

--1.3. Rozpocznij transakcję.
BEGIN TRANSACTION;

--1.4. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--1.5. Podwyższ o 1000 zł pensję pracownika o identyfikatorze równym 100.
UPDATE employees
SET salary = salary + 1000
WHERE employee_id = 100;

--1.6. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--1.7. Zatwierdź transakcję.
COMMIT TRANSACTION;

--1.8. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--1.9. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;


--2.1. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--2.2. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--2.3. Rozpocznij transakcję.
BEGIN TRANSACTION;

--2.4. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--2.5. Obniż o 1000 zł pensję pracownika o identyfikatorze równym 100.
UPDATE employees
SET salary = salary - 1000
WHERE employee_id = 100;

--2.6. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--2.7. Wycofaj transakcję.
ROLLBACK TRANSACTION;

--2.8. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--2.9. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;


--3.1. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--3.2. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--3.3. Rozpocznij transakcję.
BEGIN TRANSACTION;

--3.4. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--3.5. Obniż o 1000 zł pensję pracownika o identyfikatorze równym 100.
UPDATE employees
SET salary = salary - 1000
WHERE employee_id = 100;

--3.6. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--3.7. Utwórz punkt zapisu o nazwie new_checkpoint.
SAVE TRANSACTION new_checkpoint;

--3.8. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--3.9. Podwyższ o 1000 zł pensję pracownika o identyfikatorze równym 100.
UPDATE employees
SET salary = salary + 1000
WHERE employee_id = 100;

--3.10. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--3.11. Wycofaj transakcję do punktu zapisu new_checkpoint.
ROLLBACK TRANSACTION new_checkpoint;

--3.12. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--3.13. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;

--3.14. Zatwierdź transakcję.
COMMIT TRANSACTION;

--3.15. Wyświetl wszystkie otwarte w ramach sesji transakcje.
SELECT * FROM sys.dm_tran_session_transactions
WHERE session_id = @@SPID;

--3.16. Wyświetl pensję pracownika o identyfikatorze równym 100.
SELECT salary FROM employees
WHERE employee_id = 100;


--4.1. Wyświetl listę wszystkich kopii zapasowych.
SELECT * FROM msdb.dbo.backupset;

--4.2. Utwórz pełną kopię zapasową bazy danych HR i zapisz ją do pliku o nazwie HR_full.bak.
BACKUP DATABASE hr
TO DISK = '/hr_full.bak';
GO

--4.3. Wyświetl listę wszystkich kopii zapasowych.
SELECT * FROM msdb.dbo.backupset;

--4.4. Wyświetl liczbę wszystkich pracowników.
SELECT COUNT(*) AS employee_count FROM employees;

--4.5. Usuń pracownika o identyfikatorze równym 206.
DELETE FROM employees
WHERE employee_id = 206;

--4.6. Wyświetl liczbę wszystkich pracowników.
SELECT COUNT(*) AS employee_count FROM employees;


--5.1. Utwórz różnicową kopię zapasową bazy danych HR i zapisz ją do pliku o nazwie HR_differential.bak.
BACKUP DATABASE hr
TO DISK = '/hr_differential.bak'
	WITH DIFFERENTIAL;
GO

--5.2. Wyświetl listę wszystkich kopii zapasowych.
SELECT * FROM msdb.dbo.backupset;

--5.3. Usuń pracownika o identyfikatorze równym 202.
DELETE FROM employees
WHERE employee_id = 202;

--5.4. Wyświetl liczbę wszystkich pracowników.
SELECT COUNT(*) AS employee_count FROM employees;


--6.1. Przywróć bazę danych HR na podstawie pliku o nazwie HR_differential.bak.
USE master;
RESTORE DATABASE hr
FROM DISK = '/hr_full.bak'
	WITH NORECOVERY,
		REPLACE;
GO
RESTORE DATABASE hr
FROM DISK = '/hr_differential.bak'
	WITH RECOVERY;
GO


--6.2. Wyświetl liczbę wszystkich pracowników.
USE hr;
SELECT COUNT(*) AS employee_count FROM employees;

--6.3. Przywróć bazę danych HR na podstawie pliku o nazwie HR_full.bak.
USE master;
RESTORE DATABASE hr
FROM DISK = '/hr_full.bak'
	WITH RECOVERY,
		REPLACE;
GO

--6.4. Wyświetl liczbę wszystkich pracowników.
USE hr;
SELECT COUNT(*) AS employee_count FROM employees;


--7.1. Wyświetl listę wszystkich zadań.
EXEC msdb.dbo.sp_help_job;

--7.2. Utwórz zadanie o nazwie HR_full_backup.
EXEC msdb.dbo.sp_add_job
	@job_name = N'hr_full_backup';
GO

--7.3. Wyświetl listę wszystkich zadań.
EXEC msdb.dbo.sp_help_job;

--7.4. Utwórz krok zadania o nazwie backup, który utworzy pełną kopię zapasową bazy danych HR i zapisze ją do pliku o nazwie HR_full.bak.
EXEC msdb.dbo.sp_add_jobstep
	@job_name = N'hr_full_backup',
	@step_name = N'backup',
	@subsystem = N'TSQL',
	@command = N'BACKUP DATABASE hr TO DISK = "/hr_full.bak"';
GO


--8.1. Wyświetl listę wszystkich harmonogramów.
EXEC msdb.dbo.sp_help_schedule;

--8.2. Utwórz harmonogram o nazwie every_Sunday, który od 1 stycznia 2024 roku będzie wykonywany w każdą niedzielę o 3:00.
EXEC msdb.dbo.sp_add_schedule
	@schedule_name = N'every_Sunday',
	@freq_type = 8,
	@freq_interval = 1,
	@freq_recurrence_factor = 1,
	@active_start_date = 20240101,
	@active_start_time = 030000;
GO

--8.3. Wyświetl listę wszystkich harmonogramów.
EXEC msdb.dbo.sp_help_schedule;


--9.1. Przypisz harmonogram o nazwie every_Sunday do zadania o nazwie HR_full_backup.
EXEC msdb.dbo.sp_attach_schedule
	@job_name = N'hr_full_backup',
	@schedule_name = N'every_Sunday';
GO

--9.2. Przypisz zadanie o nazwie HR_full_backup do lokalnego serwera.
EXEC msdb.dbo.sp_add_jobserver
	@job_name = N'hr_full_backup';
GO

--9.3. Dezaktywuj harmonogram o nazwie every_Sunday.
EXEC msdb.dbo.sp_update_schedule
	@name = N'every_Sunday',
	@enabled = 0;
GO
