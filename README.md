# Apache_HAProxy_Infra_Automation
This GitRepo contains the complete setup details of creating infrastructure and configuring Apache and HAProxy

## Softwares Used  
Following softwares are used in this setup : 
1. Terraform - For creating Infrastructure
2. Ansible - For configuring Apache and HAProxy in the servers created above
3. Testinfra - For running the testcases

## Steps to build a Load Balanced Web Server Environment
### Step 1 - Create Infra
1. Run - `terraform init`
2. Run - `terraform apply` ( Confirm the changes and approve the plan. )
Note - Configure the values for `shared_credentials_file` and `profile` in the `provider` section before running the above 2 commands. One can also configure AWS creds in various other ways too. 

### Step 2 - Configure Apache and HAProxy
1. Run - `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=<flag>'`
To enable **sticky_session** , set the flag to **true**
**E.g** `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=true'`

To disable **sticky_session** , set the flag to **true** . Then **round robin** will be enabled by default. 
**E.g** `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=true'`
