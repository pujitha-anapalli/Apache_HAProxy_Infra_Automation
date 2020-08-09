output "web_server_1_ip" {
  description = "Public IP of the Ec2 Instance 1"
  value       = "${aws_instance.web_server_1.public_ip}"
}

output "web_server_2_ip" {
  description = "Public IP of the Ec2 Instance 2"
  value       = "${aws_instance.web_server_2.public_ip}"
}
resource "local_file" "web_server_ips" {

  filename = "./web_server_ips.txt"
  content     = <<EOF
${aws_instance.web_server_1.public_ip}
${aws_instance.web_server_2.public_ip}
EOF
  }

resource "local_file" "Ansible_Inventory" {

  filename = "./inventory/ec2_instances.ini"
  content     = <<EOF
    [ec2_instances]
    ${aws_instance.web_server_1.public_ip} ansible_host=${aws_instance.web_server_1.public_ip} ansible_port=22 ansible_user=ec2-user ansible_ssh_private_key_file=./devops-test.pem
    ${aws_instance.web_server_2.public_ip} ansible_host=${aws_instance.web_server_2.public_ip} ansible_port=22 ansible_user=ec2-user ansible_ssh_private_key_file=./devops-test.pem

    [load_balancer]
    ${aws_instance.ha_proxy_lb.public_ip} ansible_host=${aws_instance.ha_proxy_lb.public_ip} ansible_port=22 ansible_user=ec2-user ansible_ssh_private_key_file=./devops-test.pem

EOF
  }
