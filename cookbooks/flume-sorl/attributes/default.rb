default['flume_solr']['version'] = '0.1.0'
default['flume_solr']['deploy_dir'] = "/opt"
default['flume_solr']['home'] = "/opt/flume-solr-#{node['flume_solr']['version']}"
default['flume_solr']['url'] = "#{node['deployment_server']['url']}/flume-solr-#{node['flume_solr']['version']}.zip"
default['flume_solr']['checksum'] = "c3f2fcf555f2e190631a63a20095fd8f72017be5c5c71fd239c7dd8f571e7499"

