


nginx_dir = node['nginx']['dir']

servers = search(:node, 'roles:mca')

directory node['mca_443']['location_dir'] do
	recursive true
end

if servers.length > 0
	template "#{nginx_dir}/sites-enabled/mca-443" do
		content "mca-443.erb"
		variables(
			:servers => servers
		)
		notifies :reload, "service[nginx]"
	end
end
