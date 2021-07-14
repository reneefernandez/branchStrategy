# README #

This is a skeleton layout for the On Demand deployment playbook structure. The roles contain placeholder tasks to later be filled in for relevant deployment steps.

This current configuration is able to initialize / create a workspace on demand without configuring the Terraform Cloud backend.

Currently, the script used to initalize the backend makes some assumptions for it's configuration.

```
TF_BACKEND_TOKEN=$(awk '/token/ { print $3 }' ~/.terraformrc | sed 's/\"//g')
ORGANIZATION=$(awk '/organization/ {print $3}' $BACKEND_CONFIG | sed 's/\"//g')
PREFIX=$(awk '/workspace/ {print $5}' $BACKEND_CONFIG | cut -d - -f 1 | sed 's/\"//g')
```

This expects the backend token for Terraform Cloud to be configured at `~/.terraformrc` as well as the backend config file in each projet to follow the convention of

```
workspaces { prefix = "Prod-" }
organization = "client-Prod"
```

## Running the playbook

run the convenience script `deploy_ondemand_latest`

this will also allow paramaters to be passed such as limiting roles `-l 'appcapi-latest'` or passing extra vars `-e "env=test"`

or run the playbook: `ansible-playbook -i latest_hosts ondemand.yml`


## Usage

Ansible best practices can be read about here: http://docs.ansible.com/playbooks_best_practices.html
