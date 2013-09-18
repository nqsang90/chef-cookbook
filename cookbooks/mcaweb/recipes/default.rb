#
# Cookbook Name:: mcaweb
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mbv-tomcat"
include_recipe "mbv-search"

class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

xacct = do_search('xacct', 'default', 'xacct')
host_xacct = xacct['ipaddress']
port_xacct = xacct['port']

inv = do_search('inventory', 'default', 'inventory')
host_inv = inv['ipaddress']
port_inv = inv['port']

order = do_search('order-process', 'default', 'order_process')
host_order = order['ipaddress']
port_order = order['port']

installment = do_search('installment', 'default', 'installment')
host_installment = installment['ipaddress']
port_installment = installment['port']

mfs = do_search('mfs', 'default', 'mfs')
host_mfs = mfs['ipaddress']
port_mfs = mfs['port']

mca = do_search('mca', 'default', 'mca')
host_mca = mca['ipaddress']
port_mca = mca['port']

account = do_search('account', 'default', 'account')
host_account = account['ipaddress']
port_account = account['port']

if (port_xacct == '' || port_inv == '' || port_order == '' || port_installment == '' || port_mfs == '' || port_mca == '' || port_account == '')
	return
end

for i in 0..node['user']['num_instance']-1
	package_server = node['deployment_server']['url']
	artifact_id = "mcaweb"
	dest_link = "user"
	version = node['user'][i]['version']
	package = artifact_id + "-" + version + ".zip"
	tomcat_dir = node['mbv_tomcat'][i]['home']
	app_dir = "#{node['user']['deploy_dir']}/#{artifact_id}"
	deploy_type = "install"

	link_path = "#{tomcat_dir}/webapps/#{dest_link}"

	#prepare webapps folder
	directory "#{app_dir}/#{version}" do
	  owner "root"
	  group "root"
	  mode 00755
	  recursive true
	end

	# download
	remote_file "#{app_dir}/#{version}/#{package}" do
	  source "#{node['user'][i]['url']}"
		checksum node['user'][i]['checksum']
	  mode "0755"
	end

	# extract package
	execute "extract-mcaweb-#{version}" do
		cwd app_dir+'/'+version
		command "unzip -x #{package}"
		not_if {File.exists?("/opt/mca-system/mcaweb/#{node['user'][i]['version']}/mcaweb")}
	end


	# config the package

	config_dir = "#{app_dir}/#{version}/#{artifact_id}/WEB-INF"
	#execute "dos2unix" do
		#command "dos2unix #{config_dir}/*.conf"
	#	user "root"
		#group "root"
	#end

	gateway_account = "mca-gateway.vn"
	template "#{config_dir}/service-account.conf" do
		content "service-account.conf.erb"
		variables(
			:gateway_account => gateway_account,
			:host_account => host_account,
			:port_account => port_account
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end

	template "#{config_dir}/ctx-mca-user.conf" do
		content "ctx-mca-user.conf.erb"
		variables(
			:host_xacct => host_xacct,
			:port_xacct => port_xacct
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end

	template "#{config_dir}/service-inventory.conf" do
		content "service-inventory.conf.erb"
		variables(
			:host_inv => host_inv,
			:port_inv => port_inv,
			:host_order => host_order,
			:port_order => port_order,
			:host_installment => host_installment,
			:port_installment => port_installment
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
	template "#{config_dir}/service-mfs.conf" do
		content "service-mfs.conf.erb"
		variables(
			:host_mfs => host_mfs,
			:port_mfs => port_mfs
		)
		notifies :restart, "service[ntomcat-#{i}]"
	end
	template "#{config_dir}/service-mbvid.conf" do
		content "service-mbvid.conf.erb"
		variables(
			:host_account => host_account,
			:port_account => port_account
		)
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

	# link
	link link_path do
		to	"#{app_dir}/#{version}/#{artifact_id}"
		notifies :restart, "service[ntomcat-#{i}]"
	end
end

