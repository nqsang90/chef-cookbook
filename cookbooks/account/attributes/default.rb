include_attribute "mbv-tomcat::default"

default['account']['num_instance'] = 1

default['account'][0]['version'] = "0.3.6"
default['account'][1]['version'] = "0.3.5"
default['account'][0]['checksum'] = "f04937ec3b6b94fd1517d397212fddc572453de146d20c801147c20760e1628e"
default['account'][1]['checksum'] = "f04937ec3b6b94fd1517d397212fddc572453de146d20c801147c20760e1628e"

default['account'][0]['status'] = 'enable'
default['account'][1]['status'] = 'enable'

default['account']['default'] = 0

for i in 0..node['mbv_tomcat']['num_instance']-1
	default['account'][i]['port'] = node['mbv_tomcat']['connector_ports'][i]
	default['account'][i]['url'] = "#{node['deployment_server']['url']}/account-#{node['account'][i]['version']}.zip"
end

default['account']['deploy_dir'] = "/opt/mca-system"
default['account']['db_host'] = "localhost"
default['account']['db_port'] = 3306
default['account']['db_schema'] = "authentication"
default['account']['db_username'] = "root"
default['account']['db_password'] = node['mysql']['server_root_password']

