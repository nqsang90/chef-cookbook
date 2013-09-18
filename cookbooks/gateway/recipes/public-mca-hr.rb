
include_recipe "gateway::mca-443"

nginx_dir = node['nginx']['dir']
servers = search(:node, 'recipes:mca-hr')

if servers.length > 0
	template "#{node['mca_443']['location_dir']}/public-mca-hr" do
		content		"public-mca-hr.erb"
		variables(
			:host_hr => servers[0]['ipaddress'],
			:port_hr => servers[0]['mca_hr']['port']
		)
	notifies :reload, "service[nginx]"
	end
end
