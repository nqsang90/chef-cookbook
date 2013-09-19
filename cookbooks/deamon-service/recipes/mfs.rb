for i in 0..node['mfs']['num_instance']-1
	service_name = "mfs-#{i}"
	template "/etc/init/#{service_name}.conf" do
	  content "upstart-service.conf.erb"
	  source "upstart-service.conf.erb"
	  owner "root"
	  group "root"
	  mode "755"
		variables(
			:service_name => service_name,
			:search_string => "#{service_name}/libs/",
			:service_home => node['mfs'][i]['home'],
			:java_home => node['java']['java_home'],
			:depend_service => "started mca",
			:basename => 'mfs',
			:service_port => node['mfs'][i]['port']
		)
	end

	link "/etc/init.d/#{service_name}" do
		to "/etc/init/#{service_name}.conf"
	end
end