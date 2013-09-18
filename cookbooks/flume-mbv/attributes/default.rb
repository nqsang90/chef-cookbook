default['apache_flume']['version'] = '1.4.0'
default['apache_flume']['deploy_dir'] = "/opt"
default['apache_flume']['home'] = "/opt/apache-flume-#{node['apache_flume']['version']}"
default['apache_flume']['url'] = "#{node['deployment_server']['url']}/apache-flume-#{node['apache_flume']['version']}.zip"

