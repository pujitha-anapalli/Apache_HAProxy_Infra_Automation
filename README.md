# Apache_HAProxy_Infra_Automation
This GitRepo contains the complete setup details of creating infrastructure and configuring Apache and HAProxy

## Softwares Used  
Following softwares are used in this setup : 
1. Terraform - For creating Infrastructure in AWS
2. Ansible - For configuring Apache and HAProxy in the servers created above
3. Testinfra - For running the testcases

## Steps to build a Load Balanced Web Server Environment
## Step 1 - Create Infra
- 1. Run - `terraform init`
- 2. Run - `terraform apply` ( Confirm the changes and approve the plan. )

Note - Configure the values for `shared_credentials_file` and `profile` in the `provider` section before running the above 2 commands. One can also configure AWS creds in various other ways too. 
Below resources will be created:
- 2 EC2 Instances that will be configured as Webservers
- 1 EC2 Instance that will be configured as Load Balancer
- 1 Security Group for Webservers
- 1 Security Group for Load Balancer
- 1 Local file (inventory/ec2_instances.ini)  which will be used for Ansible Inventory
- 1 Local file (web_server_ips.txt) with the details of Webservers IPs to be used in the testcases

Three AWS ec2-instances will be launched by the Terraform like below :

![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/AWS-Ec2-Instances.png)  

## Step 2 - Configure Apache and HAProxy

- Run - `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=<flag>'`


To enable **sticky_session** , set the flag to **true**

**E.g** `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=true'`

To disable **sticky_session** , set the flag to **false**. Then **round robin** routing policy will be enabled by default. 

**E.g** `ansible-playbook -i ./inventory/ec2_instances.ini apache-haproxy-playbook.yaml  --extra-vars 'sticky_session=false'`

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

## Step 3 - Test the configurations

- **Testing the Web Servers**

`py.test -v --hosts=ec2_instances --ansible-inventory=inventory/ec2_instances.ini --connection=ansible tests/test_web_server.py --force-ansible`

This command will run the tests for the Apache Servers. The details for the servers are fetched from the Ansible Inventory  Below are the testcases :
1. Check for sudo access
2. Check if Apache is installed
3. Check if Apache is up and running
4. Check if curl is enabled

![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/Web_Server_Test.png)  

- **Testing the Load Balancer**

`py.test -v --hosts=load_balancer --ansible-inventory=inventory/ec2_instances.ini --connection=ansible tests/test_load_balancer.py --force-ansible`

This command will run the tests for the HAProxy Server. The details for this is also fetched from the Ansible Inventory  Below are the testcases :

1. Check for sudo access
2. Check if HAProxy is installed
3. Check if HAProxy is up and running
4. Check if curl is enabled
5. Check if we can curl Load balancer when Apache on Server 1 is stopped.
6. Check if we can curl Load balancer when Apache on Server 2 is stopped.

![snapshot 1](https://github.com/pujitha-anapalli/Apache_HAProxy_Infra_Automation/blob/master/Screenshots/Load_Balancer_Test.png)  

## Step 4 - Delete Infra
-  Run - `terraform destroy`
Once the project is verified, we can delete the entire resources created. 


# BONUS
## Brief summary of what you liked about your solution
- Ansible Inventory file created automatically by the Terraform with all the required details. 
- IPs of the Servers launched are dynamically added at all the relevant places throughout the solution ( Ansible Inventory and Testinfra testcases ). 

## Brief summary of what you disliked about your solution
- During the first invoke of the ansible playbook command, need to add each host to the trusted hosts list manually. This could have been automated. 

## Configurable Round Robin / Sticky Load Balancer
- This is handled while invloking ansible-playbook command. 

## Return instance identifier of your webserver in addition to “Hello World”
- Everytime we curl the Load Balancer, the Instance IP is also displayed along with "Hello World".
