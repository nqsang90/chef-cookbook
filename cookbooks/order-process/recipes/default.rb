#
# Cookbook Name:: order-process
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
include_recipe "mbv-search"
class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

inventory = do_search('inventory', 'default', 'inventory')
	host_inventory = inventory['ipaddress']
	port_inventory = inventory['port']
host_active_mq = node['active_mq']['host']
mfs = do_search('mfs', 'default', 'mfs')
	host_mfs = mfs['ipaddress']
	port_mfs = mfs['port']
xacct = do_search('xacct', 'default', 'xacct')
	host_xacct = xacct['ipaddress']
	port_xacct = xacct['port']

package_server = node['deployment_server']['url']
artifact_id = "order-process"
version = node['order_process']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "#{node['order_process']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "order"
deploy_type = "install"
link_file = "#{app_link_dir}/#{artifact_id}.sh"
order_process_port = node['order_process']['port']

mca_structure "create-order-process-structure" do
	mod_name 	artifact_id
	dest		app_dir
end

mod_dir = "#{app_dir}/modules"
# download
remote_file "#{mod_dir}/#{package}" do
	source node['order_process']['url']
	checksum node['order_process']['checksum']
  #mode "0755"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{mod_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
end

# run mysql script
execute "mysql-run-order" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/order-process/script/order.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'order'\" | grep order"
end

# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:service_port => order_process_port,
		:production => false
	)
	notifies :restart, "service[order-process]"
end



# config order
order_config_dir = "#{app_dir}/modules/order-process"

execute "dos2unix" do
	command "dos2unix #{order_config_dir}/*.conf"
end

template "#{order_config_dir}/active_mq-jndi.conf" do
	content "active_mq-jndi.conf.erb"
	variables(
		:host_active_mq => host_active_mq
	)
	notifies :restart, "service[order-process]"
end
template "#{order_config_dir}/inv-service.properties" do
	content "inv-service.properties.erb"
	variables(
		:host_inventory => host_inventory,
		:port_inventory => port_inventory
	)
	notifies :restart, "service[order-process]"
end
template "#{order_config_dir}/order-process.properties" do
	content "order-process.properties.erb"
	variables(
		:db_user => db_user,
		:db_password => db_password
	)
	notifies :restart, "service[order-process]"
end
template "#{order_config_dir}/service-inventory.conf" do
	content "service-inventory.conf.erb"
	variables(
		:host_inventory => host_inventory,
		:port_inventory => port_inventory
	)
	notifies :restart, "service[order-process]"
end
template "#{order_config_dir}/service-mfs.conf" do
	content "service-mfs.conf.erb"
	variables(
		:host_mfs => host_mfs,
		:port_mfs => port_mfs
	)
	notifies :restart, "service[order-process]"
end
template "#{order_config_dir}/service-xacct.conf" do
	content "service-xacct.conf.erb"
	variables(
		:host_xacct => host_xacct,
		:port_xacct => port_xacct
	)
	notifies :restart, "service[order-process]"
end

# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh; chmod u+x #{artifact_id}"
end

# link folder
link node['order_process']['home'] do
	to app_dir
end

include_recipe "order-process::order-process"

service "order-process" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end
