# Dokumentation der Konfigurationsdatei: Modul organizational_unit

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul organizational_unit ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|name                |Ja      |Der zu vergebende Name der Organizational Unit.|String               |`"people"`                 |
|path                |Ja      |Der Pfad der Organizational Unit.          |String               |`"DC=vulncorp,DC=lab"`     |

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.

```json
{
    "name": "people",
    "path": "DC=vulncorp,DC=lab"
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
