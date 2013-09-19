

default['installment']['version'] = "0.5.18-alpha2"
default['installment']['port'] = 8383
default['installment']['checksum'] = "4c9116b272d8f4c1a44c34ed0f979c834e5e6db89925e5a8702a0c56ae732001"


default['installment']['home'] = "/opt/installment"
default['installment']['url'] = "#{node['deployment_server']['url']}/installment-#{node['installment']['version']}.zip"

default['installment']['deploy_dir'] = "/opt/mca-system"
default['installment']['db_schema'] = "installment"
default['installment']['db_username'] = "root"
default['installment']['db_host'] = "localhost"
default['installment']['db_port'] = 3306
default['installment']['db_password'] = node['mysql']['server_root_password']

