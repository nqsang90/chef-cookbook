#
# Cookbook Name:: mca-service
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
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

mfs = do_search('mfs', 'default', 'mfs')
	host_mfs = mfs['ipaddress']
	port_mfs = mfs['port']
host_active_mq = node['active_mq']['host']
inventory = do_search('inventory', 'default', 'inventory')
	host_inventory = inventory['ipaddress']
	port_inventory = inventory['port']
xacct = do_search('xacct', 'default', 'xacct')
	host_xacct = xacct['ipaddress']
	port_xacct = xacct['port']
account = do_search('account', 'default', 'account')
	host_account = account['ipaddress']
	port_account = account['port']
mca = do_search('mca', 'default', 'mca')
	host_mca = mca['ipaddress']
	port_mca = mca['port']

if (port_mfs == '' || port_inventory == '' || port_xacct == '' || port_account == '' || port_mca == '')
	return
end

package_server = node['deployment_server']['url']
artifact_id = "mca-service"
version = node['mca_service']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "#{node['mca_service']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']

deploy_type = "install"
link_file = "#{app_link_dir}/#{artifact_id}.sh"
mca_service_port = node['mca_service']['port']

mca_structure "create-mca-service-structure" do
	mod_name 	artifact_id
	dest		app_dir
end

mod_dir = "#{app_dir}/modules"

# download
remote_file "#{mod_dir}/#{package}" do
	source node['mca_service']['url']
	checksum node['mca_service']['checksum']
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{mod_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
end


# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:service_port => mca_service_port,
		:production => false
	)
	notifies :restart, "service[mca-service]"
end



# config mca-service
mca_service_config_dir = "#{app_dir}/modules/mca-service"

execute "dos2unix" do
	command "dos2unix #{mca_service_config_dir}/*.conf"
end

template "#{mca_service_config_dir}/active_mq.conf" do
	content "active_mq.conf.erb"
	variables(
		:host_active_mq => host_active_mq
	)
	notifies :restart, "service[mca-service]"
end

template "#{mca_service_config_dir}/service-mca.conf" do
	content "service-mca.conf.erb"
	variables(
		:host_mca => host_mca,
		:port_mca => port_mca
	)
	notifies :restart, "service[mca-service]"
end
template "#{mca_service_config_dir}/service-mfs.conf" do
	content "service-mfs.conf.erb"
	variables(
		:host_mfs => host_mfs,
		:port_mfs => port_mfs
	)
	notifies :restart, "service[mca-service]"
end
template "#{mca_service_config_dir}/service-xacct.conf" do
	content "service-xacct.conf.erb"
	variables(
		:host_xacct => host_xacct,
		:port_xacct => port_xacct
	)
	notifies :restart, "service[mca-service]"
end

template "#{mca_service_config_dir}/service-xsecd.conf" do
	content "service-xsecd.conf.erb"
	variables(
		:host_xsecd => node['ipaddress']
	)
	notifies :restart, "service[mca-service]"
end


# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh; chmod u+x #{artifact_id}"
end

# link folder
link node['mca_service']['home'] do
	to app_dir
end


include_recipe "mca-service::mca-service"

service "mca-service" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end
