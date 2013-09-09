default['embedded_webapp']['version'] = '0.1.1'
default['embedded_webapp']['deploy_dir'] = "/opt/mca-system"
default['embedded_webapp']['url'] = "#{node['deployment_server']['url']}/embedded-webapp-#{node['embedded_webapp']['version']}.zip"
