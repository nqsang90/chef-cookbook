
include_recipe "gateway::admin-vs"

nginx_dir = node['nginx']['dir']
mca = multi_search('mca', 'default', 'mca')

if mca['num_instance'] > 0
	template "#{node['admin_vs']['location_dir']}/admin-mca" do
	content		"admin-mca.erb"
	variables(
		:host_mca => mca['ipaddress'],
		:port_mca => mca[0]['port']
	)
	notifies :reload, "service[nginx]"
	end
end
