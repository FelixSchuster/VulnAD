# Dokumentation der Konfigurationsdatei: Modul fileshare

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul fileshare ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|name                |Ja      |Name des zu hostenden Fileshares.          |String               |`"Share1"`                 |
|path                |Ja      |Lokaler Speicherort der zu hostenden Dateien.|String               |`"C:\\Shares\\Share1"`  |
|drive               |Ja      |Das Laufwerk, auf das der Fileshare gemapped werden soll.|String               |`"Z"`                      |

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.

```json
{
    "name": "Share1",
    "path": "C:\\Shares\\Share1",
    "drive": "Z"
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
