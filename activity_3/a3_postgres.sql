-- 1. Dla każdego pracownika, wyświetl jego imię, nazwisko oraz informację o prowizji:
--        – "Brak prowizji" w przypadku, gdy pracownik nie ma podanej prowizji,
--        – "Nieznana prowizja" w przypadku, gdy prowizja pracownika nie może być porównana względem pozostałych
--          pracowników z tego samego działu,
--        – "Niska prowizja" w przypadku, gdy iloczyn prowizji i minimalnego wynagrodzenia dla stanowiska pracownika
--          jest mniejszy niż średnie wynagrodzenie wszystkich pracowników z działu tego pracownika pomniejszone o 5000,
--        – "Wysoka prowizja" w pozostałych przypadkach.
--    Kolumnę z informacją o prowizji nazwij commission_info.
--    Wynik posortuj według ostatniej informacji.
--    W rozwiązaniu wykorzystaj instrukcję warunkową.

-- PostgreSQL



-- 2. Wyświetl nazwy krajów, nazwy regionów oraz liczby departamentów znajdujących się w każdym kraju.
--    Wyniki ogranicz w zależności od liczby departamentów w następujący sposób:
--        – uwzględnij tylko te kraje z regionu Europe, które mają więcej niż 1 departament,
--        – uwzględnij tylko te kraje z regionu Americas, które mają więcej niż 3 departamenty,
--        – nie uwzględniaj krajów z pozostałych regionów.
--    W rozwiązaniu wykorzystaj instrukcję warunkową CASE w klauzuli HAVING.
--    Dodatkowo wskaż pozostałe klauzule, w których także można wykorzystać instrukcję warunkową CASE.

-- PostgreSQL



-- 3. Przeanalizuj poniższy ciąg wartości i znajdź zależności:
--      5.
--      4.
--      4.1.
--      4.3.
--      4.4.
--      3.
--      3.1.
--      3.3.
--      2.
--      2.1.
--      1.
--      1.1.
--    Napisz blok anonimowy, który wypisze powyższe wartości.
--    W rozwiązaniu wykorzystaj pętlę LOOP oraz funkcje wyjścia, kontynuowania i/lub przerwania iteracji.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje pętla LOOP, wykorzystaj inny, dostępny rodzaj pętli.

-- PostgreSQL



-- 4. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne.
--    Wypisz nazwy kolejnych miast zaczynając od lokalizacji z ID równym 1500 i kończąc na lokalizacji z ID równym 2500.
--    Załóż, że w bazie danych nie brakuje żadnych wartości ID lokalizacji w powyższym przedziale, gdzie krok
--    wynosi 100.
--    Dla każdego miasta wypisz dodatkowo tyle par nawiasów prostokątnych ( [] ), ile departamentów znajduje się w nim.
--    Uwaga! Jeżeli dany system to umożliwia, wykorzystaj %TYPE przy deklaracji zmiennych.
--    Uwaga! Jeżeli dany system to umożliwia, użyj 1 pętli FOR oraz 1 pętli WHILE.

-- PostgreSQL



-- 5. Stwórz blok anonimowy i zadeklaruj w nim zmienne dla sumy wynagrodzeń i kwoty granicznej.
--    Jeżeli suma wynagrodzeń jest mniejsza lub równa określonej kwocie granicznej, wypisz sumę wynagrodzeń
--    wszystkich pracowników. W przeciwnym razie wywołaj tylko swój wyjątek i wypisz adekwatną informację.
--    Wypróbuj swoje rozwiązanie dla kwot granicznych 500 000 i 700 000.
--    Dodatkowo wskaż różnice pomiędzy:
--        – THROW i RAISERROR w Microsoft SQL Server,
--        – RAISE EXCEPTION, RAISE WARNING, RAISE NOTICE i RAISE INFO w PostgreSQL.

-- PostgreSQL



-- 6. Stwórz blok anonimowy i zadeklaruj w nim zmienne dla nazwy departamentu i nazwy miasta.
--    Wypisz nazwę departamentu, który znajduje się w wybranym mieście.
--    Złap wyjątki systemowe za pomocą ich nazw w przypadkach, gdy taki departament nie istnieje lub istnieje więcej
--    niż 1 taki departament - wypisz adekwatną informację.
--    Wypróbuj swoje rozwiązanie dla miast Venice, Munich i Seattle.
--    Dodatkowo sprawdź, w jaki sposób zapisywane są wartości do zmiennych przy poleceniu SELECT, które zwraca więcej
--    niż jedną wartość lub nie zwraca nic.
--    Uwaga! Jeżeli w jakimś systemie nie istnieją wyjątki systemowe dotyczące braku wyników lub zbyt dużej liczby
--    wyników, zaproponuj jak najprostsze rozwiązanie, które umożliwi przechwycenie takich błędów.

-- PostgreSQL



-- 7. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor z parametrem odnoszącym się do nazwy
--    kraju.
--    Wypisz numery ID lokalizacji oraz nazwy miast z kraju United States of America, którego nazwa jest przesyłana
--    do kursora.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje kursor z parametrem, zapisz nazwę podanego kraju w zmiennej
--    i wykorzystaj ją w kursorze.

-- PostgreSQL



-- 8. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne oraz kursor.
--    Usuń wszystkie lokalizacje, w których nie ma żadnego departamentu.
--    W rozwiązaniu wykorzystaj klauzulę WHERE CURRENT OF w odniesieniu do kursora.
--    Dodatkowo wymień wszystkie polecenia, z którymi można wykorzystać klauzulę WHERE CURRENT OF w odniesieniu
--    do kursora.

-- PostgreSQL



-- 9. Stwórz blok anonimowy i zadeklaruj w nim odpowiednie zmienne.
--    Dla każdej lokalizacji, wypisz wszystkie dane na jej temat razem z dodanymi opisami.
--    Kolejność danych w jednej wiadomości to: ID lokalizacji, adres, kod pocztowy, miasto, stan/prowincja oraz
--    id kraju. Zwróć uwagę, żeby nie wyświetlać poszczególnych opisów w przypadku braku podanej wartości.
--    Uwaga! Jeżeli dany system to umożliwia, wykorzystaj kursor z FOR LOOP.
--    Uwaga! Jeżeli dany system to umożliwia, użyj %ROWTYPE przy deklaracji zmiennej.

-- PostgreSQL

