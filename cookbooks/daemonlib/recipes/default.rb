#
# Cookbook Name:: daemonlib
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


package_server = node['deployment_server']['url']
artifact_id = "daemonlib"
version = node['daemonlib']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "/opt/daemons/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
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
execute "extract-daemonlib" do
	cwd "#{version_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{app_dir}/bin")}
end

execute "make-executable" do
	cwd "#{app_dir}/bin"
	command "chmod a+x *.sh"
end




