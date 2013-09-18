

nginx_dir = node['nginx']['dir']
servers = search(:node, 'recipes:account')

if servers.length > 0
	
end
