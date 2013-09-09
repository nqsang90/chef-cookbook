#
# Cookbook Name:: commons-daemon
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

artifact_id = "commons-daemon"
version = node['commons_daemon']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "#{node['commons_daemon']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
deploy_type = "install"

#prepare webapps folder
directory "#{version_dir}" do
  recursive true
end


# download
remote_file "#{version_dir}/#{package}" do
  source "#{node['commons_daemon']['url']}"
	checksum "3af2690fe7f82d2f759c86a1c8686759e460ccf6e5ef5f9a8e10d8db25e5c6b6"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{version_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{app_dir}/bin")}
end

# extract jsvc.tar.gz
execute "extract jsvc" do
	cwd "#{app_dir}/bin"
	command "tar xzf jsvc.tar.gz"
	not_if {File.exists?("#{app_dir}/bin/jsvc-src")}
end

# make configure executable, then make and configure
execute "extract jsvc" do
	cwd "#{app_dir}/bin"
	command "chmod a+x configure; ./configure --with-java=$JAVA_HOME; make"
	not_if {File.exists?("#{app_dir}/bin/jsvc-src/jsvc")}
end












