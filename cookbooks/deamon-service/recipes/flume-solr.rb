
service_name = 'flume-solr'
template "/etc/init/#{service_name}.conf" do
  content "solr-service.conf.erb"
  source "solr-service.conf.erb"
  owner "root"
  group "root"
  mode "755"
	variables(
		:service_name => service_name,
		:script_path => "#{node['flume_solr']['home']}/bin/daemon.sh",
		:java_home => node['java']['java_home']
	)
end

link "/etc/init.d/#{service_name}" do
	to "/etc/init/#{service_name}.conf"
end

