# Modul fileshare

Hier geht's zurück zur [Dokumentation der Grundstruktur](./cfg_root.md).

## Modulbeschreibung in Tabellenform

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|name                |Ja      |Name des zu hostenden Fileshares.          |String               |`"Share1"`                 |
|path                |Ja      |Lokaler Speicherort der zu hostenden Dateien.|String               |`"C:\\Shares\\Share1"`  |
|drive               |Ja      |Das Laufwerk, auf das der Fileshare gemapped werden soll.|String               |`"Z"`                      |

## Modulbeschreibung im JSON-Format

```json
{
    "name": "Share1",
    "path": "C:\\Shares\\Share1",
    "drive": "Z"
}
```
