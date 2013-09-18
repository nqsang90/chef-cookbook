default['mfs']['num_instance'] = 2

default['mfs'][0]['version'] = "0.2.13-alpha2"
default['mfs'][1]['version'] = "0.2.12-alpha2"
default['mfs'][0]['checksum'] = "d6802ecac3c9f92c2e05aba601d8e6c198e1353aa11c63a7f60a695c834c30ed"
default['mfs'][1]['checksum'] = "d6802ecac3c9f92c2e05aba601d8e6c198e1353aa11c63a7f60a695c834c30ed"
default['mfs'][0]['status'] = 'enable'
default['mfs'][1]['status'] = 'enable'
default['mfs']['port'] = [8686,9696]
default['mfs']['deploy_dir'] = "/opt/mca-system"
default['mfs']['default'] = 0

for i in 0..node['mfs']['num_instance']-1
        default['mfs'][i]['port'] = node['mfs']['port'][i]
        default['mfs'][i]['url'] = "#{node['deployment_server']['url']}/mfs-#{node['mfs'][i]['version']}.zip"
		default['mfs'][i]['home'] = "/opt/mfs-#{i}"
end

