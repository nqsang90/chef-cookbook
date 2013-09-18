#
# Cookbook Name:: flume-mbv
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


artifact_id = "apache-flume"
version = node['apache_flume']['version']
package = "#{artifact_id}-#{version}.zip"
deploy_type = "install"


# download
remote_file "#{node['apache_flume']['deploy_dir']}/#{package}" do
  source "#{node['apache_flume']['url']}"
	checksum "09e92bbfe500b29dd4ce140ed68c4c7224fa1605326bfb0440e7300e3a89a3dd"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{node['apache_flume']['deploy_dir']}"
	command "unzip -x #{package}"
	not_if {File.exists?(node['apache_flume']['home'])}
end


