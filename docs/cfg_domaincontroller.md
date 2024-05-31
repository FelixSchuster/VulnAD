# domaincontroller module

Take me back to the [base document](./cfg_root.md).

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

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|host_name           |Yes      |The hostname to be assigned.                |String               |`"DC-01"`                  |
|default_user        |Yes      |The credentials to be assigned to the local account.|default_user         |See [default_user](./cfg_default_user.md)       |
|network_interface   |No    |The network interface to be used during the setup.<br>Default: `"Ethernet"`|String               |`"Ethernet"`               |
|ip_address          |Yes      |The IP address to be assigned.              |String               |`"10.0.0.10"`              |
|subnet_mask         |Yes      |The subnet mask of the network.           |String               |`"255.255.255.0"`          |
|default_gateway     |Yes      |The default gateway of the network.        |String               |`"10.0.0.1"`               |
|primary_dns         |Yes      |The primary DNS server.<br>Recommended: `"127.0.0.1"`|String               |`"127.0.0.1"`              |
|secondary_dns       |Yes      |The secondary DNS server.<br>Recommended: `"8.8.8.8"`|String               |`"8.8.8.8"`                |
|dsrm_password       |Yes      |The DSRM (Directory Services Restore Mode) password to be set for the domain.|String               |`"DSRM-P@ssword"`          |
|has_rdp_enabled     |No    |Option to enable RDP.<br>Additionally, the RestrictedAdmin mode is disabled to enable Pass-The-Hash attacks.|Boolean              |`true`/`false`               |
|has_iis_installed   |No    |Option for automated installation of the IIS web server.<br>The files in the `.\Website\*` folder will be hosted on port 80.|Boolean              |`true`/`false`               |
|fileshares          |No    |Option for automated hosting of file shares.<br>The files in the `.\Fileshares\<Sharename>\*` folder will be shared. Via Group Policy, all workstations in the domain will connect to the specified file shares. Currently, it is not possible to create ACLs; all accounts have access to the hosted file shares.|fileshare[]          |See [fileshare](./cfg_fileshare.md)          |
|mssqlserver         |No    |Option for automated hosting of an MSSQL server.<br>If specified: An MSSQL server instance will be hosted on port 1433. |mssqlserver          |See [mssqlserver](./cfg_mssqlserver.md)        |
