#
# Cookbook Name:: installment
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
artifact_id = "installment"
version = node['installment']['version']
package = "#{artifact_id}-#{version}.zip"
version_dir = "#{node['installment']['deploy_dir']}/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
deploy_type = "install"
link_file = "#{app_link_dir}/#{artifact_id}.sh"

installment_port = node['installment']['port']
host_active_mq = node['active_mq']['host']

host_xacct = node['ipaddress']
port_xacct = node['xacct']['port']


if (File.exists?(link_file) && File.symlink?(link_file) && File.readlink(link_file) == "#{app_dir}/bin/#{artifact_id}.sh" && File.exists?("#{app_dir}"))
	#return
end

mca_structure "create-installment-structure" do
	mod_name 	artifact_id
	dest		app_dir
end
mod_dir = "#{app_dir}/modules"
# download
remote_file "#{mod_dir}/#{package}" do
  source "#{node['installment']['url']}"
	checksum "4c9116b272d8f4c1a44c34ed0f979c834e5e6db89925e5a8702a0c56ae732001"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{mod_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
end


# run mysql script
execute "mysql-run-installment" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/installment/script/installment-0.5.20-alpha2.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'installment'\" | grep installment"
end

# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:service_port => installment_port,
		:production => false
	)
    notifies :restart, "service[installment]"
end


# config installment
installment_config_dir = "#{app_dir}/modules/installment"

execute "dos2unix" do
	command "dos2unix #{installment_config_dir}/*.conf"
end

template "#{installment_config_dir}/active_mq-jndi.conf" do
	content "active_mq-jndi.conf.erb"
	variables(
		:host_active_mq => host_active_mq
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/database.conf" do
	content "database.conf.erb"
	variables(
		:db_host => "localhost",
		:db_user => db_user,
		:db_password => db_password
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/installment-email-order.conf" do
	content "installment-email-order.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/installment-report.conf" do
	content "installment-report.conf.erb"
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/jms-jndi-inv-notification.conf" do
	content "jms-jndi-inv-notification.conf.erb"
	variables(
		:host_active_mq => host_active_mq
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/mgr-file.conf" do
	content "mgr-file.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service.conf" do
	content "service.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service-ac.conf" do
	content "service-ac.conf.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service-account.conf" do
	content "service-account.conf.erb"
	variables(
		:host_account => node['ipaddress'],
		:port_account => node['account']['port']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service-inventory.conf" do
	content "service-inventory.conf.erb"
	variables(
		:host_inventory => node['ipaddress'],
		:port_inventory => node['inventory']['port']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service-mfs.conf" do
	content "service-mfs.conf.erb"
	variables(
		:host_mfs => node['ipaddress'],
		:port_mfs => node['mfs']['port']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service-order.conf" do
	content "service-order.conf.erb"
	variables(
		:host => node['ipaddress'],
		:port => node['order_process']['port']
	)
    notifies :restart, "service[installment]"
end
template "#{installment_config_dir}/service-xaccount.conf" do
	content "service-xaccount.conf.erb"
	variables(
		:host_xacct => node['ipaddress'],
		:port_xacct => port_xacct
	)
    notifies :restart, "service[installment]"
end


template "#{app_dir}/config/commons-logging.properties" do
	content "commons-logging.properties.erb"
end
template "#{app_dir}/config/log4j2.xml" do
	content "log4j2.xml.erb"
    notifies :restart, "service[installment]"
end


# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh; chmod u+x #{artifact_id}"
end

# link folder
link node['installment']['home'] do
	to app_dir
end

include_recipe "deamon-service::installment"

service "installment" do
	provider Chef::Provider::Service::Upstart
	supports :status => true, :restart => true, :reload => true
	action :start
end




