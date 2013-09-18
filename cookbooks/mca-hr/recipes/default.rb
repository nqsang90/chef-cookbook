#
# Cookbook Name:: mca-hr
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mbv-tomcat"


class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

host_active_mq = node['active_mq']['host']
host_xsecd = "10.120.18.99"


user = do_search('mcaweb', 'default', 'user')
host_user = user['ipaddress']
port_user = user['port']

account = do_search('account', 'default', 'account')
host_account = account['ipaddress'] 
port_account = account['port']

mca = do_search('mca', 'default', 'mca')
host_mca = mca['ipaddress']
port_mca = mca['port']

xacct = do_search('xacct', 'default', 'xacct')
host_xacct = xacct['ipaddress']
port_xacct = xacct['port']

gateway_account = "mca-gateway.vn"

if (port_user == '' || port_account == '' || port_mca == '' || port_xacct == '')
	return
end

for i in 0..node['account']['num_instance']-1
	package_server = node['deployment_server']['url']
	artifact_id = "mca-hr"
	version = node['mca_hr'][i]['version']
	package = artifact_id + "-" + version + ".zip"
	tomcat_dir = node['mbv_tomcat'][i]['home']
	app_dir = "#{node['mca_hr']['deploy_dir']}/#{artifact_id}"
	version_dir = "#{app_dir}/#{version}"
	dest_link = "hr"
	link_path = "#{tomcat_dir}/webapps/#{dest_link}"

	#prepare webapps folder
	directory "#{app_dir}/#{version}" do
	  recursive true
	end


	# download
	remote_file "#{version_dir}/#{package}" do
	 	source "#{node['mca_hr'][i]['url']}"
		checksum node['mca_hr'][i]['checksum']
	end

	# extract package
	execute "extract-package" do
		cwd app_dir+'/'+version
		command "unzip -x #{package}"
		not_if {File.exists?("#{version_dir}/#{artifact_id}")}
	end


	# config the package

	config_dir = "#{version_dir}/#{artifact_id}/WEB-INF"
	execute "dos2unix" do
		command "dos2unix #{config_dir}/*.conf"
	end

	template "#{config_dir}/ctx-service.conf" do
		content "ctx-service.conf.erb"
		variables(
			:host_user => host_user
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end
	template "#{config_dir}/service-account.conf" do
		content "service-account.conf.erb"
		variables(
			:gateway_account => gateway_account,
			:host_account => host_account,
			:port_account => port_account
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end
	template "#{config_dir}/service-mca.conf" do
		content "service-mca.conf.erb"
		variables(
			:host_mca => host_mca,
			:port_mca => port_mca
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end
	template "#{config_dir}/service-memcached.conf" do
		content "service-memcached.conf.erb"
		notifies :restart, "service[ntomcat-#{i}]"
	end
	template "#{config_dir}/service-xacct.conf" do
		content "service-xacct.conf.erb"
		variables(
			:host_xacct => host_xacct,
			:port_xacct => port_xacct
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end

	link link_path do
		to	"#{app_dir}/#{version}/#{artifact_id}"
		notifies :restart, "service[ntomcat-#{i}]"
	end
end



