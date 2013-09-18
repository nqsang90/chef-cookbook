default['mca']['num_instance'] = 2

default['mca'][0]['version'] = "0.3.15-beta1"
default['mca'][1]['version'] = "0.3.14-beta1"
default['mca'][0]['checksum'] = "d9c6ba173462efde90b2d72c68ecf3128aba71b81958f9ca14b4c136141364bc"
default['mca'][1]['checksum'] = "fd30809462802680e5bfeaa0c8dbfbe9ecc43cf261e1e929bc5316dc2324242c"
default['mca'][0]['status'] = 'enable'
default['mca'][1]['status'] = 'enable'
default['mca']['port'] = [8484,9494]
default['mca']['deploy_dir'] = "/opt/mca-system"

default['mca']['default'] = 0

for i in 0..node['mca']['num_instance']-1
        default['mca'][i]['port'] = node['mca']['port'][i]
        default['mca'][i]['url'] = "#{node['deployment_server']['url']}/mca-#{node['mca'][i]['version']}.zip"
		default['mca'][i]['home'] = "/opt/mca-#{i}"
end
