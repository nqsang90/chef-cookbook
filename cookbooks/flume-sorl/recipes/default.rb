#
# Cookbook Name:: flume-solr
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


artifact_id = "flume-solr"
version = node['flume_solr']['version']
package = "#{artifact_id}-#{version}.zip"
deploy_type = "install"


# download
remote_file "#{node['flume_solr']['deploy_dir']}/#{package}" do
	source "#{node['flume_solr']['url']}"
	checksum node['flume_solr']['checksum']
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{node['flume_solr']['deploy_dir']}"
	command "unzip -x #{package}"
	not_if {File.exists?(node['flume_solr']['home'])}
end


include_recipe "flume-sorl::flume-solr"

service "flume-solr" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end

