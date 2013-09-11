#
# Cookbook Name:: mfs
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java::set_java_home"
include_recipe "account"
include_recipe "daemonlib"
include_recipe "commons-daemon"
include_recipe "embedded-webapp"
include_recipe "id-generator"

package_server = node['deployment_server']['url']
artifact_id = "mfs"
version = "0.2.13-beta2"
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
version_dir = "#{node['mfs']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"

app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "mfs"
deploy_type = "install"
link_file = "#{app_link_dir}/mfs.sh"


host_xacct = node['ipaddress']
port_xacct = node['xacct']['port']
host_account = node['ipaddress']
host_mca = node['ipaddress']
port_mca = node['mca']['port']
host_xsecd = node['ipaddress']


mca_structure "create-mfs-structure" do
	mod_name 	artifact_id
	dest		app_dir
end

mod_dir = "#{app_dir}/modules"

# download
remote_file "#{mod_dir}/#{package}" do
	source node['mfs']['url']
	checksum "d6802ecac3c9f92c2e05aba601d8e6c198e1353aa11c63a7f60a695c834c30ed"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd mod_dir
	command "unzip -x #{package}"
	not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
end


execute "mysql-run-mfs" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mfs/sql/mfs_0.2.12.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'mfs'\" | grep mfs"
    notifies :restart, "service[mfs]"
end
execute "mysql-patch-mfs" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mfs/sql/db-patch-0.2.12.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"use mfs; show columns from scheduled_event;\" | grep schedule_id"
    notifies :restart, "service[mfs]"
end

# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:service_port => node['mfs']['port'],
		:production => false
	)
    notifies :restart, "service[mfs]"
end
# config mfs

mfs_config_dir = "#{mod_dir}/mfs"
execute "dos2unix" do
	command "dos2unix #{mfs_config_dir}/*.conf"
end

template "#{mfs_config_dir}/mfs.conf" do
	content "mfs.conf.erb"
	variables(
		:db_host => "localhost",
		:db_port => 3306,
		:db_user => "root",
		:db_password => node['mysql']['server_root_password']
	)
    notifies :restart, "service[mfs]"
end

template "#{mfs_config_dir}/service-mca.conf" do
	content "service-mca.conf.erb"
	variables(
		:host_mca => host_mca,
		:port_mca => port_mca
	)
    notifies :restart, "service[mfs]"
end

template "#{mfs_config_dir}/service.conf" do
	content "service.conf.erb"
	variables(
		:host_xacct => host_xacct,
		:port_xacct => port_xacct,
		:host_account => host_account
	)
    notifies :restart, "service[mfs]"
end
template "#{mfs_config_dir}/service-ac.conf" do
	content "service-ac.conf.erb"
    notifies :restart, "service[mfs]"
end
template "#{mfs_config_dir}/service-xsecd.conf" do
	content "service-xsecd.conf.erb"
	variables(
		:host_xsecd => host_xsecd
	)
    notifies :restart, "service[mfs]"
end

# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh"
end


# link folder
link node['mfs']['home'] do
	to app_dir
end

include_recipe "deamon-service::mfs"

service "mfs" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end

