#
# Cookbook Name:: inventory
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

include_recipe "inventory::inventory"

class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

host_active_mq = node['active_mq']['host']

installment = do_search('installment', 'default', 'installment')
host_installment = installment['ipaddress']
port_installment = installment['port']

if (port_installment == '')
	return
end

for i in 0..node['inventory']['num_instance']-1
	package_server = node['deployment_server']['url']
	artifact_id = "inventory"
	version = node['inventory'][i]['version']
	package = "#{artifact_id}-#{version}.zip"
	version_dir = "#{node['inventory']['deploy_dir']}/#{artifact_id}/#{version}"
	app_dir = "#{version_dir}/#{artifact_id}"
	app_link_dir = "/opt/daemons/bin"
	link_file = "#{app_link_dir}/#{artifact_id}.sh"

	db_user = node['inventory']['db_username']
	db_password = node['inventory']['db_password']

	inventory_port = node['inventory'][i]['port']
	mca_structure "create-inventory-structure" do
		mod_name 	artifact_id
		dest		app_dir
	end


	mod_dir = "#{app_dir}/modules"
	# download
	remote_file "#{mod_dir}/#{package}" do
		source node['inventory'][i]['url']
		checksum node['inventory'][i]['checksum']
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


=begin
	execute "mysql-patch-inventory-1" do
		command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/inventory/script/patch-0.2.0.sql"
		not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show INDEX from inventory.inventory_item\" | grep groupId"
	end
=end
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
			:production => false
		)
		notifies :restart, "service[inventory-#{i}]"
	end



	# config inventory
	inventory_config_dir = "#{app_dir}/modules/inventory"

	execute "dos2unix" do
		command "dos2unix #{inventory_config_dir}/*.conf"
	end

	template "#{inventory_config_dir}/active_mq-jndi.conf" do
		content "active_mq-jndi.conf.erb"
		variables(
			:host_active_mq => host_active_mq,
		)
		notifies :restart, "service[inventory-#{i}]"
	end
	template "#{inventory_config_dir}/crawl.conf" do
		content "crawl.conf.erb"
		variables(
			:host_inventory => node['ipaddress'],
			:port_inventory => inventory_port
		)
		notifies :restart, "service[inventory-#{i}]"
	end
	template "#{inventory_config_dir}/ctx-jdo.conf" do
		content "ctx-jdo.conf.erb"
		variables(
			:db_host => node['inventory']['db_host'],
			:db_schema => node['inventory']['db_schema'],
			:db_port => node['inventory']['db_port'],
			:db_username => node['inventory']['db_username'],
			:db_password => node['inventory']['db_password']
		)
		notifies :restart, "service[inventory-#{i}]"
	end
	template "#{inventory_config_dir}/service-installment.conf" do
		content "service-installment.conf.erb"
		variables(
			:installment_host => host_installment,
			:installment_port => port_installment
		)
		notifies :restart, "service[inventory-#{i}]"
	end
	template "#{inventory_config_dir}/ctx-indexing.conf" do
		content "ctx-indexing.conf.erb"
		variables(
			:host_solr => node['ipaddress']
		)
		notifies :restart, "service[inventory-#{i}]"
	end


	# make *.sh executable
	execute "chmod-add-executable" do
		cwd "#{app_dir}/bin"
		command "chmod u+x *.sh; chmod u+x #{artifact_id}"
	end


	link node['inventory'][i]['home'] do
		to app_dir
	end



	service "inventory-#{i}" do
		provider Chef::Provider::Service::Upstart
		supports :status => true, :restart => true, :reload => true
		action :start
	end
end
