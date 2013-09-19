

default['mca_hr']['version'] = "0.2.3"
default['mca_hr']['checksum'] = "276ae4c02b4dda8f3b346480961cb85c83a626918de010f473c9e66b5ce85469"

default['mca_hr']['port'] = node['tomcat']['port']
default['mca_hr']['url'] = "#{node['deployment_server']['url']}/mca-hr-#{node['mca_hr']['version']}.zip"

default['mca_hr']['deploy_dir'] = "/opt/mca-system"


