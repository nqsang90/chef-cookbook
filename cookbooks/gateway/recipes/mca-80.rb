

nginx_dir = node['nginx']['dir']

template "#{nginx_dir}/sites-enabled/mca-80" do
	content "mca-80.erb"
end
