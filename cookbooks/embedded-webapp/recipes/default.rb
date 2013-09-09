#
# Cookbook Name:: embedded-webapp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

version = node['embedded_webapp']['version']
package_server = node['deployment_server']['url']
artifact_id = "embedded-webapp"
package = "#{artifact_id}-#{version}.zip"
app_dir = "#{node['embedded_webapp']['deploy_dir']}/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
deploy_type = "install"

#prepare webapps folder
directory "#{version_dir}" do
  recursive true
end


# download
remote_file "#{version_dir}/#{package}" do
  source "#{node['embedded_webapp']['url']}"
	checksum "191a8a23706bed32c78963caae8165a977a5f07dd50c4e7a368ac33d86b9f52d"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{version_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{version_dir}/#{artifact_id}/libs")}
end


