# user_account module

Take me back to the [base document](./cfg_root.md).

```json
{
    "sam_account_name": "asmith",
    "given_name": "Alice",
    "surname": "Smith",
    "password": "Alice-P@ssword",
    "path": "OU=people,DC=vulncorp,DC=lab",
    "is_domain_administrator": true,
    "has_pre_auth_disabled": true
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|sam_account_name    |Yes      |The SamAccountName to be assigned to the account.|String               |`"asmith"`                 |
|given_name          |Yes      |The first name to be assigned to the account.|String               |`"Alice"`                  |
|surname             |Yes      |The surname to be assigned to the account.|String               |`"Smith"`                  |
|password            |Yes      |The password to be assigned to the account.|String               |`"Alice-P@ssword"`         |
|path                |Yes      |The organizational unit to which the account should belong. The OU must be specified as [organizational_unit](./cfg_organizational_unit.md).|String               |`"OU=people,DC=vulncorp,DC=lab"`|
|is_domain_administrator|No    |Option for assigning Domain Admin permissions.|Boolean              |`true`/`false`               |
|has_pre_auth_disabled|No    |Option for disabling Kerberos pre-authentication.<br>Can be used to simulate AS-REP Roasting attacks.|Boolean              |`true`/`false`               |
