#
# Cookbook Name:: mfs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mca::default"

package_server = node['deployment_server']['url']
artifact_id = "mfs"
version = "0.2.12-beta2"
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
app_temp_dir = "/tmp/#{artifact_id}"
app_dir = "/opt/daemons/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "mca"
deploy_type = "install"
link_file = "#{app_link_dir}/mca.sh"

if (File.exists?(link_file) && File.symlink?(link_file) && File.readlink(link_file) == "#{app_dir}/#{version}/bin/mca.sh" && File.exists?("#{app_dir}/#{version}"))
	return
end

# download
remote_file "#{mod_dir}/#{package}" do
  source "#{mod_dir}/#{package}"
  #mode "0755"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{version_dir}/#{artifact_id}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{app_dir}/#{version}/libs")}
end


execute "mysql-run-mfs" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mfs/sql/mfs_0.2.0.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'mfs'\" | grep mfs"
end

# config mfs

mfs_config_dir = "#{mod_dir}/mfs"
execute "dos2unix" do
	command "dos2unix #{mfs_config_dir}/*.conf"
end
template "#{mca_config_dir}/service-mca.conf" do
	content "mfs/service-mca.conf.erb"
	source "mfs/service-mca.conf.erb"
end

template "#{mca_config_dir}/service.conf" do
	content "mfs/service.conf.erb"
	source "mfs/service.conf.erb"
end
template "#{mca_config_dir}/service-ac.conf" do
	content "mfs/service-ac.conf.erb"
	source "mfs/service-ac.conf.erb"
end
template "#{mca_config_dir}/service-xsecd.conf" do
	content "mfs/service-xsecd.conf.erb"
	source "mfs/service-xsecd.conf.erb"
end

# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/#{version}/bin"
	command "chmod u+x *.sh"
end

# stop service
execute "stop-service" do
	command "#{link_file} stop"
	only_if "ps -ef | grep mca.sh | grep -v 'grep'"
end
# link
link link_file do
	to	"#{app_dir}/#{version}/bin/mca.sh"
end
# start service
execute "start-service" do
	command "#{link_file} start"
	#not_if "ps -ef | grep mca.sh | grep -v 'grep'"
end

