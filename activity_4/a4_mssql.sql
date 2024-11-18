-- 1. Utwórz procedurę proc1, która z wykorzystaniem kursora wypisze nazwy miast, w których realne maksymalne zarobki
--    pracowników są niższe od podanej kwoty.
--    Wywołaj ją z parametrem 10000.

-- Microsoft SQL Server



-- 2. Utwórz procedurę proc2, która dodaje informacje o nowym departamencie do bazy danych.
--    ID nowego departamentu musi być automatycznie wyliczane zgodnie z zasadą nadawania ID dla departamentów.
--    Nazwa departamentu musi być podana jako parametr procedury.
--    ID menadżera domyślnie nie ma wpisywanej wartości, ale można ją podać jako parametr procedury.
--    ID lokalizacji ma domyślnie ustawioną wartość 2000, jednakże można podać także inną wartość jako parametr
--    procedury.
--    Wywołaj procedurę proc2 na wszystkie możliwe sposoby, żeby przetestować działanie parametrów domyślnych.

-- Microsoft SQL Server



-- 3. Utwórz procedurę proc3, która podwyższy prowizję o podaną liczbę punktów procentowych u pracowników zatrudnionych
--    przed podanym rokiem i poprzez parametr wyjściowy zwróci liczbę zmodyfikowanych rekordów.
--    Wywołaj ją z parametrami 2004 oraz 0.05.

-- Microsoft SQL Server



-- 4. Utwórz funkcję func4, która zwróci procentowy udział liczby pracowników zatrudnionych w podanym departamencie
--    w łącznej liczbie wszystkich pracowników.
--    Wynik zaokrąglij do części setnych.
--    Wywołaj ją dla wszystkich departamentów wewnątrz zapytania dającego wynik w postaci trzech kolumn: department_id,
--    department_name, percentage.

-- Microsoft SQL Server



-- 5. Utwórz funkcję func5, która zwróci wszystkie informacje o departamentach mających siedzibę w podanym kraju.
--    Wywołaj ją z parametrem Canada wewnątrz zapytania dającego wynik w postaci dwóch kolumn: department_id,
--    department_name.

-- Microsoft SQL Server



-- 6. Utwórz funkcję func6, która zwróci kursor z informacjami o pracownikach (imię, nazwisko oraz nazwa stanowiska),
--    których menadżerem jest podany pracownik.
--    Wywołaj ją z parametrami "Matthew" i "Weiss".
--    Następnie wypisz spośród nich tylko tych pracowników (ich imiona i nazwiska), którzy zajmują stanowisko
--    Stock Clerk.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje funkcja zwracająca kursor, wykorzystaj funkcję zwracającą tabelę
--    oraz kursor.

-- Microsoft SQL Server



-- 7. Utwórz wyzwalacz, który przed dodaniem pracownika sprawdzi, czy data zatrudnienia jest przyszłą datą.
--    Jeżeli warunek jest spełniony, to wyświetli tylko komunikat "Niedozwolona operacja!".
--    Jeżeli warunek nie jest spełniony, to doda pracownika.
--    Potwierdź działanie dla dwóch przypadków testowych.
--    Uwaga! W niektórych systemach wymagane jest utworzenie własnej funkcji i/lub widoku tabeli pracownicy.

-- Microsoft SQL Server



-- 8. Utwórz wyzwalacz, który po usunięciu jednego lub wielu miast za pomocą pojedynczego polecenia wypisze ich nazwy
--    oraz nazwy ich krajów.
--    Potwierdź działanie poprzez usunięcie wszystkich miast, w których żaden departament nie ma swojej siedziby.
--    Uwaga! W niektórych systemach wymagane jest utworzenie kursora lub własnej funkcji.

-- Microsoft SQL Server



-- 9. Utwórz wyzwalacz, który przed podwyższeniem prowizji menadżera departamentu sprawdzi jej nową wartość.
--    Jeżeli nowa prowizja jest co najmniej dwukrotnie większa od poprzedniej, to zmniejszy jej nową wartość
--    do dwukrotności poprzedniej wartości. Jeżeli menadżer departamentu nie miał wcześniej przypisanej prowizji,
--    nowa wartość może wynieść maksymalnie 0,1. Potwierdź działanie wyzwalacza aktualizując wybranych pracowników
--    z departamentów o id równym 20 i 80.
--    Uwaga! W niektórych systemach wymagane jest utworzenie własnej funkcji.
--    Uwaga! Jeżeli w jakimś systemie nie istnieje wyzwalacz BEFORE, wykorzystaj wyzwalacz INSTEAD OF.

-- Microsoft SQL Server

