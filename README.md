# VulnAD

VulnAD erstellt eine realitätsnahe Active Directory Domäne und befüllt diese mit verschiedensten Objekten, darunter Organizational Units, Domain Accounts und Service Accounts.
Anders als die meisten Active Directory Random-User-Generatoren konfiguriert VulnAD die Domäne basierend auf einer Konfigurationsdatei und ermöglicht so die Implementation vordefinierter Angriffsvektoren.
Zusätzlich installiert das Tool die Active Directory Domain Services am Domain Controller und verbindet Workstations mit der Domäne, ein manuelles Konfigurieren von Active Directory ist somit nicht notwendig.
VulnAD ist außerdem in der Lage, mit Hilfe von Scheduled Tasks Personenverhalten zu simulieren.
So kann beispielsweise der Zugriff auf Fileshares simuliert oder LLMNR Traffic generiert werden, was die Nachstellung diverser Angriffe ermöglicht.

**Diese Dokumentation befindet sich derzeit im Aufbau.**

*TODO: GIF einfügen*

## Setup
```text
git clone https://github.com/FelixSchuster/VulnAD
cd VulnAD
powershell -ExecutionPolicy bypass .\VulnAD .\<ConfigurationFile>.json <Hostname>
```

## Dokumentation

*TODO: Erstellen der VMs dokumentieren*

VulnAD konfiguriert die Domäne anhand einer JSON-Konfigurationsdatei, der Aufbau ist [hier](./docs/configuration_root.md) dokumentiert.\
Beispiele für valide Konfigurationsdateien sind im `examples`-Ordner zu finden.

*TODO: action_bevore_restart dokumentieren*

## TODO
- Dokumentation fertigstellen
- Übersetzung der Dokumentation ins Englische
- Umbenennen der lokalen Accountnamen zu Beginn des Setups
- Examples und Writeups bereitstellen
- Dynamische Implementierung von `is_generating_http_traffic`
- Refactoring!