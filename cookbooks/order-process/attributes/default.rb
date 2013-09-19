
default['order_process']['version'] = "0.2.19"
default['order_process']['checksum'] = "5d9ef0f9b3ffd525fc995c74ab497f7de0d881b78d3e6ef46099dd65ae2e6107"
default['order_process']['port'] = 8282
default['order_process']['deploy_dir'] = "/opt/mca-system"

default['order_process']['port'] = node['order_process']['port']
default['order_process']['url'] = "#{node['deployment_server']['url']}/order-process-#{node['order_process']['version']}.zip"
default['order_process']['home'] = "/opt/order-process"
