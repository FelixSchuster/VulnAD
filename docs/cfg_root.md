# Documentation of the configuration file

This documentation describes how to structure configuration files for VulnAD.
Examples of valid configuration files can be found in the `examples` folder.

```json
{
    "domain_name": "vulncorp.lab",
    "domaincontroller": {
        ...
    },
    "workstations": [
        ...
    ],
    "organizational_units": [
        ...
    ],
    "user_accounts": [
        ...
    ],
    "service_accounts": [
        ...
    ]
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|domain_name         |Yes      |The domain name to be assigned.              |String               |`"vulncorp.lab"`           |
|domaincontroller    |Yes      |Configuration for the domain controller.    |domaincontroller     |See [domaincontroller](./cfg_domaincontroller.md)   |
|workstations        |Yes      |Configuration for the workstations.        |workstation[]        |See [workstation](./cfg_workstation.md)        |
|organizational_units|No    |Configuration for the Organizational Units.|organizational_unit[]|See [organizational_unit](./cfg_organizational_unit.md)|
|user_accounts       |Yes      |Configuration for the domain user accounts.       |user_account[]       |See [user_account](./cfg_user_account.md)       |
|service_accounts    |No    |Configuration for the service accounts.    |service_account[]    |See [service_account](./cfg_service_account.md)    |
