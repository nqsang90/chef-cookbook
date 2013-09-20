
include_recipe "gateway::admin-vs"

nginx_dir = node['nginx']['dir']
mfs = multi_search('mfs', 'default', 'mfs')

if mfs['num_instance'] > 0
	template "#{node['admin_vs']['location_dir']}/admin-mfs" do
	content		"admin-mca.erb"
	variables(
		:host_mfs => mfs['ipaddress'],
		:port_mfs => mfs[0]['port']
	)
	notifies :reload, "service[nginx]"
	end
end
