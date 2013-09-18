#default['sorl']['version'] = '4.4.0'
default['solr_log_index']['port'] = 8983
default['solr_log_index']['deploy_dir'] = "#{node['solr']['home']}"
default['solr_log_index']['home'] = "#{node['solr']['home']}/log_index"
default['solr_log_index']['url'] = "#{node['deployment_server']['url']}/solr-mods/log_index.zip"

