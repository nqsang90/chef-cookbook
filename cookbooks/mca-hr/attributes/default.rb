
default['mca_hr']['num_instance'] = 2

default['mca_hr'][0]['version'] = "0.2.3"
default['mca_hr'][1]['version'] = "0.2.2"
default['mca_hr'][0]['checksum'] = "276ae4c02b4dda8f3b346480961cb85c83a626918de010f473c9e66b5ce85469"
default['mca_hr'][1]['checksum'] = "276ae4c02b4dda8f3b346480961cb85c83a626918de010f473c9e66b5ce85469"

default['mca_hr'][0]['status'] = 'enable'
default['mca_hr'][1]['status'] = 'enable'

default['mca_hr']['default'] = 0

for i in 0..node['mbv_tomcat']['num_instance']-1
	default['mca_hr'][i]['port'] = node['mbv_tomcat']['connector_ports'][i]
	default['mca_hr'][i]['url'] = "#{node['deployment_server']['url']}/mca-hr-#{node['mca_hr'][i]['version']}.zip"
end

default['mca_hr']['deploy_dir'] = "/opt/mca-system"


