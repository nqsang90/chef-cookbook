
include_recipe "gateway::mca-443"

nginx_dir = node['nginx']['dir']
hr = multi_search('mca-hr', 'default', 'mca_hr')

if hr['num_instance'] > 0
	template "#{node['mca_443']['location_dir']}/public-mca-hr" do
		content		"public-mca-hr.erb"
		variables(
			:host_hr => hr['ipaddress'],
			:port_hr => hr[0]['port']
		)
	notifies :reload, "service[nginx]"
	end
end
