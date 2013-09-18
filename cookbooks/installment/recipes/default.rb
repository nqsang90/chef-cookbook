#
# Cookbook Name:: installment
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
include_recipe "installment::installment"

class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end


host_active_mq = node['active_mq']['host']

account = do_search('account', 'default', 'account')
host_account = account['ipaddress']
port_account = account['port']

inv = do_search('inventory', 'default', 'inventory')
host_inv = inv['ipaddress']
port_inv = inv['port']

order = do_search('order-process', 'default', 'order_process')
host_order = order['ipaddress']
port_order = order['port']

xacct = do_search('xacct', 'default', 'xacct')
host_xacct = xacct['ipaddress']
port_xacct = xacct['port']

mfs = do_search('mfs', 'default', 'mfs')
host_mfs = mfs['ipaddress']
port_mfs = mfs['port']

gateway_account_admin = "mca-gateway.vn"
gateway_account_user = "mca-gateway.vn"

if (port_account == '' || port_inv == '' || port_order == '' || port_xacct == '' || port_mfs == '')
	return
end

for i in 0..node['installment']['num_instance']-1
	package_server = node['deployment_server']['url']
	artifact_id = "installment"
	version = node['installment'][i]['version']
	package = "#{artifact_id}-#{version}.zip"
	version_dir = "#{node['installment']['deploy_dir']}/#{artifact_id}/#{version}"
	app_dir = "#{version_dir}/#{artifact_id}"
	app_link_dir = "/opt/daemons/bin"
	db_user = node['installment']['db_username']
	db_password = node['installment']['db_password']

	link_file = "#{app_link_dir}/#{artifact_id}.sh"

	mca_structure "create-installment-structure" do
		mod_name 	artifact_id
		dest		app_dir
	end
	mod_dir = "#{app_dir}/modules"
	# download
	remote_file "#{mod_dir}/#{package}" do
		source "#{node['installment'][i]['url']}"
		checksum node['installment'][i]['checksum']
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
			:service_port => node['installment'][i]['port'],
			:production => false
		)
		notifies :restart, "service[installment-#{i}]"
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
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/database.conf" do
		content "database.conf.erb"
		variables(
			:db_host => node['installment']['db_host'],
			:db_schema => node['installment']['db_schema'],
			:db_port => node['installment']['db_port'],
			:db_username => node['installment']['db_username'],
			:db_password => node['installment']['db_password']
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/installment-email-order.conf" do
		content "installment-email-order.conf.erb"
		variables(
			:ipaddress => node['ipaddress']
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/installment-report.conf" do
		content "installment-report.conf.erb"
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/jms-jndi-inv-notification.conf" do
		content "jms-jndi-inv-notification.conf.erb"
		variables(
			:host_active_mq => host_active_mq
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/mgr-file.conf" do
		content "mgr-file.conf.erb"
		variables(
			:ipaddress => node['ipaddress']
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/service.conf" do
		content "service.conf.erb"
		variables(
			:ipaddress => node['ipaddress']
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/service-ac.conf" do
		content "service-ac.conf.erb"
		variables(
			:ipaddress => node['ipaddress']
		)
		notifies :restart, "service[installment-#{i}]"
	end

	template "#{installment_config_dir}/service-account.conf" do
		content "service-account.conf.erb"
		variables(
			:gateway_account_admin => gateway_account_admin,
			:gateway_account_user => gateway_account_user,
			:host_account => host_account,
			:port_account => port_account
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/service-inventory.conf" do
		content "service-inventory.conf.erb"
		variables(
			:host_inventory => host_inv,
			:port_inventory => port_inv
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/service-mfs.conf" do
		content "service-mfs.conf.erb"
		variables(
			:host_mfs => host_mfs,
			:port_mfs => port_mfs
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/service-order.conf" do
		content "service-order.conf.erb"
		variables(
			:host => host_order,
			:port => port_order
		)
		notifies :restart, "service[installment-#{i}]"
	end
	template "#{installment_config_dir}/service-xaccount.conf" do
		content "service-xaccount.conf.erb"
		variables(
			:host_xacct => host_xacct,
			:port_xacct => port_xacct
		)
		notifies :restart, "service[installment-#{i}]"
	end


	template "#{app_dir}/config/commons-logging.properties" do
		content "commons-logging.properties.erb"
	end
	template "#{app_dir}/config/log4j2.xml" do
		content "log4j2.xml.erb"
		notifies :restart, "service[installment-#{i}]"
	end


	# make *.sh executable
	execute "chmod-add-executable" do
		cwd "#{app_dir}/bin"
		command "chmod u+x *.sh; chmod u+x #{artifact_id}"
	end

	# link folder
	link node['installment'][i]['home'] do
		to app_dir
	end

	service "installment-#{i}" do
		provider Chef::Provider::Service::Upstart
		supports :status => true, :restart => true, :reload => true
		action :start
	end
end



