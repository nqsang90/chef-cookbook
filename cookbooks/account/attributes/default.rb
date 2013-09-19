include_attribute "tomcat::default"


default['account']['version'] = "0.3.6"
default['account']['checksum'] = "f04937ec3b6b94fd1517d397212fddc572453de146d20c801147c20760e1628e"

default['account']['port'] = node['tomcat']['port']
default['account']['url'] = "#{node['deployment_server']['url']}/account-#{node['account']['version']}.zip"


default['account']['deploy_dir'] = "/opt/mca-system"
default['account']['db_host'] = "localhost"
default['account']['db_port'] = 3306
default['account']['db_schema'] = "authentication"
default['account']['db_username'] = "root"
default['account']['db_password'] = node['mysql']['server_root_password']

