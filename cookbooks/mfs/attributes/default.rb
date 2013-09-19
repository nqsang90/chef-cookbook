
default['mfs']['version'] = "0.2.13-alpha2"

default['mfs']['checksum'] = "d6802ecac3c9f92c2e05aba601d8e6c198e1353aa11c63a7f60a695c834c30ed"

default['mfs']['status'] = 'enable'
default['mfs']['port'] = 8686
default['mfs']['deploy_dir'] = "/opt/mca-system"

default['mfs']['port'] = node['mfs']['port']
default['mfs']['url'] = "#{node['deployment_server']['url']}/mfs-#{node['mfs']['version']}.zip"
default['mfs']['home'] = "/opt/mfs"
