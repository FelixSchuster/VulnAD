# Dokumentation der Konfigurationsdatei: Modul default_user

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul default_user ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|user_name           |Ja      |Der Accountname für den lokalen Account.<br>Dieses Feld wird derzeit ignoriert, stattdessen wird der Accountname des  Accounts, mit dem das Setup gestartet wird, übernommen.|String               |`"Admin"`                  |
|password            |Ja      |Das Passwort für den lokalen Account.<br>Das Passwort muss nicht dem aktuellen Passwort des Accounts entsprechen und wird im Laufe des Setups auf das hier angegebene Passwort geändert.|String               |`"Admin-P@ssword"`         |

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.

```json
{
    "user_name": "Admin",
    "password": "Admin-P@ssword"
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
