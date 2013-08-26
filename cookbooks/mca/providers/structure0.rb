# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_dir_struture
	end
  end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  @current_resource = Chef::Resource::McaStructure0.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.dest(@new_resource.dest)
  @current_resource.mod_name(@new_resource.mod_name)

  if ::File.exists?("#{@current_resource.dest}/bin")
    @current_resource.exists = true
  end
end


def create_dir_struture
	app_dir = @current_resource.dest
	artifact_id = @current_resource.mod_name
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

	# copy daemonlib
	execute "copy-daemonlib" do
		cwd "#{app_dir}"
		command "cp -fr /opt/daemons/daemonlib/#{node['daemonlib']['version']}/daemonlib/* ."
		not_if {::File.exists?("#{app_dir}/bin")}
	end

	# rename main.properties
	file "#{app_dir}/#{artifact_id}.properties" do
		content "#{app_dir}/main.properties"
		provider Chef::Provider::File::Copy
		action	:nothing
	end
	execute "copy main.pro" do
		command "cp #{app_dir}/main.properties #{app_dir}/#{artifact_id}.properties"
	end

	# edit launch.sh
	execute "edit-launch.sh" do
		cwd "#{app_dir}/bin"
		command "sed -i 's/{SYSTEM_NAME}/#{artifact_id}/g' launch.sh"#; mv launch.sh #{artifact_id}.sh"
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
		not_if {::File.exists?("#{mod_dir}/embedded-webapp")}
	end
	# copy id-generator
	execute "copy-idgen" do
		cwd "#{mod_dir}"
		command "cp -fr /opt/daemons/id-generator/#{node['id_generator']['version']}/id-generator ."
		not_if {::File.exists?("#{mod_dir}/id-generator")}
	end

	# template launch.sh
	template "#{app_dir}/bin/#{artifact_id}.sh" do
		content "launch.sh.erb"
		variables(
			:mod_name => artifact_id
		)
	end
end
