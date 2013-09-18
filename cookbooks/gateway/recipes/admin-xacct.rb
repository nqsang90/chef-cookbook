
include_recipe "gateway::admin-vs"

nginx_dir = node['nginx']['dir']
servers = search(:node, 'recipes:xacct')

if servers.length > 0
	template "#{node['admin_vs']['location_dir']}/admin-xacct" do
	content		"admin-xactt.erb"
	variables(
		:mca_server_group => node['gateway']['mca_server_group'],
		:host_xacct => servers[0]['fqdn'],
		:port_xacct => servers[0]['xacct']['port']
	)
	notifies :reload, "service[nginx]"
	end
end
