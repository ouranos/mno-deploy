# Maestrano Infrastructure

[ ![Codeship Status for maestrano/mno-deploy](https://codeship.com/projects/f6587590-e990-0133-f67a-4afac8d396b8/status?branch=master)](https://codeship.com/projects/147638)

The complete Maestrano infrastructure can be deployed on demand on AWS using these scripts
The `ansible` directory contains the Ansible playbooks to create a new environment and setup the components

Tested with Ansible 2.0.2.0

## Infrastructure configuration and setup
The default cloud provider used to deploy the Maestrano platform is Amazon Web Services running inside a VPC.
The different components of the platform are deployed independantly (frontend, mnohub, nex!, connec!, impac!)
[ ![Architecture diagram](https://raw.githubusercontent.com/maestrano/mno-deploy/develop/architecture_diagram.png)]

### Setup a new environment
Create a directory structure as follows. Copy the scripts files `setup_infrastructure.sh`, `setup_instance.sh` and `vault_pass.sh` under the directory `myproject/scripts`.
```
+-- _myproject
|   +-- _ansible
|       +-- _files
|           +-- _public_keys
|           +-- _xero_certs
|       +-- _vars
|           +-- myenv.yml
|           +-- myenv_secret.yml
|   +-- scripts
|       +-- setup_infrastructure.sh
|       +-- setup_instance.sh
|       +-- vault_pass.sh
```

### Ansible variables and secrets
The infrastructure needs to be configured
- Create a yaml configuration file under `ansible/vars` (eg: `ansible/vars/myenv.yml`) and customise values from `ansible/group_vars/all` as needed
- Create a yaml secret file file under `ansible/vars` (eg: `ansible/vars/myenv_secret.yml`) containing passwords and secrets
- Encrypt the secret file with ansible vault: `ansible-vault encrypt ansible/vars/myenv_secret.yml`
- Store the ansible vault password in a text file that will be reused as part of the deployment scripts

### Infrastructure setup
- Run the following script

```
export AWS_ACCESS_KEY_ID=<some-key>
export AWS_SECRET_ACCESS_KEY=<some-key>
export AWS_REGION=ap-southeast-2
export ANSIBLE_VAULT_PASSWORD_FILE=path/to/ansible/vault/key
export ENVIRONMENT_CONFIGURATION=myenv
export MNO_DEPLOY_VERSION=develop/latest
sh scripts/setup_infrastructure.sh
```

### Common components configuration
#### User ssh keys
To be stored under `ansible/files/public_keys`

### Mnohub configuration
#### Xero certificates
To be stored under `ansible/files/xero_certs`
