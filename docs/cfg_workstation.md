# workstation module

Take me back to the [base document](./cfg_root.md).

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
    "simulate_user_account": {
        ...
    }
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|host_name           |Yes      |The hostname to be assigned.                |String               |`"WKST-01"`                |
|default_user        |Yes      |The credentials to be assigned to the local account.|default_user         |See [default_user](./cfg_default_user.md)       |
|network_interface   |No    |The network interface to be used during the setup.<br>Default: `"Ethernet"`|String               |`"Ethernet"`               |
|ip_address          |Yes      |The IP address to be assigned.              |String               |`"10.0.0.100"`             |
|subnet_mask         |Yes      |The subnet mask of the network.           |String               |`"255.255.255.0"`          |
|default_gateway     |Yes      |The default gateway of the network.        |String               |`"10.0.0.1"`               |
|primary_dns         |Yes      |The primary DNS server.<br>Recommended: IP address of the DC|String               |`"10.0.0.10"`              |
|secondary_dns       |Yes      |The secondary DNS server.<br>Recommended: `"8.8.8.8"`|String               |`"8.8.8.8"`                |
|has_rdp_enabled     |No    |Option to enable RDP.<br>Additionally, the RestrictedAdmin mode is disabled to enable Pass-The-Hash attacks.|Boolean              |`true`/`false`               |
|logged_in_users     |No    |Domain accounts that have logged in to this box once.<br>Can be used to leave password hashes in the box's cache. At least one account must be specified under *logged_in_users* or *local_administrators*. If an account without administrator privileges is used for the setup, the corresponding permissions will be granted to it during the setup and then revoked afterward. The account names must be specified as [user_account](./cfg_user_account.md) or [service_account](./cfg_service_account.md). |String[]             |`"alice", "bob", "charlie"`|
|local_administrators|No    |Domain accounts for which local administrator permissions should be configured.<br>Accounts specified here leave password hashes in the box's cache. At least one account must be specified under *logged_in_users* or *local_administrators* . The account names must be specified as [user_account](./cfg_user_account.md) or [service_account](./cfg_service_account.md). |String[]             |`"alice", "bob"`           |
|simulate_user_account|No    |Domain account to simulate user behavior.|simulate_user_account               |See [simulate_user_account](./cfg_simulate_user_account.md)               |
