


default['admin_vs']['log_dir'] = node['nginx']['log_dir']
default['admin_vs']['location_dir'] = "#{node['nginx']['dir']}/admin-location"
default['admin_vs']['port'] = 9090

