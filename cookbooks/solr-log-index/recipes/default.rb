#
# Cookbook Name:: solr-log-index
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sorl-mbv"
include_recipe "daemon"

artifact_id = "log_index"
package = "#{artifact_id}.zip"
app_dir = "#{node['solr_log_index']['deploy_dir']}/log_index"
deploy_type = "install"


# download
remote_file "#{node['solr_log_index']['deploy_dir']}/#{package}" do
  source "#{node['solr_log_index']['url']}"
	checksum "fe99bef8004d6743e03e03a6dcbc05ecb96fc721f31be853377db26826c7649b"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{node['solr_log_index']['deploy_dir']}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{app_dir}/solr")}
end

#config
config_dir = "#{app_dir}/solr/bin"

template "#{config_dir}/daemon.sh" do
	content "daemon.sh.erb"
end

template "#{config_dir}/start.sh" do
	content "start.sh.erb"
end
template "#{config_dir}/setup.sh" do
	content "setup.sh.erb"
end
#template "#{app_dir}/solr/log_action/conf/scripts.sh" do
	#content "scripts.sh.erb"
#end


execute "make-exe" do
	cwd "#{config_dir}"
	command "chmod a+x *.sh"
end

include_recipe "solr-log-index::solr-log-index"

service "solr-log-index" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end


