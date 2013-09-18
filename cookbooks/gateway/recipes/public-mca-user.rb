
include_recipe "gateway::mca-443"

class ::Chef::Recipe
	include ::Mbv::McaWeb::Search
end

nginx_dir = node['nginx']['dir']
host = multi_search('mcaweb', 'default', 'user')

if host['num_instance'] > 0
	template "#{node['mca_443']['location_dir']}/public-mca-user" do
		content		"public-mca-user.erb"
		variables(
			:host => host
		)
	notifies :reload, "service[nginx]"
	end
end
