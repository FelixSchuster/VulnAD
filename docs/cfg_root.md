# Grundstruktur der Konfigurationsdatei

In dieser Dokumentation wird beschrieben, wie Konfigurationdateien für VulnAD aufzubauen sind.
Beispiele für valide Konfigurationsdateien sind im `examples`-Ordner zu finden.

## Grundstruktur in Tabellenform

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|domain_name         |Ja      |Der zu vergebende Domainname.              |String               |`"vulncorp.lab"`           |
|domaincontroller    |Ja      |Konfiguration für den Domaincontroller.    |domaincontroller     |Siehe [domaincontroller](./cfg_domaincontroller.md)   |
|workstations        |Ja      |Konfiguration für die Workstations.        |workstation[]        |Siehe [workstation](./cfg_workstation.md)        |
|organizational_units|Nein    |Konfiguration für die Organizational Units.|organizational_unit[]|Siehe [organizational_unit](./cfg_organizational_unit.md)|
|user_accounts       |Ja      |Konfiguration für die User Accounts.       |user_account[]       |Siehe [user_account](./cfg_user_account.md)       |
|service_accounts    |Nein    |Konfiguration für die Service Accounts.    |service_account[]    |Siehe [service_account](./cfg_service_account.md)    |

## Grundstruktur im JSON-Format

```json
{
    "domain_name": "vulncorp.lab",
    "domaincontroller": {
        ...
    },
    "workstations": [
        ...
    ],
    "organizational_units": [
        ...
    ],
    "user_accounts": [
        ...
    ],
    "service_accounts": [
        ...
    ]
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
