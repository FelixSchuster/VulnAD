# Dokumentation der Konfigurationsdatei: Modul user_account

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul user_account ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|sam_account_name    |Ja      |Der zu vergebende SamAccountName für den  Account.|String               |`"asmith"`                 |
|given_name          |Ja      |Der zu vergebende Vorname für den  Account.|String               |`"Alice"`                  |
|surname             |Ja      |Der zu vergebende Nachname für den  Account.|String               |`"Smith"`                  |
|password            |Ja      |Das zu vergebende Passwort für den  Account.|String               |`"Alice-P@ssword"`         |
|path                |Ja      |Die Organizational Unit, der der Account angehören sein soll.<br>Die OU muss als [organizational_unit](./organizational_unit.md) hinterlegt sein.|String               |`"OU=people,DC=vulncorp,DC=lab"`|
|is_domain_administrator|Nein    |Option für das Vergeben von Domainadmin-Berechtigungen.|Boolean              |`true`/`false`               |
|has_pre_auth_disabled|Nein    |Option für das Deaktivieren der Kerberos Pre-Authentication.<br>Kann genutzt werden, um AS-REP Roasting Angriffe nachzustellen.|Boolean              |`true`/`false`               |

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.\

```json
{
    "sam_account_name": "asmith",
    "given_name": "Alice",
    "surname": "Smith",
    "password": "Alice-P@ssword",
    "path": "OU=people,DC=vulncorp,DC=lab",
    "is_domain_administrator": true,
    "has_pre_auth_disabled": true
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
