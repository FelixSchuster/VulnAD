# Modul domaincontroller

Hier geht's zurück zur [Dokumentation der Grundstruktur](./cfg_root.md).

## Modulbeschreibung in Tabellenform

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|host_name           |Ja      |Der zu vergebende Hostname.                |String               |`"DC-01"`                  |
|default_user        |Ja      |Die zu vergebenden Credentials des lokalen Accounts.|default_user         |Siehe [default_user](./cfg_default_user.md)       |
|network_interface   |Nein    |Das Netzwerkinterface, das für das Setup genutzt werden soll.<br>Default: `"Ethernet"`|String               |`"Ethernet"`               |
|ip_address          |Ja      |Die zu vergebende IP-Adresse.              |String               |`"10.0.0.10"`              |
|subnet_mask         |Ja      |Die Subnetzmaske des Netzwerkes.           |String               |`"255.255.255.0"`          |
|default_gateway     |Ja      |Das Default Gateway des Netzwerkes.        |String               |`"10.0.0.1"`               |
|primary_dns         |Ja      |Der primäre DNS-Server.<br>Empfohlen für den DC: `"127.0.0.1"`<br>Empfohlen für die Workstations: IP-Adresse des DCs|String               |`"127.0.0.1"`              |
|secondary_dns       |Ja      |Der sekundäre DNS-Server.<br>Empfohlen: `"8.8.8.8"`|String               |`"8.8.8.8"`                |
|dsrm_password       |Ja      |Das zu setzende DSRM-Passwort für die Domäne.|String               |`"DSRM-P@ssword"`          |
|has_rdp_enabled     |Nein    |Option für das automatisierte Starten von RDP.<br>Wenn true: Zusätzlich wird der RestrictedAdmin Mode deaktiviert, um Pass-The-Hash Angriffe zu ermöglichen.|Boolean              |`true`/`false`               |
|has_iis_installed   |Nein    |Option für das automatisierte Installieren des IIS-Webservers.<br>Wenn true: Der Webserver wird auf Port 80 gehostet. Die Dateien im Ordner `.\Website\*` werden gehostet.|Boolean              |`true`/`false`               |
|fileshares          |Nein    |Option für das automatisierte Hosten von Fileshares.<br>Wenn angegeben: Die Dateien im Ordner `.\Fileshares\<Sharename>\*` werden geteilt. Per Group Policy verbinden sich alle Workstations in der Domäne mit den angegebenen Fileshares. Derzeit ist es nicht möglich, ACLs zu erstellen, alle Konten besitzen Zugriff auf die gehostetet Fileshares.|fileshare[]          |Siehe [fileshare](./cfg_fileshare.md)          |
|mssqlserver         |Nein    |Option für das automatisierte Hosten eines MSSQL-Servers.<br>Wenn angegeben: Eine MSSQL-Server Instanz wird auf Port 1433 gehostet.|mssqlserver          |Siehe [mssqlserver](./cfg_mssqlserver.md)        |

## Modulbeschreibung im JSON-Format

```json
{
    "host_name": "DC-01",
    "default_user": {
        ...
    },
    "network_interface": "Ethernet",
    "ip_address": "10.0.0.10",
    "subnet_mask": "255.255.255.0",
    "default_gateway": "10.0.0.1",
    "primary_dns": "127.0.0.1",
    "secondary_dns": "8.8.8.8",
    "dsrm_password": "DSRM-P@ssword",
    "has_rdp_enabled": true,
    "has_iis_installed": true,
    "fileshares": [
        ...
    ],
    "mssqlserver": {
        ...
    }
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
