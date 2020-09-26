# Projekt z przedmiotu Bazy danych
## Mateusz Markiewicz (298653)

## Pierwsze Uruchomienie
Do uruchomienia niezbędna jest baza danych 'student' oraz użytkownik 'app' z hasłem 'qwerty'. Dodatkowo wymagane jest rozszerzenie PostGis (create extension postgis).
Przed uruchomieniem aplikacji baza powinna być pusta. Pierwsze uruchomienie powinno wyglądać następująco:
> python main.py --init

Takie wywołanie wczyta oraz wykona plik 'database.sql' zawierający model fizyczny bazy.

## Kolejne uruchomienia
Każde następne uruchomienie powinno składać się z ciągu jednego lub więcej zapytań w formie obiektów JSON przekazanych za pomocą standardowego wejścia. W rezultacie na standardowym wyjściu zostanie wypisany wynik kolejnych zapytań, również w formie obiektu JSON ze statusem "OK" w przypadku poprawnego zapytania (z opcjonalnym polem "data" zawierającym wynik zapytania) lub "ERROR" w przypadku niepoprawnego zapytania.

## Drop
Możliwe jest również wywołanie z parametrem '--drop', co powoduje dropowanie wszystkich tabel stworzonych za pomocą opcji '--init'