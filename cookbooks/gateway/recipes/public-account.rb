
include_recipe "gateway::mca-443"
class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

nginx_dir = node['nginx']['dir']
account = multi_search('account', 'default', 'account')

if account['num_instance'] > 0
	template "#{node['mca_443']['location_dir']}/public-account" do
		content		"public-account.erb"
		variables(
			:host_account => account['ipaddress'],
			:port_account => account[0]['port']
		)
	notifies :reload, "service[nginx]"
	end
end
