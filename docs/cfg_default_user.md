# default_user module

Take me back to the [base document](./cfg_root.md).

```json
{
    "user_name": "Admin",
    "password": "Admin-P@ssword"
}
```

|Parameter           |Required|Description                               |Data type             |Example                  |
|--------------------|--------|-------------------------------------------|---------------------|-------------------------|
|user_name           |Yes      |The account name for the local account.<br>This field is currently ignored; instead, the account name of the account used to initiate the setup will be taken over.|String               |`"Admin"`                  |
|password            |Yes      |The password for the local account.<br>The password does not need to match the current password of the account and will be changed to the password specified here during the setup.|String               |`"Admin-P@ssword"`         |
