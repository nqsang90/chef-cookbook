
for i in 0..node['mbv_tomcat']['num_instance']-1
	service_name = "ntomcat-#{i}"
	template "/etc/init/#{service_name}.conf" do
	  content "simple-service.conf.erb"
	  source "simple-service.conf.erb"
	  owner "root"
	  group "root"
	  mode "755"
		variables(
			:service_name => service_name,
			:script_path => "#{node['mbv_tomcat'][i]['home']}/bin/catalina.sh",
			:java_home => node['java']['java_home']
		)
	end

	link "/etc/init.d/#{service_name}" do
		to "/etc/init/#{service_name}.conf"
	end
end
