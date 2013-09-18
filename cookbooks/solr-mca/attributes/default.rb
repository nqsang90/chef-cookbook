#default['sorl']['version'] = '4.4.0'
default['solr_mca']['port'] = 8984
default['solr_mca']['deploy_dir'] = "#{node['solr']['home']}"
default['solr_mca']['home'] = "#{node['solr']['home']}/mca"
default['solr_mca']['url'] = "#{node['deployment_server']['url']}/solr-mods/mca.zip"
default['solr_mca']['checksum'] = "d938163d0c362960598885b5330cf78762b487373853cdb6d3188a355cd303b3"
