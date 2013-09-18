
nginx_dir = node['nginx']['dir']
servers = search(:node, 'roles:mca')


directory node['admin_vs']['location_dir'] do
	recursive true
end
if (servers.length > 0)
	template "#{nginx_dir}/sites-enabled/admin-vs" do
		content "admin-vs.erb"
		variables(
			:servers => servers
		)
		notifies :reload, "service[nginx]"
	end
end

