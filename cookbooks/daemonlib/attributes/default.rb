

default['daemonlib']['version'] = "0.2.1"
default['daemonlib']['deploy_dir'] = "/opt/mca-system"
default['daemonlib']['url'] = "#{node['deployment_server']['url']}/daemonlib-#{node['daemonlib']['version']}.zip"
