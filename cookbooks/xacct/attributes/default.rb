default['xacct']['version'] = "0.3.5-beta2"

default['xacct']['port'] = 8585
default['xacct']['checksum'] = "0c604fd08f42968750f9ccc8ccfebbc87c66b3fe107d253e362f31c7c3753cab"

default['xacct']['home'] = "/opt/xacct"
default['xacct']['url'] = "#{node['deployment_server']['url']}/xacct-#{node['xacct']['version']}.zip"

default['xacct']['deploy_dir'] = "/opt/mca-system"
default['xacct']['db_schema'] = "xaccount"
default['xacct']['db_username'] = "root"
default['xacct']['db_host'] = "localhost"
default['xacct']['db_port'] = 3306
default['xacct']['db_password'] = node['mysql']['server_root_password']

