
include_recipe "gateway::admin-vs"

nginx_dir = node['nginx']['dir']
servers = search(:node, 'recipes:installment')

if servers.length > 0
	template "#{node['admin_vs']['location_dir']}/admin-installment" do
		content		"admin-installment.erb"
		variables(
			:host_installment => servers[0]['ipaddress'],
			:port_installment => servers[0]['installment']['port']
		)
	notifies :reload, "service[nginx]"
	end
end
