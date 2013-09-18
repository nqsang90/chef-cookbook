
include_recipe "gateway::admin-vs"

nginx_dir = node['nginx']['dir']
servers = search(:node, 'recipes:mca')

if servers.length > 0
	template "#{node['admin_vs']['location_dir']}/admin-mca" do
	content		"admin-mca.erb"
	variables(
		:mca_server_group => node['gateway']['mca_server_group'],
		:host_mca => servers[0]['fqdn'],
		:port_mca => servers[0]['mca']['port']
	)
	notifies :reload, "service[nginx]"
	end
end
