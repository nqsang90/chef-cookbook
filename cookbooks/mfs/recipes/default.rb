#
# Cookbook Name:: mfs
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
include_recipe "mbv-search"

class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

xacct = do_search('xacct', 'default', 'xacct')
	host_xacct = xacct['ipaddress']
	port_xacct = xacct['port']
account = do_search('account', 'default', 'account')
	host_account = account['ipaddress']
	port_account = account['port']
mca = do_search('mca', 'default', 'mca')
	host_mca = mca['ipaddress']
	port_mca = mca['port']
host_xsecd = "10.120.18.99"

if (port_xacct == '' || port_account == '' || port_mca == '')
	return
end

for i in 0..node['mfs']['num_instance']-1
	package_server = node['deployment_server']['url']
	artifact_id = "mfs"
	version = node['mfs'][i]['version']
	package = artifact_id + "-" + version + ".zip"
	version_dir = "#{node['mfs']['deploy_dir']}/#{artifact_id}/#{version}"
	app_dir = "#{version_dir}/#{artifact_id}"

	app_link_dir = "/opt/daemons/bin"
	db_user = "root"
	db_password = node['mysql']['server_root_password']
	db_name = "mfs"
	deploy_type = "install"
	link_file = "#{app_link_dir}/mfs.sh"
	mfs_port = node['mfs'][i]['port']
	
	mca_structure "create-mfs-structure" do
		mod_name 	artifact_id
		dest		app_dir
	end

	mod_dir = "#{app_dir}/modules"

	# download
	remote_file "#{mod_dir}/#{package}" do
		source "#{node['mfs'][i]['url']}"
		checksum node['mfs'][i]['checksum']
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
		notifies :restart, "service[mfs-#{i}]"
	end
	execute "mysql-patch-mfs" do
		command "mysql -u #{db_user} -p#{db_password} #{db_name} < #{mod_dir}/mfs/sql/db-patch-0.2.12.sql"
		not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"use mfs; show columns from scheduled_event;\" | grep schedule_id"
		notifies :restart, "service[mfs-#{i}]"
	end

	# config embedded-webapp
	ew_config_dir = "#{mod_dir}/embedded-webapp"
	template "#{ew_config_dir}/embedded-webapp.conf" do
		content "embedded-webapp/embedded-webapp.conf.erb"
		source "embedded-webapp/embedded-webapp.conf.erb"
		variables(
			:service_port => mfs_port,
			:production => false
		)
		notifies :restart, "service[mfs-#{i}]"
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
		notifies :restart, "service[mfs-#{i}]"
	end

	template "#{mfs_config_dir}/service-mca.conf" do
		content "service-mca.conf.erb"
		variables(
			:host_mca => host_mca,
			:port_mca => port_mca
		)
		notifies :restart, "service[mfs-#{i}]"
	end

	template "#{mfs_config_dir}/service.conf" do
		content "service.conf.erb"
		variables(
			:host_xacct => host_xacct,
			:port_xacct => port_xacct,
			:host_account => host_account,
			:port_account => port_account
		)
		notifies :restart, "service[mfs-#{i}]"
	end
	template "#{mfs_config_dir}/service-ac.conf" do
		content "service-ac.conf.erb"
		notifies :restart, "service[mfs-#{i}]"
	end
	template "#{mfs_config_dir}/service-xsecd.conf" do
		content "service-xsecd.conf.erb"
		variables(
			:host_xsecd => host_xsecd
		)
		notifies :restart, "service[mfs-#{i}]"
	end

	# make *.sh executable
	execute "chmod-add-executable" do
		cwd "#{app_dir}/bin"
		command "chmod u+x *.sh"
	end


	# link folder
	link node['mfs'][i]['home'] do
		to app_dir
	end

	include_recipe "mfs::mfs"

	service "mfs-#{i}" do
		provider Chef::Provider::Service::Upstart
		supports :status => true, :restart => true, :reload => true
		action :start
	end
end
