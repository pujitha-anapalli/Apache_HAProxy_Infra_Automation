import testinfra
import pytest
from pathlib import Path

# def hostname(host):
#     return host.ansible.get_variables()['inventory_hostname']

# test for having root prevelleges
def test_sudo(host):
    with host.sudo():
        assert host.check_output('whoami') == 'root'

# test to check if haproxy is installed on Web Servers
def test_haproxy_is_installed(host):
        haproxy = host.package("haproxy")
        assert haproxy.is_installed

# test to check if apache is running on Web Servers
def test_haproxy_is_running(host):
    with host.sudo():
        assert host.service("haproxy").is_running

# test to check if curl is working on HAProxy Servers
def test_curl(host):
    cmd = host.run("curl -vs http://localhost")
    assert "HTTP/1.1 200" in cmd.stderr

# method to sleep for assigned sec
def wait_awhile():
    import time
    time.sleep(10)

# get the list of Servers running with Apache dynamically
def get_apache_server_details():
    web_server_list = []
    path = Path(__file__).parent / "../web_server_ips.txt"
    with path.open() as f:
        for ip in f:
            ip = ip.strip()
            web_server_list.append(ip)
    f.close()
    return web_server_list

# Bring the server 1 down and test the Load Balancer
def test_load_balancer_high_availability_server_1_down(host):
    web_server_list = get_apache_server_details()
    host_detail = "ansible://" + web_server_list[0] + "?ansible_inventory=inventory/ec2_instances.ini&force_ansible=True"
    apache_host = testinfra.get_host(host_detail,sudo=True)
    try:
        stop_and_start_apache_server(host,apache_host,"stop")
        wait_awhile()
        test_curl(host)

    finally:
        stop_and_start_apache_server(host,apache_host,"start")
        wait_awhile()

# Bring the server 2 down and test the Load Balancer
def test_load_balancer_high_availability_server_2_down(host):
    web_server_list = get_apache_server_details()
    host_detail = "ansible://" + web_server_list[1] + "?ansible_inventory=inventory/ec2_instances.ini&force_ansible=True"
    apache_host = testinfra.get_host(host_detail,sudo=True)
    try:
        stop_and_start_apache_server(host,apache_host,"stop")
        wait_awhile()
        test_curl(host)

    finally:
        stop_and_start_apache_server(host,apache_host,"start")
        wait_awhile()

# method to start/stop the apache running on the Server
def stop_and_start_apache_server(host,apache_host,state):
    cmd = apache_host.run("sudo service httpd "+state )
    assert cmd.rc == 0
