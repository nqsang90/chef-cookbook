default['solr']['version'] = '4.0.0'
default['solr']['deploy_dir'] = "/opt"
default['solr']['home'] = "/opt/apache-solr-#{node['solr']['version']}"
default['solr']['url'] = "#{node['deployment_server']['url']}/apache-solr-#{node['solr']['version']}.zip"

