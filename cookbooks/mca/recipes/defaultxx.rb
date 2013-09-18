#
# Cookbook Name:: mca
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

mca_port = "8484"
package_server = node['deployment_server']['url']
artifact_id = "mca"
version = "0.2.1"
package = artifact_id + "-" + version + ".zip"
tomcat_dir = node['tomcat']['base']
app_temp_dir = "/tmp/#{artifact_id}"
app_dir = "/opt/daemons/#{artifact_id}"
version_dir = "#{app_dir}/#{version}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "mca"
deploy_type = "install"
link_file = "#{app_link_dir}/mca.sh"
launch_file = "#{version_dir}/#{artifact_id}/bin/#{artifact_id}.sh"

mod_dir = "#{version_dir}/#{artifact_id}/modules"
#config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
mca_config_dir = "#{mod_dir}/mca"

if (File.exists?(link_file) && File.symlink?(link_file) && File.readlink(link_file) == "#{launch_file}" && File.exists?("#{launch_file}"))
	return
end

#prepare webapps folder
directory "#{version_dir}" do
  #owner "root"
  #group "root"
  #mode 00755
  recursive true
  #action :nothing
end
directory app_link_dir do
  #owner "root"
  #group "root"
  #mode 00755
  recursive true
  #action :nothing
end

# download
remote_file "#{version_dir}/#{package}" do
  source "#{package_server}/#{artifact_id}/#{version}/#{package}"
  #mode "0755"
end

# extract package
execute "extract-#{artifact_id}" do
	cwd "#{version_dir}"
	command "unzip -x #{package}"
	not_if {File.exists?("#{version_dir}/#{artifact_id}/bin/#{artifact_id}")}
end

# run mysql script
execute "mysql-run-mca" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mca/script/mca.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'mca'\" | grep mca"
end
#execute "mysql-run-crypto" do
#command "mysql -u #{db_user} -p#{db_password} < #{app_dir}/#{version}/modules/mca/script/crypto.sql"
#not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"use mca; show tables\" | grep x509_certs"
#end
execute "mysql-run-mfs" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mfs/sql/mfs_0.2.0.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'mfs'\" | grep mfs"
end


template "#{ew_config_dir}/embedded-webapp.conf" do
	content "ew/embedded-webapp.conf.erb"
	source "ew/embedded-webapp.conf.erb"
	variables(
		:mca_port => mca_port
	)
end
# config mca


execute "dos2unix" do
	command "dos2unix #{mca_config_dir}/*.conf"
end
template "#{mca_config_dir}/mca-billing.conf" do
	content "mca/mca-billing.conf.erb"
	source "mca/mca-billing.conf.erb"
end

template "#{mca_config_dir}/mca-services.conf" do
	content "mca/mca-services.conf.erb"
	source "mca/mca-services.conf.erb"
end
template "#{mca_config_dir}/service-ac.conf" do
	content "mca/service-ac.conf.erb"
	source "mca/service-ac.conf.erb"
end
template "#{mca_config_dir}/mca-report.conf" do
	content "mca/mca-report.conf.erb"
	source "mca/mca-report.conf.erb"
end
template "#{mca_config_dir}/service-account.conf" do
	content "mca/service-account.conf.erb"
	source "mca/service-account.conf.erb"
end

template "#{mca_config_dir}/service-xacct.conf" do
	content "mca/service-xacct.conf.erb"
	source "mca/service-xacct.conf.erb"
end
template "#{mca_config_dir}/service-xsecd.conf" do
	content "mca/service-xsecd.conf.erb"
	source "mca/service-xsecd.conf.erb"
end
template "#{mca_config_dir}/mca.xml" do
	content "mca/mca.xml.erb"
	source "mca/mca.xml.erb"
end

# config mfs

mfs_config_dir = "#{mod_dir}/mfs"
execute "dos2unix" do
	command "dos2unix #{mfs_config_dir}/*.conf"
end
template "#{mca_config_dir}/service-mca.conf" do
	content "mfs/service-mca.conf.erb"
	source "mfs/service-mca.conf.erb"
end

template "#{mca_config_dir}/service.conf" do
	content "mfs/service.conf.erb"
	source "mfs/service.conf.erb"
end
template "#{mca_config_dir}/service-ac.conf" do
	content "mfs/service-ac.conf.erb"
	source "mfs/service-ac.conf.erb"
end
template "#{mca_config_dir}/service-xsecd.conf" do
	content "mfs/service-xsecd.conf.erb"
	source "mfs/service-xsecd.conf.erb"
end

# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{version_dir}/#{artifact_id}/bin"
	command "chmod u+x *.sh #{artifact_id}"
end

# stop service
execute "stop-service" do
	command "#{link_file} stop"
	only_if {File.exists?("#{version_dir}/#{artifact_id}/bin/mca.pid")}
end
# link
link link_file do
	to	"#{launch_file}"
end
# start service
execute "start-service" do
	command "#{link_file} start"
	not_if {File.exists?("#{version_dir}/#{artifact_id}/bin/mca.pid")}
end

