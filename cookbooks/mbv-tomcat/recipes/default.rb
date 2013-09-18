#
# Cookbook Name:: mbv-tomcat
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
include_recipe "java"


for i in 0..node['mbv_tomcat']['num_instance']-1

	log i
	# download
	remote_file "#{node["mbv_tomcat"][i]["home"]}.tar.gz" do
		source node['mbv_tomcat']['url']
		checksum node['mbv_tomcat']['checksum']
	end

	# extract package
	execute "extract-tomcat-#{i}" do
		cwd node['mbv_tomcat']['deploy_dir']
		command "tar xvzf #{node["mbv_tomcat"][i]["home"]}.tar.gz"
		not_if {File.exists?(node["mbv_tomcat"][i]["home"])}
	end
	execute "rename-tomcat-#{i}" do
		cwd node['mbv_tomcat']['deploy_dir']
		command "mv #{node["mbv_tomcat"]["name"]} #{node["mbv_tomcat"][i]["home"]}"
		not_if {File.exists?(node["mbv_tomcat"][i]["home"])}
	end
	template "#{node["mbv_tomcat"][i]["home"]}/conf/server.xml" do
		content "server.xml.erb"
		variables(
			:shutdown_port => node['mbv_tomcat']['shutdown_ports'][i],
			:connector_port => node['mbv_tomcat']['connector_ports'][i],
			:ajp_connector_port => node['mbv_tomcat']['ajp_connector_ports'][i]
		)
	end
	include_recipe "mbv-tomcat::n-tomcat"

	service "ntomcat-#{i}" do
		provider Chef::Provider::Service::Upstart
		supports :status => true, :restart => true, :reload => true
		action :start
	end
end
