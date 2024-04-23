# Dokumentation der Konfigurationsdatei: Modul service_account

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul service_account ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|sam_account_name    |Ja      |Der zu vergebende SamAccountName für den  Account.|String               |`"sqluser"`                |
|name                |Ja      |Der zu vergebende Name für den  Account.   |String               |`"sqluser"`                |
|password            |Ja      |Das zu vergebende Passwort für den  Account.|String               |`"sqluser-P@ssword"`       |
|path                |Ja      |Die Organizational Unit, der der Account angehören sein soll.<br>Die OU muss als [organizational_unit](./organizational_unit.md) hinterlegt sein.|String               |`"OU=services,DC=vulncorp,DC=lab"`|
|is_domain_administrator|Nein    |Option für das Vergeben von Domainadmin-Berechtigungen.|Boolean              |`true`/`false`               |
|has_pre_auth_disabled|Nein    |Option für das Deaktivieren der Kerberos Pre-Authentication.<br>Kann genutzt werden, um AS-REP Roasting Angriffe nachzustellen.|Boolean              |`true`/`false`               |
|service_principal_name|Ja      |Der zu vergebende ServicePrincipalName für den Account.|String               |`"MSSQLSvc/DC-01.vulncorp.lab:1433"`|

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.\

```json
{
    "sam_account_name": "sqluser",
    "name": "sqluser",
    "password": "sqluser-P@ssword",
    "path": "OU=services,DC=vulncorp,DC=lab",
    "is_domain_administrator": true,
    "has_pre_auth_disabled": true,
    "service_principal_name": "MSSQLSvc/DC-01.vulncorp.lab:1433"
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
