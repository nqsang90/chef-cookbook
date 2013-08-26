#
# Cookbook Name:: mca
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "daemonlib::default"
include_recipe "commons-daemon::default"

package_server = node['deployment_server']['url']
artifact_id = "mca"
version = "0.3.13-beta1"
package = "#{artifact_id}-#{version}.zip"
version_dir = "/opt/daemons/#{artifact_id}/#{version}"
app_dir = "#{version_dir}/#{artifact_id}"
app_link_dir = "/opt/daemons/bin"
db_user = "root"
db_password = node['mysql']['server_root_password']
db_name = "mca"
deploy_type = "install"
link_file = "#{app_link_dir}/mca.sh"
mca_port = 8484

if (File.exists?(link_file) && File.symlink?(link_file) && File.readlink(link_file) == "#{app_dir}/bin/mca.sh" && File.exists?("#{app_dir}"))
	#return
end

# install YAML
cpan_client 'YAML' do
    action 'install'
    install_type 'cpan_module'
    user 'root'
    group 'root'
end
# install URI::Escape
cpan_client 'URI::Escape' do
    action 'install'
    install_type 'cpan_module'
    user 'root'
    group 'root'
end


#prepare webapps folder
directory "#{app_dir}" do
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

# copy daemonlib
execute "copy-daemonlib" do
	cwd "#{app_dir}"
	command "cp -fr /opt/daemons/daemonlib/#{node['daemonlib']['version']}/daemonlib/* ."
	not_if {File.exists?("#{app_dir}/bin")}
end

# rename main.properties
file "#{app_dir}/#{artifact_id}.properties" do
	content "#{app_dir}/main.properties"
	provider Chef::Provider::File::Copy
	action	:nothing
end
execute "copy main.pro" do
	command "mv #{app_dir}/main.properties #{app_dir}/#{artifact_id}.properties"
end

# edit launch.sh
execute "edit-launch.sh" do
	command "sed -i 's/{SYSTEM_NAME}/#{artifact_id}/g' #{app_dir}/bin/launch.sh"
end

# copy to templates
file "/var/chef/cache/cookbooks/#{artifact_id}/templates/default/#{artifact_id}.sh.erb" do
	content "#{app_dir}/bin/launch.sh"
	provider Chef::Provider::File::Copy
end

# copy commons-daemon.jar
commons_daemon = "/opt/daemons/commons-daemon/#{node['commons_daemon']['version']}/commons-daemon"

file "#{app_dir}/bin/commons-daemon.jar" do
	content "#{commons_daemon}/commons-daemon.jar"
	provider Chef::Provider::File::Copy
	action	:nothing
end
execute "copy commons-daemon" do
	command "cp #{commons_daemon}/commons-daemon.jar #{app_dir}/bin/commons-daemon.jar"
end


# copy jsvc
file "#{app_dir}/bin/#{artifact_id}" do
	content "#{commons_daemon}/bin/jsvc-src/jsvc"
	provider Chef::Provider::File::Copy
	action	:nothing
end
execute "copy jsvc file" do
	command "cp #{commons_daemon}/bin/jsvc-src/jsvc	 #{app_dir}/bin/#{artifact_id}"
end

# prepare modules dir
mod_dir = "#{app_dir}/modules"
directory "#{mod_dir}" do
  recursive true
end
directory "#{app_dir}/log" do
  recursive true
end


# copy embedded-webapp
execute "copy-ew" do
	cwd "#{mod_dir}"
	command "cp -fr /opt/daemons/embedded-webapp/#{node['embedded_webapp']['version']}/embedded-webapp ."
	not_if {File.exists?("#{mod_dir}/embedded-webapp")}
end
# copy id-generator
execute "copy-idgen" do
	cwd "#{mod_dir}"
	command "cp -fr /opt/daemons/id-generator/#{node['id_generator']['version']}/id-generator ."
	not_if {File.exists?("#{mod_dir}/id-generator")}
end

# download
remote_file "#{mod_dir}/#{package}" do
  source "#{package_server}/#{artifact_id}/#{version}/#{package}"
  #mode "0755"
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
#not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"use mca; show tables\" | grep x509_certs"
#end
execute "mysql-run-mfs" do
	command "mysql -u #{db_user} -p#{db_password} < #{mod_dir}/mfs/sql/mfs_0.2.0.sql"
	not_if "mysql -u #{db_user} -p#{db_password} --silent --skip-column-names --execute=\"show databases like 'mfs'\" | grep mfs"
end


# config embedded-webapp
ew_config_dir = "#{mod_dir}/embedded-webapp"
template "#{ew_config_dir}/embedded-webapp.conf" do
	content "embedded-webapp/embedded-webapp.conf.erb"
	source "embedded-webapp/embedded-webapp.conf.erb"
	variables(
		:mca_port => mca_port,
		:production => false,
	)
end

# config mca

mca_config_dir = "#{mod_dir}/mca"
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
template "#{mfs_config_dir}/service-mca.conf" do
	content "mfs/service-mca.conf.erb"
	source "mfs/service-mca.conf.erb"
end

template "#{mfs_config_dir}/service.conf" do
	content "mfs/service.conf.erb"
	source "mfs/service.conf.erb"
end
template "#{mfs_config_dir}/service-ac.conf" do
	content "mfs/service-ac.conf.erb"
	source "mfs/service-ac.conf.erb"
end
template "#{mfs_config_dir}/service-xsecd.conf" do
	content "mfs/service-xsecd.conf.erb"
	source "mfs/service-xsecd.conf.erb"
end

# make *.sh executable
execute "chmod-add-executable" do
	cwd "#{app_dir}/bin"
	command "chmod u+x *.sh; chmod u+x #{artifact_id}"
end

# stop service
execute "stop-service" do
	command "#{link_file} stop"
	only_if {::File.exists?(link_file)}
end
# link
link link_file do
	to	"#{app_dir}/bin/mca.sh"
end
# start service
execute "start-service" do
	command "#{link_file} start"
	#not_if "ps -ef | grep mca/ | grep -v 'grep'"
end

