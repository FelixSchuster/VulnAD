# Dokumentation der Konfigurationsdatei: Modul workstation

Hier geht's zurück zur [Dokumentation der Grundstruktur](./configuration_root.md).

## Modulbeschreibung in Tabellenform

Das Modul workstation ist wie in folgender Tabelle dargestellt festgelegt.

|Parameter           |Required|Beschreibung                               |Datentyp             |Beispiel                 |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|host_name           |Ja      |Der zu vergebende Hostname.                |String               |`"WKST-01"`                |
|default_user        |Ja      |Die zu vergebenden Credentials des lokalen Accounts.|default_user         |Siehe [default_user](./default_user.md)       |
|network_interface   |Nein    |Das Netzwerkinterface, das für das Setup genutzt werden soll.<br>Default: `"Ethernet"`|String               |`"Ethernet"`               |
|ip_address          |Ja      |Die zu vergebende IP-Adresse.              |String               |`"10.0.0.100"`             |
|subnet_mask         |Ja      |Die Subnetzmaske des Netzwerkes.           |String               |`"255.255.255.0"`          |
|default_gateway     |Ja      |Das Default Gateway des Netzwerkes.        |String               |`"10.0.0.1"`               |
|primary_dns         |Ja      |Der primäre DNS-Server.<br>Empfohlen für den DC: `"127.0.0.1"`<br>Empfohlen für die Workstations: IP-Adresse des DCs|String               |`"10.0.0.10"`              |
|secondary_dns       |Ja      |Der sekundäre DNS-Server.<br>Empfohlen: `"8.8.8.8"`|String               |`"8.8.8.8"`                |
|has_rdp_enabled     |Nein    |Option für das automatisierte Starten von RDP.<br>Wenn true: Zusätzlich wird der RestrictedAdmin Mode deaktiviert, um Pass-The-Hash Angriffe zu ermöglichen.|Boolean              |`true`/`false`               |
|logged_in_users     |Nein    |Domainaccounts, die sich einmal auf dieser Box angemeldet haben.<br>Kann genutzt werden, um Passwort-Hashes im Cache der Box zu hinterlassen. Unter *logged_in_users* oder *local_administrators* muss mindestens ein Account hinterlegt sein, um das Setup zu ermöglichen. Wird ein Account für das Setup genutzt, der keine Administratorberechtigungen besitzt, werden diesem während der Dauer des Setups die entsprechenden Berechtigungen vergeben und anschließend wieder entzogen.  Die Accountnamen müssen als [user_account](./user_account.md) oder [service_account](./service_account.md) hinterlegt sein.|String[]             |`"alice", "bob", "charlie"`|
|local_administrators|Nein    |Domainaccounts, für die lokale Administratorberechtigungen konfiguriert werden sollen.<br>Hier eingetragene Accounts hinterlassen Passwort-Hashes im Cache der Box. Unter *logged_in_users* oder *local_administrators* muss mindestens ein Account hinterlegt sein, um das Setup zu ermöglichen. Die Accountnamen müssen als [user_account](./user_account.md) oder [service_account](./service_account.md) hinterlegt sein.|String[]             |`"alice", "bob"`           |
|simulate_user_account|Nein    |Domainaccount, für den Aktivitäten simuliert werden sollen.<br>Für diesen Account wird automatisiertes Anmelden am entsprechenden Host konfiguriert. Siehe *browse_fileshares*, *is_generating_smb_traffic* und *is_generating_http_traffic* für Beispiele von Aktivitäten, die simuliert werden können. Der Accountname muss als [user_account](./user_account.md) oder [service_account](./service_account.md) hinterlegt sein.|String               |`"alice"`                  |
|browse_fileshares   |Nein    |Fileshares, die von einem Domainaccount besucht werden sollen.<br>Kann genutzt werden, um URL-File-Attacks nachzustellen. Setzt einen Eintrag unter *simulate_user_account* voraus. Der Fileshare muss unter fileshares am Domain Controller existieren.|String[]             |`"\\\\DC-01\\Share1"`      |
|is_generating_smb_traffic|Nein    |Ist die Option aktiviert, wird der Fileshare `\\DC-1` gemapped.<br>Kann genutzt werden, um LLMNR-Poisoning und NTLM-Relaying nachzustellen, wenn der Fileshare nicht im Netzwerk existiert. Setzt einen Eintrag unter *simulate_user_account* voraus.|Boolean              |`true`/`false`               |
|is_generating_http_traffic|Nein    |Ist die Option aktiviert, wird ein nicht existierender Hostname mittels IPv6 aufgelöst.<br>Kann genutzt werden, um Man-In-The-Middle Angriffe nachzustellen, wenn IPv6 im Netzwerk aktiviert, aber nicht konfiguriert ist. Setzt einen Eintrag unter *simulate_user_account* voraus. Das Feature befindet sich in Entwicklung und kann derzeit noch nicht verlässlich genutzt werden.|Boolean              |`true`/`false`               |

## Modulbeschreibung im JSON-Format

Im JSON-Format wird der Inhalt wie folgt dargestellt.\

```json
{
    "host_name": "WKST-01",
    "default_user": {
        ...
    },
    "network_interface": "Ethernet",
    "ip_address": "10.0.0.100",
    "subnet_mask": "255.255.255.0",
    "default_gateway": "10.0.0.1",
    "primary_dns": "10.0.0.10",
    "secondary_dns": "8.8.8.8",
    "has_rdp_enabled": true,
    "logged_in_users": [
        "alice", "bob", "charlie"
    ],
    "local_administrators": [
        "alice", "bob"
    ],
    "simulate_user_account": "alice",
    "browse_fileshares": [
        "\\\\DC-01\\Share1"
    ],
    "is_generating_smb_traffic": true,
    "is_generating_http_traffic": true  
}
```

Beispiele für mit `...` markierte Inhalte sind in der Dokumentation des jeweiligen Moduls zu finden.
