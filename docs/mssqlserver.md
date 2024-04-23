# Dokumentation der Konfigurationsdatei: Modul mssqlserver

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul mssqlserver ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|service_account     |Ja      |Account, mit dem das Service gestartet werden soll.<br>Der Accountname muss unter service_accounts hinterlegt sein.|String               |`"sqluser"`                |
|service_administrator_accounts|Ja      |Accounts, die Admin-Berechtigungen erhalten sollen.<br>Die Accountnamen müssen als [user_account](./user_account.md) oder [service_account](./service_account.md) hinterlegt sein.|String[]             |`"alice", "sqluser"`       |

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.

```json
{
    "service_account": "sqluser",
    "service_administrator_accounts": [
        "alice", "sqluser"
    ]
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
