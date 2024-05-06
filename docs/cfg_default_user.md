# Modul default_user

Hier geht's zurück zur [Dokumentation der Grundstruktur](./cfg_root.md).

## Modulbeschreibung in Tabellenform

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|user_name           |Ja      |Der Accountname für den lokalen Account.<br>Dieses Feld wird derzeit ignoriert, stattdessen wird der Accountname des  Accounts, mit dem das Setup gestartet wird, übernommen.|String               |`"Admin"`                  |
|password            |Ja      |Das Passwort für den lokalen Account.<br>Das Passwort muss nicht dem aktuellen Passwort des Accounts entsprechen und wird im Laufe des Setups auf das hier angegebene Passwort geändert.|String               |`"Admin-P@ssword"`         |

## Modulbeschreibung im JSON-Format

```json
{
    "user_name": "Admin",
    "password": "Admin-P@ssword"
}
```
