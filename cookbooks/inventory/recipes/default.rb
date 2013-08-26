#
# Cookbook Name:: inventory
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "daemonlib::default"
include_recipe "commons-daemon::default"

package_server = node['deployment_server']['url']
artifact_id = "inventory"
version = "0.3.10-beta1"
package = "#{artifact_id}-#{version}.zip"
version_dir = "/opt/daemons/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "mca"
deploy_type = "install"
link_file = "#{app_link_dir}/#{artifact_id}.sh"
inventory_port = 8181

if (File.exists?(link_file) && File.symlink?(link_file) && File.readlink(link_file) == "#{app_dir}/bin/#{artifact_id}.sh" && File.exists?("#{app_dir}"))
	#return
end

mca_structure "create-inventory-structure" do
	mod_name 	artifact_id
	dest		app_dir
end

mod_dir = "#{app_dir}/modules"
# download
remote_file "#{mod_dir}/#{package}" do
  source "#{package_server}/#{artifact_id}/#{version}/#{package}"
  #mode "0755"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{mod_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
end


# run mysql script
execute "mysql-run-inventory" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/inventory/script/inventory-0.1.2.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'inventory'\" | grep inventory"
end
execute "mysql-patch-inventory-1" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/inventory/script/patch-0.2.0.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show INDEX from inventory.inventory_item\" | grep groupId"
end
#execute "mysql-patch-inventory-2" do
#	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/inventory/script/patch-0.2.1.sql"
	#not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'inventory'\" | grep inventory"
#end


# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:service_port => inventory_port,
		:production => false,
	)
end



# config inventory
inventory_config_dir = "#{app_dir}/modules/inventory"

execute "dos2unix" do
	command "dos2unix #{inventory_config_dir}/*.conf"
end

template "#{inventory_config_dir}/active_mq-jndi.conf" do
	content "active_mq-jndi.conf.erb"
end
template "#{inventory_config_dir}/crawl.conf" do
	content "crawl.conf.erb"
	variables(
		:host_inventory => node['ipaddress'],
		:port_inventory => inventory_port
	)
end
template "#{inventory_config_dir}/ctx-jdo.conf" do
	content "ctx-jdo.conf.erb"
	variables(
		:service_port => inventory_port,
		:db_host => "localhost",
		:db_user => db_user,
		:db_password => db_password
	)
end
template "#{inventory_config_dir}/service-installment.conf" do
	content "service-installment.conf.erb"
	variables(
		:installment_host => node['ipaddress'],
		:installment_port => 8383
	)
end


# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh; chmod u+x #{artifact_id}"
end

# stop service
execute "stop-service" do
	command "#{link_file} stop"
	only_if {::File.exists?(link_file)}
end
# link
link link_file do
	to	"#{app_dir}/bin/#{artifact_id}.sh"
end
# start service
execute "start-service" do
	command "#{link_file} start"
	#not_if "ps -ef | grep mca/ | grep -v 'grep'"
end
