# Apache_HAProxy_Infra_Automation
This GitRepo contains the complete setup details of creating infrastructure and configuring Apache and HAProxy

## Softwares Used  
Following softwares are used in this setup : 
1. Terraform - For creating Infrastructure
2. Ansible - For configuring Apache and HAProxy in the servers created above
3. Testinfra - For running the testcases

## Steps to build a Load Balanced Web Server Environment
## Step 1 - Create Infra
- 1. Run - `terraform init`
- 2. Run - `terraform apply` ( Confirm the changes and approve the plan. )

Note - Configure the values for `shared_credentials_file` and `profile` in the `provider` section before running the above 2 commands. One can also configure AWS creds in various other ways too. 

3 ec2-instances will be launched by the Terraform like below :

![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/AWS-Ec2-Instances.png)  

## Step 2 - Configure Apache and HAProxy

- Run - `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=<flag>'`


To enable **sticky_session** , set the flag to **true**

**E.g** `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=true'`

To disable **sticky_session** , set the flag to **false**. Then **round robin** routing policy will be enabled by default. 

**E.g** `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=true'`

## Verify Results

Note down the **Load Balancer IP** from the ansible command output.

Copy the `load_balancer_ip`in any browser or run `curl <load_balancer_ip>` continously. We will get the below results :

**sticky_session set to false**

 Alternatively, Server-1 and Server-2 is being hit by the Load Balancer : 

`Hello World from Server 1 - <apache_server_1_ip>`

or

`Hello World from Server 2 - <apache_server_2_ip>`

![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/Server-1.png)  
![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/Server-2.png)  

**sticky_session set to true**

Any one Server between the two, will be hit by the Load Balancer repeatedly : 

`Hello World from Server 1 - <apache_server_1_ip>`
![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/Server-1.png)  
