#
# Cookbook Name:: mcaweb
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#package "maven"
#package "tomcat7"

package_server = node['deployment_server']['url']
artifact_id = "mcaweb"
dest_link = "user"
version = "0.3.36"
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
app_temp_dir = "/tmp/#{artifact_id}"
app_dir = "/opt/webapps/#{artifact_id}"
deploy_type = "install"

link_path = "#{tomcat_dir}/webapps/#{dest_link}"
if (File.exists?("#{link_path}") && File.symlink?("#{link_path}") && File.readlink("#{link_path}") == "#{app_dir}/#{version}/#{artifact_id}" && File.exists?("#{app_dir}/#{version}"))
	#return
end

#prepare webapps folder
directory "#{app_dir}/#{version}" do
  owner "root"
  group "root"
  mode 00755
  recursive true
end

# download
remote_file "#{app_dir}/#{version}/#{package}" do
  source "#{package_server}/#{artifact_id}/#{version}/#{package}"
  mode "0755"
end

# extract package
execute "extract-package" do
	cwd app_dir+'/'+version
	command "unzip -x #{package}"
	not_if {File.exists?(app_dir+'/'+version+'/'+artifact_id)}
end


# config the package

config_dir = "#{app_dir}/#{version}/#{artifact_id}/WEB-INF"
#execute "dos2unix" do
	#command "dos2unix #{config_dir}/*.conf"
#	user "root"
	#group "root"
#end

template "#{config_dir}/service-account.conf" do
	content "service-account.conf.erb"
end


#stop server
service "tomcat6" do
	action :stop
end
# link
link "#{tomcat_dir}/webapps/#{dest_link}" do
	to	"#{app_dir}/#{version}/#{artifact_id}"
end
# start tomcat server
service "tomcat6" do
	action :start
end



