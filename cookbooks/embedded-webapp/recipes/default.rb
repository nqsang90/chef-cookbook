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
app_dir = "/opt/daemons/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
deploy_type = "install"

#prepare webapps folder
directory "#{version_dir}" do
  #owner "root"
  #group "root"
  #mode 00755
  recursive true
  #action :nothing
end


# download
remote_file "#{version_dir}/#{package}" do
  source "#{package_server}/#{artifact_id}/#{version}/#{package}"
  #mode "0755"
  #action :nothing
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{version_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{version_dir}/#{artifact_id}/libs")}
end


