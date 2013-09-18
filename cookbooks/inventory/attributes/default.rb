

default['inventory']['num_instance'] = 2

default['inventory'][0]['version'] = "0.3.10-beta1"
default['inventory'][1]['version'] = "0.3.9-beta1"
default['inventory']['port'] = [8181, 9191]
default['inventory'][0]['checksum'] = "84d48d31a8328dd3d8b666a430a76a5443b7d32724c37d7426007778c8f716a4"
default['inventory'][1]['checksum'] = "84d48d31a8328dd3d8b666a430a76a5443b7d32724c37d7426007778c8f716a4"

default['inventory'][0]['status'] = 'enable'
default['inventory'][1]['status'] = 'enable'

default['inventory']['default'] = 0

for i in 0..node['inventory']['num_instance']-1
	default['inventory'][i]['home'] = "/opt/inventory-#{i}"
	default['inventory'][i]['port'] = node['inventory']['port'][i]
	default['inventory'][i]['url'] = "#{node['deployment_server']['url']}/inventory-#{node['inventory'][i]['version']}.zip"
end

default['inventory']['deploy_dir'] = "/opt/mca-system"
default['inventory']['db_schema'] = "inventory"
default['inventory']['db_username'] = "root"
default['inventory']['db_host'] = "localhost"
default['inventory']['db_port'] = 3306
default['inventory']['db_password'] = node['mysql']['server_root_password']

