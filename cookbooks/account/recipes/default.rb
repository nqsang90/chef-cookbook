
# Cookbook Name:: account
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute


package_server = node['deployment_server']['url']
artifact_id = "account"
version = node['account']['version']
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
app_temp_dir = "/tmp/#{artifact_id}"
app_dir = "#{node['account']['deploy_dir']}/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = node['account']['db_name']
deploy_type = "install"
host_active_mq = node['active_mq']['host']
host_xsecd = "10.120.18.99"

#prepare webapps folder
directory "#{app_dir}/#{version}" do
  recursive true
end


# download
remote_file "#{app_dir}/#{version}/#{package}" do
  source "#{node['account']['url']}"
	checksum "f04937ec3b6b94fd1517d397212fddc572453de146d20c801147c20760e1628e"
end

# extract package
execute "extract-package" do
	cwd app_dir+'/'+version
	command "unzip -x #{package}"
	not_if {File.exists?("#{version_dir}/#{artifact_id}")}
end

# run mysql script
execute "mysql-create-authen" do
	command "mysql -u #{db_user} -p#{db_password} < #{app_dir}/#{version}/script/authentication.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'authentication'\" | grep authentication"
end


# config the package

config_dir = "#{app_dir}/#{version}/#{artifact_id}/WEB-INF"
execute "dos2unix" do
	command "dos2unix #{config_dir}/*.conf"
end

template "#{config_dir}/account-jdo.conf" do
	content "account-jdo.conf.erb"
	variables(
		:db_name => db_user,
		:db_password => db_password
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/active_mq-jndi.conf" do
	content "active_mq-jndi.conf.erb"
	variables(
		:host_active_mq => host_active_mq
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/active_mq_sender.conf" do
	content "active_mq_sender.conf.erb"
	variables(
		:host_active_mq => host_active_mq
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/authentication-module.conf" do
	content "authentication-module.erb"
	variables(
		:host_account => node['ipaddress']
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/trusted-domains.xml" do
	content "trusted-domains.xml.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/config.properties" do
	content "config.properties.erb"
	variables(
		:host_xsecd => host_xsecd
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/oauth.conf" do
	content "oauth.conf.erb"
	variables(
		:host_account => node['ipaddress']
	)
	notifies :restart, "service[tomcat6]"
end
template "#{config_dir}/keytrust.properties" do
	content "keytrust.properties.erb"
	notifies :restart, "service[tomcat6]"
end

#stop server
#service "tomcat6" do
#	action :stop
#end
# link
link "#{tomcat_dir}/webapps/#{artifact_id}" do
	to	"#{app_dir}/#{version}/#{artifact_id}"
	notifies :restart, "service[tomcat6]"
end
# start tomcat server
service "tomcat6" do
	supports :restart => true
	action :enable
end


