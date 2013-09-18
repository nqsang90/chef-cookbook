module McaSearchLibrary
	def do_search(cookbook_name, recipe_name, index)
		servers = search(:node, "recipes::#{cookbook_name}\:\:#{recipe_name}")
		if servers.length > 0
			host[:ipaddress] = servers[0]['ipaddress']
			host[:fqdn] = servers[0]['fqdn']

			if defined? servers[0]['num_instance']
				# not supposed to support service installed on multiple machine. just use the first one found
				num_instance = servers[0]['num_instance']
				chosen = 0
				if (num_instance > 1)
					chosen = servers[0][index]['default']
				end
				host[:port] = servers[0][index][chosen]['port']
			else
				host[:port] = servers[0][index]['port']
			end		
			return host
		end
	end
end
