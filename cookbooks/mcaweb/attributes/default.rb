
default['user']['num_instance'] = 2

default['user'][0]['version'] = "0.3.36"
default['user'][1]['version'] = "0.3.35"
default['user'][0]['checksum'] = "d9c6ba173462efde90b2d72c68ecf3128aba71b81958f9ca14b4c136141364bc"
default['user'][1]['checksum'] = "d9c6ba173462efde90b2d72c68ecf3128aba71b81958f9ca14b4c136141364bc"

default['user'][0]['status'] = 'enable'
default['user'][1]['status'] = 'enable'

default['user']['default'] = 0

for i in 0..node['mbv_tomcat']['num_instance']-1
	default['user'][i]['port'] = node['mbv_tomcat']['connector_ports'][i]
	default['user'][i]['url'] = "#{node['deployment_server']['url']}/mcaweb-#{node['user'][i]['version']}.zip"
end

default['user']['deploy_dir'] = "/opt/mca-system"


