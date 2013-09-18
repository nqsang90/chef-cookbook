default['order_process']['num_instance'] = 2

default['order_process'][0]['version'] = "0.2.19"
default['order_process'][1]['version'] = "0.2.18"
default['order_process'][0]['checksum'] = "5d9ef0f9b3ffd525fc995c74ab497f7de0d881b78d3e6ef46099dd65ae2e6107"
default['order_process'][1]['checksum'] = "5d9ef0f9b3ffd525fc995c74ab497f7de0d881b78d3e6ef46099dd65ae2e6107"
default['order_process'][0]['status'] = 'enable'
default['order_process'][1]['status'] = 'enable'
default['order_process']['port'] = [8282,9292]
default['order_process']['deploy_dir'] = "/opt/mca-system"

default['order_process']['default'] = 0

for i in 0..node['order_process']['num_instance']-1
	default['order_process'][i]['port'] = node['order_process']['port'][i]
	default['order_process'][i]['url'] = "#{node['deployment_server']['url']}/order-process-#{node['order_process'][i]['version']}.zip"
	default['order_process'][i]['home'] = "/opt/order-process-#{i}"
end