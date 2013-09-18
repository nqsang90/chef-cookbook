
default['installment']['num_instance'] = 1

default['installment'][0]['version'] = "0.5.18-alpha2"
default['installment'][1]['version'] = "0.5.17-alpha2"
default['installment']['port'] = [8383, 9393]
default['installment'][0]['checksum'] = "4c9116b272d8f4c1a44c34ed0f979c834e5e6db89925e5a8702a0c56ae732001"
default['installment'][1]['checksum'] = "4c9116b272d8f4c1a44c34ed0f979c834e5e6db89925e5a8702a0c56ae732001"

default['installment'][0]['status'] = 'enable'
default['installment'][1]['status'] = 'enable'

default['installment']['default'] = 0

for i in 0..node['installment']['num_instance']-1
	default['installment'][i]['home'] = "/opt/installment-#{i}"
	default['installment'][i]['port'] = node['installment']['port'][i]
	default['installment'][i]['url'] = "#{node['deployment_server']['url']}/installment-#{node['installment'][i]['version']}.zip"
end

default['installment']['deploy_dir'] = "/opt/mca-system"
default['installment']['db_schema'] = "installment"
default['installment']['db_username'] = "root"
default['installment']['db_host'] = "localhost"
default['installment']['db_port'] = 3306
default['installment']['db_password'] = node['mysql']['server_root_password']

