#
# Cookbook Name:: id-generator
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute



package_server = node['deployment_server']['url']
artifact_id = "id-generator"
version = node['id_generator']['version']
package = "#{artifact_id}-#{version}.zip"
app_dir = "#{node['id_generator']['deploy_dir'] }/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
deploy_type = "install"

#prepare webapps folder
directory "#{version_dir}" do
  recursive true
end


# download
remote_file "#{version_dir}/#{package}" do
  source "#{node['id_generator']['url']}"
	checksum "e8c1a3669e0d83d86c48847e4c37eed2702e0b2cf90dbcfaadfa074b6a840aa2"
  #mode "0755"
  #action :nothing
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{app_dir}/#{version}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{version_dir}/#{artifact_id}/libs")}
end


