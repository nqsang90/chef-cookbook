#
# Cookbook Name:: xacct
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java::set_java_home"
include_recipe "daemonlib"
include_recipe "commons-daemon"
include_recipe "embedded-webapp"
include_recipe "id-generator"



class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end


host_active_mq = node['active_mq']['host']
account = do_search('account', 'default', 'account')
host_account = account['ipaddress']
port_account = account['port']
if (port_account == '')
	delay_start = true
	return
end
gateway_account = "mca-gateway.vn"


package_server = node['deployment_server']['url']
artifact_id = "xacct"
version = node['xacct']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "#{node['xacct']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
app_link_dir = "/opt/daemons/bin"	

db_user = node['xacct']['db_username']
db_password = node['xacct']['db_password']

mca_structure "create-xacct-#{version}" do
	mod_name 	artifact_id
	dest		app_dir
end

mod_dir = "#{app_dir}/modules"
# download
remote_file "#{mod_dir}/#{package}" do
	source node['xacct']['url']
	checksum node['xacct']['checksum']
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{mod_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
end


# run mysql script
execute "mysql-run-xaccount" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/xacct/script/xaccount.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'xaccount'\" | grep xaccount"
end



# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:service_port => node['xacct']['port'],
		:production => false
	)
	notifies :restart, "service[xacct]"
end



# config xacct
xacct_config_dir = "#{app_dir}/modules/xacct"

execute "dos2unix" do
	command "dos2unix #{xacct_config_dir}/*.conf"
end

template "#{xacct_config_dir}/service-ac.conf" do
	content "service-ac.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
	notifies :restart, "service[xacct]"
end
template "#{xacct_config_dir}/service-account.conf" do
	content "service-account.conf.erb"
	variables(
		:gateway_account => gateway_account,
		:host_account => host_account,
		:port_account => port_account
	)
	notifies :restart, "service[xacct]"
end
template "#{xacct_config_dir}/service-memcached.conf" do
	content "service-memcached.conf.erb"
	notifies :restart, "service[xacct]"
end
template "#{xacct_config_dir}/service-xsecd.conf" do
	content "service-xsecd.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
	notifies :restart, "service[xacct]"
end
template "#{xacct_config_dir}/xacct-jdo.conf" do
	content "xacct-jdo.conf.erb"
	variables(
		:db_host => node['xacct']['db_host'],
		:db_port => node['xacct']['db_port'],
		:db_schema => node['xacct']['db_schema'],
		:db_username => node['xacct']['db_username'],
		:db_password => node['xacct']['db_password']
	)
	notifies :restart, "service[xacct]"
end


#config xacct-mca
xacct_mca_config_dir = "#{app_dir}/modules/xacct/modules/xacct-mca"
template "#{xacct_mca_config_dir}/service-mca.conf" do
	content "xacct-mca/service-mca.conf.erb"
	source "xacct-mca/service-mca.conf.erb"
	variables(
		:host_mca => node['ipaddress']
	)
	notifies :restart, "service[xacct]" 
end
template "#{xacct_mca_config_dir}/service-xsecd.conf" do
	content "xacct-mca/service-xsecd.conf.erb"
	source "xacct-mca/service-xsecd.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
	notifies :restart, "service[xacct]"
end

# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh; chmod u+x #{artifact_id}"
end

link node['xacct']['home'] do
	to app_dir
end

include_recipe "xacct::xacct"

service "xacct" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true
	action :start
end


