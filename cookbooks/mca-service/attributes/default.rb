
default['mca_service']['version'] = "0.1.2"
default['mca_service']['checksum'] = "79b4fabc1ffdca175346908295d147406b1b30bf08743d244cd016eac0841c9f"
default['mca_service']['port'] = 8787
default['mca_service']['deploy_dir'] = "/opt/mca-system"

default['mca_service']['port'] = node['mca_service']['port']
default['mca_service']['url'] = "#{node['deployment_server']['url']}/mca-service-#{node['mca_service']['version']}.zip"
default['mca_service']['home'] = "/opt/mca-service"
