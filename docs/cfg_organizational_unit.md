# Modul organizational_unit

Hier geht's zurück zur [Dokumentation der Grundstruktur](./cfg_root.md).

## Modulbeschreibung in Tabellenform

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|name                |Ja      |Der zu vergebende Name der Organizational Unit.|String               |`"people"`                 |
|path                |Ja      |Der Pfad der Organizational Unit.          |String               |`"DC=vulncorp,DC=lab"`     |

## Modulbeschreibung im JSON-Format

```json
{
    "name": "people",
    "path": "DC=vulncorp,DC=lab"
}
```
