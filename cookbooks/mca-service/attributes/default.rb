default['mca_service']['num_instance'] = 2

default['mca_service'][0]['version'] = "0.1.2"
default['mca_service'][1]['version'] = "0.1.1"
default['mca_service'][0]['checksum'] = "79b4fabc1ffdca175346908295d147406b1b30bf08743d244cd016eac0841c9f"
default['mca_service'][1]['checksum'] = "79b4fabc1ffdca175346908295d147406b1b30bf08743d244cd016eac0841c9f"
default['mca_service'][0]['status'] = 'enable'
default['mca_service'][1]['status'] = 'enable'
default['mca_service']['port'] = [8787,9797]
default['mca_service']['deploy_dir'] = "/opt/mca-system"

default['mca_service']['default'] = 0

for i in 0..node['mca_service']['num_instance']-1
	default['mca_service'][i]['port'] = node['mca_service']['port'][i]
	default['mca_service'][i]['url'] = "#{node['deployment_server']['url']}/mca-service-#{node['mca_service'][i]['version']}.zip"
	default['mca_service'][i]['home'] = "/opt/mca-service-#{i}"
end