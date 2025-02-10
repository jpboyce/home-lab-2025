# Terraform Documentation

## Prerequisites

### Account Setup on ProxMox

1. SSH to the ProxMox server
2. Create a new account for Packer.  An example command would be `pveum user add terraform@pve -comment "Terraform User"`
3. Create a new API token for the user: `pveum user token add terraform@pve templates -privsep 1`  Note the token value
4. Give the token the permissions for VM administration: `pveum acl modify /vms -token 'terraform@pve!templates' -role PVEVMAdmin`


## Template Creation

### Ubuntu 24.04
1. Run the command: `packer build -var-file variables.pkrvars.hcl pve-ubuntu.pkr.hcl`
190faec4-8315-4195-9943-51e7663a9bc7 


terraform@pve!templates=190faec4-8315-4195-9943-51e7663a9bc7 
