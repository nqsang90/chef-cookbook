
# Cookbook Name:: account
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute


#package "maven"
#package "tomcat7"

package_server = node['deployment_server']['url']
checkout_dir = "/opt/account"
artifact_id = "account"
version = "0.3.6"
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
app_temp_dir = "/tmp/#{artifact_id}"
app_dir = "/opt/webapps/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "authentication"
deploy_type = "install"

if (File.exists?("#{tomcat_dir}/webapps/#{artifact_id}") && File.symlink?("#{tomcat_dir}/webapps/#{artifact_id}") && File.readlink("#{tomcat_dir}/webapps/#{artifact_id}") == "#{app_dir}/#{version}/#{artifact_id}" && File.exists?(app_dir+'/'+version))
	#return
end

#prepare webapps folder
directory "#{app_dir}/#{version}" do
  #owner "root"
  #group "root"
  #mode 00755
  recursive true
  #action :nothing
end

=begin
#prepare app temp dir
directory app_temp_dir do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# download .war from package server
remote_file "/#{app_temp_dir}/#{package}" do
  source "#{package_server}/#{package}"
  mode "0755"
end

# extract package
execute "extract-package" do
	cwd app_temp_dir
	command "unzip -x #{package}"
end

#what is the version being deployed?

#prepare app dir
p_app_dir = directory app_dir do
  owner "root"
  group "root"
  mode 00755
  action :nothing
end
#prepare app/version dir
p_app_v_dir = directory app_dir+'/'+version do
  owner "root"
  group "root"
  mode 00755
  action :nothing
end
=end

# download
remote_file "#{app_dir}/#{version}/#{package}" do
  source "#{package_server}/#{artifact_id}/#{version}/#{package}"
  #mode "0755"
  #action :nothing
end

# extract package
execute "extract-package" do
	cwd app_dir+'/'+version
	command "unzip -x #{package}"
	not_if {File.exists?("#{version_dir}/#{artifact_id}")}
	#action :nothing
end
#p_webapp.run_action(:create)
#p_app_dir.run_action(:create)
#p_app_v_dir.run_action(:create)
#p_download.run_action(:create)
#p_extract.run_action(:run)

# run mysql script
execute "mysql-create-authen" do
	command "mysql -u #{db_user} -p#{db_password} < #{app_dir}/#{version}/script/authentication.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'authentication'\" | grep authentication"
end


# config the package

config_dir = "#{app_dir}/#{version}/#{artifact_id}/WEB-INF"
#execute "dos2unix" do
	#command "dos2unix #{config_dir}/*.conf"
#	user "root"
	#group "root"
#end
template "#{config_dir}/config.properties" do
	content "config.properties.erb"
	variables(
		:development => true
	)
end

template "#{config_dir}/account-jdo.conf" do
	content "account-jdo.conf.erb"
	variables(
		:db_name => db_user,
		:db_password => db_password
	)
end
template "#{config_dir}/active_mq-jndi.conf" do
	content "active_mq-jndi.conf.erb"
end
template "#{config_dir}/active_mq_sender.conf" do
	content "active_mq_sender.conf.erb"
end
template "#{config_dir}/authentication-module.conf" do
	content "authentication-module.erb"
end
template "#{config_dir}/trusted-domains.xml" do
	content "trusted-domains.xml.erb"
	variables(
		:ipaddress => node['ipaddress']
	)
end
#stop server
service "tomcat6" do
	action :stop
end
# link
link "#{tomcat_dir}/webapps/#{artifact_id}" do
	to	"#{app_dir}/#{version}/#{artifact_id}"
end
# start tomcat server
service "tomcat6" do
	action :start
end



