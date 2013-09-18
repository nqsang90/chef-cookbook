#
# Cookbook Name:: sorl-mbv
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

artifact_id = "solr"
version = node['solr']['version']
package = "#{artifact_id}-#{version}.zip"
deploy_type = "install"


# download
remote_file "#{node['solr']['deploy_dir']}/#{package}" do
  source "#{node['solr']['url']}"
	checksum "905979f808654abe0fd4824f9d17280101ef2b9452e65560926cc1709dbc719e"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{node['solr']['deploy_dir']}"
	command "unzip -x #{package}"
	not_if {File.exists?(node['solr']['home'])}
end


