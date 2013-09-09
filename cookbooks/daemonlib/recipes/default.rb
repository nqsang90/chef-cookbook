#
# Cookbook Name:: daemonlib
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "cpan::bootstrap"
include_recipe "cpan-mods"

package_server = node['deployment_server']['url']
artifact_id = "daemonlib"
version = node['daemonlib']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "#{node['daemonlib']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
deploy_type = "install"

#prepare webapps folder
directory "#{version_dir}" do
  recursive true
end


# download
remote_file "#{version_dir}/#{package}" do
  source "#{node['daemonlib']['url']}"
	checksum "8622120a271a390cc5f3b3e2643b84d55b99ee1c39b7cf5a085a37b644fa2919"
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




