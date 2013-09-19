
default['mca']['version'] = "0.3.15-beta1"

default['mca']['checksum'] = "d9c6ba173462efde90b2d72c68ecf3128aba71b81958f9ca14b4c136141364bc"

default['mca']['port'] = 8484
default['mca']['deploy_dir'] = "/opt/mca-system"


default['mca']['url'] = "#{node['deployment_server']['url']}/mca-#{node['mca']['version']}.zip"
default['mca']['home'] = "/opt/mca"

