import testinfra
import pytest

def hostname(host):
    return host.ansible.get_variables()['inventory_hostname']

# test for having root prevelleges
def test_sudo(host):
    with host.sudo():
        assert host.check_output('whoami') == 'root'

# test to check if apache is installed on Web Servers
def test_apache_is_installed(host):
        apache = host.package("httpd")
        assert apache.is_installed

# test to check if apache is running on Web Servers
def test_apache_is_running(host):
    with host.sudo():
        assert host.service("httpd").is_running

# test to check if curl is working on Web Servers
def test_curl(host):
    cmd = host.run("curl -vs http://localhost")
    assert "HTTP/1.1 200" in cmd.stderr
