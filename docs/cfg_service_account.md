# service_account module

Take me back to the [base document](./cfg_root.md).

```json
{
    "sam_account_name": "sqluser",
    "name": "sqluser",
    "password": "sqluser-P@ssword",
    "path": "OU=services,DC=vulncorp,DC=lab",
    "is_domain_administrator": true,
    "has_pre_auth_disabled": true,
    "service_principal_name": "MSSQLSvc/DC-01.vulncorp.lab:1433"
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|sam_account_name    |Yes      |The SamAccountName to be assigned to the account.|String               |`"sqluser"`                |
|name                |Yes      |The name to be assigned to the account.   |String               |`"sqluser"`                |
|password            |Yes      |The password to be assigned to the account.|String               |`"sqluser-P@ssword"`       |
|path                |Yes      |The organizational unit to which the account should belong. The OU must be specified as [organizational_unit](./cfg_organizational_unit.md).|String               |`"OU=services,DC=vulncorp,DC=lab"`|
|is_domain_administrator|No    |Option for assigning Domain Admin permissions.|Boolean              |`true`/`false`               |
|has_pre_auth_disabled|No    |Option for disabling Kerberos pre-authentication.<br>Can be used to simulate AS-REP Roasting attacks.|Boolean              |`true`/`false`               |
|service_principal_name|Yes      |The ServicePrincipalName to be assigned to the account.|String               |`"MSSQLSvc/DC-01.vulncorp.lab:1433"`|
