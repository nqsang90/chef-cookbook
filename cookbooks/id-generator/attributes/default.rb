
default['id_generator']['version'] = '0.1.1'
default['id_generator']['deploy_dir'] = "/opt/mca-system"
default['id_generator']['url'] = "#{node['deployment_server']['url']}/id-generator-#{node['id_generator']['version']}.zip"
