#
# Cookbook Name:: solr-mca
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sorl-mbv"
include_recipe "daemon"

artifact_id = "mca"
package = "#{artifact_id}.zip"
app_dir = "#{node['solr_mca']['deploy_dir']}/mca"
deploy_type = "install"


# download
remote_file "#{node['solr_mca']['deploy_dir']}/#{package}" do
  source "#{node['solr_mca']['url']}"
	checksum node['solr_mca']['checksum']
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{node['solr_mca']['deploy_dir']}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{app_dir}/solr")}
end

#config
config_dir = "#{app_dir}/solr/bin"

template "#{config_dir}/daemon.sh" do
	content "daemon.sh.erb"
	notifies :restart, "service[solr-mca]"
end

template "#{config_dir}/start.sh" do
	content "start.sh.erb"
	notifies :restart, "service[solr-mca]"
end
template "#{config_dir}/setup.sh" do
	content "setup.sh.erb"
	notifies :restart, "service[solr-mca]"
end

execute "make-exe" do
	cwd "#{config_dir}"
	command "chmod a+x *.sh"
end

include_recipe "solr-mca::solr-mca"

service "solr-mca" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end


