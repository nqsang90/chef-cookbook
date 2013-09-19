

nginx_dir = node['nginx']['dir']
account = multi_search('account', 'default', 'account')

if account['num_instance'] > 0
	template "#{node['admin_vs']['location_dir']}/account" do
	content		"account.erb"
	variables(
		:host_mfs => account['ipaddress'],
		:port_mfs => account[0]['port']
	)
	notifies :reload, "service[nginx]"
	end
end
