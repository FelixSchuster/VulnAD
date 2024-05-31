# mssqlserver module

Take me back to the [base document](./cfg_root.md).

```json
{
    "service_account": "sqluser",
    "service_administrator_accounts": [
        "alice", "sqluser"
    ]
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|service_account     |Yes      |The account with which the service should be started.<br>The account name must be specified as [service_account](./cfg_service_account.md).|String               |`"sqluser"`                |
|service_administrator_accounts|Yes      |Accounts that should receive admin permissions for the service.<br>The account names must be specified as [user_account](./cfg_user_account.md) or [service_account](./cfg_service_account.md).|String[]             |`"alice", "sqluser"`       |
