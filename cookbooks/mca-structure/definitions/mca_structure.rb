
define :mca_structure, :mod_name => "module", :dest => "/tmp" do
	app_dir = params[:dest]
	artifact_id = params[:mod_name]
	
	#prepare webapps folder
	directory "#{app_dir}" do
	  recursive true
	end

	# copy daemonlib
	execute "copy-daemonlib" do
		cwd "#{app_dir}"
		command "cp -fr #{node['daemonlib']['deploy_dir']}/daemonlib/#{node['daemonlib']['version']}/daemonlib/* ."
		not_if {::File.exists?("#{app_dir}/bin")}
	end

	# rename main.properties
	#file "#{app_dir}/#{artifact_id}.properties" do
	#	content "#{app_dir}/main.properties"
	#	provider Chef::Provider::File::Copy
	#	action	:nothing
	#end
	execute "copy main.pro" do
		command "cp #{app_dir}/main.properties #{app_dir}/#{artifact_id}.properties"
		not_if {::File.exists?("#{app_dir}/#{artifact_id}.properties")}
	end

	# edit launch.sh
	execute "edit-launch.sh" do
		cwd "#{app_dir}/bin"
		command "sed -i 's/{SYSTEM_NAME}/#{artifact_id}/g' launch.sh"#; mv launch.sh #{artifact_id}.sh"
	end

	# copy commons-daemon.jar
	commons_daemon = "#{node['commons_daemon']['deploy_dir']}/commons-daemon/#{node['commons_daemon']['version']}/commons-daemon"

#	file "#{app_dir}/bin/commons-daemon.jar" do
#		content "#{commons_daemon}/commons-daemon.jar"
#		provider Chef::Provider::File::Copy
#		action	:nothing
#	end
	execute "copy commons-daemon" do
		command "cp #{commons_daemon}/commons-daemon.jar #{app_dir}/bin/commons-daemon.jar"
	end


	# copy jsvc
#	file "#{app_dir}/bin/#{artifact_id}" do
#		content "#{commons_daemon}/bin/jsvc-src/jsvc"
#		provider Chef::Provider::File::Copy
#		action	:nothing
#	end
	execute "copy jsvc file" do
		command "cp #{commons_daemon}/bin/jsvc-src/jsvc #{app_dir}/bin/#{artifact_id}"
		not_if {::File.exists?("#{app_dir}/bin/#{artifact_id}")}
	end
	execute "make-jsvc-executable" do
		command "chmod a+x #{app_dir}/bin/#{artifact_id}"
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
		command "cp -fr #{node['embedded_webapp']['deploy_dir']}/embedded-webapp/#{node['embedded_webapp']['version']}/embedded-webapp ."
		not_if {::File.exists?("#{mod_dir}/embedded-webapp")}
	end
	# copy id-generator
	execute "copy-idgen" do
		cwd "#{mod_dir}"
		command "cp -fr #{node['id_generator']['deploy_dir']}/id-generator/#{node['id_generator']['version']}/id-generator ."
		not_if {::File.exists?("#{mod_dir}/id-generator")}
	end

	# template launch.sh
	template "#{app_dir}/bin/#{artifact_id}.sh" do
		content "launch.sh.erb"
		source "launch.sh.erb"
		variables(
			:mod_name => artifact_id
		)
	end
end
