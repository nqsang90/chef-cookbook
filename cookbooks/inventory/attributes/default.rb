

default['inventory']['version'] = "0.3.10-beta1"
default['inventory']['port'] = 8181
default['inventory']['checksum'] = "84d48d31a8328dd3d8b666a430a76a5443b7d32724c37d7426007778c8f716a4"

default['inventory']['home'] = "/opt/inventory"
default['inventory']['url'] = "#{node['deployment_server']['url']}/inventory-#{node['inventory']['version']}.zip"

default['inventory']['deploy_dir'] = "/opt/mca-system"
default['inventory']['db_schema'] = "inventory"
default['inventory']['db_username'] = "root"
default['inventory']['db_host'] = "localhost"
default['inventory']['db_port'] = 3306
default['inventory']['db_password'] = node['mysql']['server_root_password']

