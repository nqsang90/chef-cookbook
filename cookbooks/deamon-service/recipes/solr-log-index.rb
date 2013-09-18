

service_name = 'solr-log-index'
template "/etc/init/#{service_name}.conf" do
  content "simple-service.conf.erb"
  source "simple-service.conf.erb"
  owner "root"
  group "root"
  mode "755"
	variables(
		:service_name => service_name,
		:script_path => "#{node['solr_log_index']['home']}/solr/bin/daemon.sh",
		:java_home => node['java']['java_home']
	)
end

link "/etc/init.d/#{service_name}" do
	to "/etc/init/#{service_name}.conf"
end

