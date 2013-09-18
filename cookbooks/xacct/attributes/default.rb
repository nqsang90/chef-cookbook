
default['xacct']['home'] = "/opt/xacct"

default['xacct']['num_instance'] = 2

default['xacct'][0]['version'] = "0.3.5-beta2"
default['xacct'][1]['version'] = "0.3.4-beta2"
default['xacct']['port'] = [8585, 9595]
default['xacct'][0]['checksum'] = "0c604fd08f42968750f9ccc8ccfebbc87c66b3fe107d253e362f31c7c3753cab"
default['xacct'][1]['checksum'] = "0c604fd08f42968750f9ccc8ccfebbc87c66b3fe107d253e362f31c7c3753cab"

default['xacct'][0]['status'] = 'enable'
default['xacct'][1]['status'] = 'enable'

default['xacct']['default'] = 0

for i in 0..node['xacct']['num_instance']-1
	default['xacct'][i]['home'] = "/opt/xacct-#{i}"
	default['xacct'][i]['port'] = node['xacct']['port'][i]
	default['xacct'][i]['url'] = "#{node['deployment_server']['url']}/xacct-#{node['xacct'][i]['version']}.zip"
end

default['xacct']['deploy_dir'] = "/opt/mca-system"
default['xacct']['db_schema'] = "xaccount"
default['xacct']['db_username'] = "root"
default['xacct']['db_host'] = "localhost"
default['xacct']['db_port'] = 3306
default['xacct']['db_password'] = node['mysql']['server_root_password']

