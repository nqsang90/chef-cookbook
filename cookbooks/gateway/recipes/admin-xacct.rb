
include_recipe "gateway::admin-vs"

nginx_dir = node['nginx']['dir']
xacct = multi_search('xacct', 'default','xacct')

if xacct['num_instance'] > 0
	template "#{node['admin_vs']['location_dir']}/admin-xacct" do
	content		"admin-xactt.erb"
	variables(
		:host_xacct => xacct['ipaddress'],
		:port_xacct => xacct[0]['port']
	)
	notifies :reload, "service[nginx]"
	end
end
