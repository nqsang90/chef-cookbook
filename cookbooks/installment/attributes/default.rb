

default['installment']['port'] = 8383
default['installment']['version'] = "0.5.18-alpha2"
default['installment']['url'] = "#{node['deployment_server']['url']}/installment-#{node['installment']['version']}.zip"
default['installment']['deploy_dir'] = "/opt/mca-system"
default['installment']['home'] = "/opt/installment"
