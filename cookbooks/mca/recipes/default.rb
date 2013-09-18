#
# Cookbook Name:: mca
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

host_active_mq = node['active_mq']['host']

xacct = do_search('xacct', 'default', 'xacct')
        host_xacct = xacct['ipaddress']
        port_xacct = xacct['port']

host_xsecd = "10.120.18.99"

account = do_search('account', 'default', 'account')
        host_account = account['ipaddress']
        port_account = account['port']

if (port_xacct == '' || port_account == '')
	return
end

for i in 0..node['mca']['num_instance']-1
	package_server = node['deployment_server']['url']
	artifact_id = "mca"
	version = node['mca'][i]['version']
	package = "#{artifact_id}-#{version}.zip"
	version_dir = "#{node['mca']['deploy_dir']}/#{artifact_id}/#{version}"
	app_dir = "#{version_dir}/#{artifact_id}"
	app_link_dir = "/opt/daemons/bin"
	db_user = "root"
	db_password = node['mysql']['server_root_password']
	db_name = "mca"
	deploy_type = "install"
	link_file = "#{app_link_dir}/mca.sh"
	launch_file = "#{version_dir}/#{artifact_id}/bin/#{artifact_id}.sh"
	mod_dir = "#{app_dir}/modules"
	mca_port = node['mca'][i]['port']
	
	mca_structure "create-mca-structure" do
		mod_name 	artifact_id
		dest		app_dir
	end

# download
	remote_file "#{mod_dir}/#{package}" do
		source "#{node['mca'][i]['url']}"
		checksum node['mca'][i]['checksum']
	end

# extract package
	execute "extract-#{artifact_id}" do
		cwd "#{mod_dir}"
		command "unzip -x #{package}"
		not_if {File.exists?("#{mod_dir}/#{artifact_id}")}
	end

# run mysql script
	execute "mysql-run-mca" do
		command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mca/script/mca.sql"
		not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'mca'\" | grep mca"
	end
#execute "mysql-run-crypto" do
	#command "mysql -u #{db_user} -p#{db_password} < #{version_dir}/modules/mca/script/crypto.sql"
#	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"use mca; show tables\" | grep x509_certs"
#end

# config embedded-webapp
	ew_config_dir = "#{mod_dir}/embedded-webapp"
	template "#{ew_config_dir}/embedded-webapp.conf" do
		content "embedded-webapp/embedded-webapp.conf.erb"
		source "embedded-webapp/embedded-webapp.conf.erb"
		variables(
			:mca_port => mca_port,
			:production => false
		)
	    notifies :restart, "service[mca-#{i}]"
	end

# config mca
	mca_config_dir = "#{mod_dir}/mca"
	execute "dos2unix" do
		command "dos2unix #{mca_config_dir}/*.conf"
	end

	template "#{mca_config_dir}/mca-billing.conf" do
		content "mca/mca-billing.conf.erb"
		source "mca/mca-billing.conf.erb"
		notifies :restart, "service[mca-#{i}]"
	end

	template "#{mca_config_dir}/mca-services.conf" do
		content "mca/mca-services.conf.erb"
		source "mca/mca-services.conf.erb"
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{mca_config_dir}/service-ac.conf" do
		content "mca/service-ac.conf.erb"
		source "mca/service-ac.conf.erb"
		variables(
			:host_active_mq => host_active_mq
		)
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{mca_config_dir}/mca-report.conf" do
		content "mca/mca-report.conf.erb"
		source "mca/mca-report.conf.erb"
		notifies :restart, "service[mca-#{i}]"
	end
	gateway_account = "mca-gateway.vn"
	template "#{mca_config_dir}/service-account.conf" do
		content "mca/service-account.conf.erb"
		source "mca/service-account.conf.erb"
		variables(
			:gateway_account => gateway_account,
			:host_account => host_account,
			:port_account => port_account
		)
		notifies :restart, "service[mca-#{i}]"
	end

	template "#{mca_config_dir}/service-xacct.conf" do
		content "mca/service-xacct.conf.erb"
		source "mca/service-xacct.conf.erb"
		variables(
			:host_xacct => host_xacct,
			:port_xacct => port_xacct
		)
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{mca_config_dir}/service-xsecd.conf" do
		content "mca/service-xsecd.conf.erb"
		source "mca/service-xsecd.conf.erb"
		variables(
			:host_xsecd => host_xsecd
		)
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{mca_config_dir}/mca.xml" do
		content "mca/mca.xml.erb"
		source "mca/mca.xml.erb"
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{mca_config_dir}/active_mq-jndi.conf" do
		content "mca/active_mq-jndi.conf.erb"
		source "mca/active_mq-jndi.conf.erb"
		variables(
			:host_active_mq => host_active_mq
		)
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{app_dir}/config/log4j2.xml" do
		content "log4j2.xml.erb"
		notifies :restart, "service[mca-#{i}]"
	end
	template "#{app_dir}/config/commons-logging.properties" do
		content "commons-logging.properties.erb"
		notifies :restart, "service[mca-#{i}]"
	end

	# make *.sh executable
	execute "chmod-add-executable" do
		cwd "#{app_dir}/bin"
		command "chmod u+x *.sh; chmod u+x #{artifact_id}"
	end

	link node['mca'][i]['home'] do
		to app_dir
	end

	include_recipe "deamon-service::mca"

	service "mca-#{i}" do
		provider Chef::Provider::Service::Upstart
		supports :status => true, :restart => true, :reload => true
		action :start
	end
end
