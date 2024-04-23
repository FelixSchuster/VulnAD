# Dokumentation der Konfigurationsdatei: Grundstruktur

Die in diesem Ordner enthaltenen Markdown-Dateien beschreiben, wie Konfigurationdateien für VulnAD aufzubauen sind.
Beispiele für valide Konfigurationsdateien sind im `examples`-Ordner zu finden.

## Grundstruktur in Tabellenform

Die Grundstruktur der Konfigurationsdatei ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|domain_name         |Ja      |Der zu vergebende Domainname.              |String               |`"vulncorp.lab"`           |
|domaincontroller    |Ja      |Konfiguration für den Domaincontroller.    |domaincontroller     |Siehe [domaincontroller](./domaincontroller.md)   |
|workstations        |Ja      |Konfiguration für die Workstations.        |workstation[]        |Siehe [workstation](./workstation.md)        |
|organizational_units|Nein    |Konfiguration für die Organizational Units.|organizational_unit[]|Siehe [organizational_unit](./organizational_unit.md)|
|user_accounts       |Ja      |Konfiguration für die User Accounts.       |user_account[]       |Siehe [user_account](./user_account.md)       |
|service_accounts    |Nein    |Konfiguration für die Service Accounts.    |service_account[]    |Siehe [service_account](./service_account.md)    |

## Grundstruktur im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.

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
