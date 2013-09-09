

default['commons_daemon']['version'] = "1.0.1"
default['commons_daemon']['deploy_dir'] = "/opt/mca-system"
default['commons_daemon']['url'] = "#{node['deployment_server']['url']}/commons-daemon-#{node['commons_daemon']['version']}.zip"
