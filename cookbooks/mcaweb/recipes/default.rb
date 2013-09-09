#
# Cookbook Name:: mcaweb
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#package "maven"
#package "tomcat7"

package_server = node['deployment_server']['url']
artifact_id = "mcaweb"
dest_link = "user"
version = node['user']['version']
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
app_temp_dir = "/tmp/#{artifact_id}"
app_dir = "#{node['user']['deploy_dir']}/#{artifact_id}"
deploy_type = "install"

host_xacct = node['ipaddress']
port_xacct = 8585
host_inv = node['ipaddress']
port_inv = 8181
host_order = host_inv
port_order = 8282
host_installment = host_order
port_installment = 8383
host_mfs = host_order
port_mfs = 8686
host_mca = host_order
port_mca = 8484
host_account = host_order
port_account = 8080

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
  source "#{node['user']['url']}"
	checksum "d9c6ba173462efde90b2d72c68ecf3128aba71b81958f9ca14b4c136141364bc"
  mode "0755"
end

# extract package
execute "extract-package" do
	cwd app_dir+'/'+version
	command "unzip -x #{package}"
	not_if {File.exists?(app_dir+'/'+version+'/'+artifact_id)}
end


# config the package

config_dir = "#{app_dir}/#{version}/#{artifact_id}/WEB-INF"
#execute "dos2unix" do
	#command "dos2unix #{config_dir}/*.conf"
#	user "root"
	#group "root"
#end

template "#{config_dir}/service-account.conf" do
	content "service-account.conf.erb"
	variables(
		:host_account => host_account
	)
end
template "#{config_dir}/ctx-mca-user.conf" do
	content "ctx-mca-user.conf.erb"
end
template "#{config_dir}/ctx-mca-user.conf" do
	content "ctx-mca-user.conf.erb"
	variables(
		:host_xacct => host_xacct,
		:port_xacct => port_xacct
	)
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
end
template "#{config_dir}/service-mca.conf" do
	content "service-mca.conf.erb"
	variables(
		:host_mca => host_mca,
		:port_mca => port_mca
	)
end
template "#{config_dir}/service-mfs.conf" do
	content "service-mfs.conf.erb"
	variables(
		:host_mfs => host_mfs,
		:port_mfs => port_mfs
	)
end
template "#{config_dir}/service-mbvid.conf" do
	content "service-mbvid.conf.erb"
	variables(
		:host_account => host_account,
		:port_account => port_account
	)
end
template "#{config_dir}/service-xacct.conf" do
	content "service-xacct.conf.erb"
	variables(
		:host_xacct => host_xacct,
		:port_xacct => port_xacct
	)
end

#stop server
service "tomcat6" do
	action :stop
end
# link
link link_path do
	to	"#{app_dir}/#{version}/#{artifact_id}"
end
# start tomcat server
service "tomcat6" do
	action :start
end



