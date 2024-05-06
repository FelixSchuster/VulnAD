# Modul mssqlserver

Hier geht's zurück zur [Dokumentation der Grundstruktur](./cfg_root.md).

## Modulbeschreibung in Tabellenform

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|service_account     |Ja      |Account, mit dem das Service gestartet werden soll.<br>Der Accountname muss unter service_accounts hinterlegt sein.|String               |`"sqluser"`                |
|service_administrator_accounts|Ja      |Accounts, die Admin-Berechtigungen erhalten sollen.<br>Die Accountnamen müssen als [user_account](./cfg_user_account.md) oder [service_account](./cfg_service_account.md) hinterlegt sein.|String[]             |`"alice", "sqluser"`       |

## Modulbeschreibung im JSON-Format

```json
{
    "service_account": "sqluser",
    "service_administrator_accounts": [
        "alice", "sqluser"
    ]
}
```
