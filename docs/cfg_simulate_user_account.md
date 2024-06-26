# service_account module

Take me back to the [base document](./cfg_root.md).

```json
{
    "user_name": "alice",
    "browse_fileshares": [
        "\\\\DC-01\\Share1",
        "\\\\DC-01\\Share2"
    ],
    "is_generating_smb_traffic": true,
    "is_generating_http_traffic": true
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|user_name    |Yes      |SamAccountName, für den Aktivitäten simuliert werden sollen.<br>Für diesen Account wird automatisiertes Anmelden am entsprechenden Host konfiguriert. Der Accountname muss als [user_account](./cfg_user_account.md) oder [service_account](./cfg_service_account.md) hinterlegt sein.|String               |`"alice"`                |
|browse_fileshares   |No    |Fileshares, die von einem Domainaccount besucht werden sollen.<br>Kann genutzt werden, um URL-File-Attacks nachzustellen. Setzt einen Eintrag unter *simulate_user_account* voraus. Der Fileshare muss unter fileshares am Domain Controller existieren.|String[]             |`"\\\\DC-01\\Share1", "\\\\DC-01\\Share2"`      |
|is_generating_smb_traffic|No    |Ist die Option aktiviert, wird der Fileshare `\\DC-1` gemapped.<br>Kann genutzt werden, um LLMNR-Poisoning und NTLM-Relaying nachzustellen, wenn der Fileshare nicht im Netzwerk existiert. Setzt einen Eintrag unter *simulate_user_account* voraus.|Boolean              |`true`/`false`               |
|is_generating_http_traffic|No    |Ist die Option aktiviert, wird ein nicht existierender Hostname mittels IPv6 aufgelöst.<br>Kann genutzt werden, um Man-In-The-Middle Angriffe nachzustellen, wenn IPv6 im Netzwerk aktiviert, aber nicht konfiguriert ist. Setzt einen Eintrag unter *simulate_user_account* voraus. Das Feature befindet sich in Entwicklung und kann derzeit noch nicht verlässlich genutzt werden.|Boolean              |`true`/`false`               |
