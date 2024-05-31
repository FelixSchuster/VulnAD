# VulnAD

VulnAD creates a realistic Active Directory domain and populates it with various objects, including Organizational Units, Domain Accounts, and Service Accounts. Unlike most Active Directory random user generators, VulnAD configures the domain based on a configuration file, allowing the implementation of predefined attack vectors. Additionally, the tool installs Active Directory Domain Services on the Domain Controller and connects workstations to the domain, eliminating the need for manual Active Directory configuration. VulnAD is also capable of simulating user behavior using Scheduled Tasks. For instance, it can simulate access to file shares or generate LLMNR traffic, enabling the recreation of various attacks.

![Demo](./docs/pics/demo.gif)

## Setup
VulnAD requires a NAT network for the Active Directory environment. Instructions on how to configure a NAT network in VirtualBox can be found [here](./docs/vbox_nat.md). Additionally, the Windows hosts that will be integrated into the environment need to be set up.

```text
git clone https://github.com/FelixSchuster/VulnAD
cd VulnAD
powershell -ExecutionPolicy Bypass
.\VulnAD <ConfigurationFile> <HostName>
```

## Documentation

VulnAD configures the domain based on a JSON configuration file, the structure of which is documented [here](./docs/cfg_root.md).\
Examples of valid configuration files can be found in the examples folder.

## TODO
- Add an option to create local accounts
- Provide examples and writeups
- Refactoring!
