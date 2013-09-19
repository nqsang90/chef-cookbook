module Mbv
	module McaWeb
		module Search
			def do_search(cookbook_name, recipe_name, index)
				host = {}

				#puts "node #{node['recipes']}"

				if node['recipes'].include? index
					host['ipaddress'] = node['ipaddress']
					host['fqdn'] = node['fqdn']
					unless node[index]['num_instance'].nil?
						default_inst = node[index]['default']
						host['port'] = node[index][default_inst]['port']
					else
						host['port'] = node[index]['port']
					end
				else
					servers = search(:node, "recipes:#{cookbook_name}")
					if servers.length > 0
						host['ipaddress'] = servers[0]['ipaddress']
						host['fqdn'] = servers[0]['fqdn']
						num_instance = servers[0][index]['num_instance']

						puts "hello #{num_instance} #{host['ipaddress']} #{servers[0]['account']}"
						unless (num_instance.nil? || num_instance == "")
							# not supposed to support service installed on multiple machines. just use the first one found
							puts "#{cookbook_name} multiple #{num_instance} instance"
							chosen = 0
							if (num_instance > 1)
								chosen = servers[0][index]['default']
							end
							host['port'] = servers[0][index]["#{chosen}"]['port']
						else
							puts "#{cookbook_name} single #{num_instance} instance"
							host['port'] = servers[0][index]['port']
						end
						puts "host #{host}"

					else
						puts "no #{cookbook_name} run"
						host = {'ipaddress' => '', 'fqdn'=> '', 'port' => ''}
					end
				end
				return host
			end

			def multi_search(cookbook_name, recipe_name, index)
				servers = search(:node, "recipes:#{cookbook_name}")
				host = {}
				if servers.length > 0
					host['ipaddress'] = servers[0]['ipaddress']
					host['fqdn'] = servers[0]['fqdn']
					num_instance = servers[0][index]['num_instance']

					unless (num_instance.nil? || num_instance == "")
						# not supposed to support service installed on multiple machines. just use the first one found
						log "#{cookbook_name} multiple #{num_instance} instance"
						host['num_instance'] = num_instance
						host['default'] = servers[0][index]['default']

						for i in 0..num_instance-1
							host[i] = {}
							host[i]['port'] = servers[0][index]["#{i}"]['port']
							host[i]['version'] = servers[0][index]["#{i}"]['version']
						end
					else
						log "#{cookbook_name} single #{num_instance} instance"
						host[0] = {}
						host[0]['port'] = servers[0][index]['port']
						host[0]['version'] = servers[0][index]['version']
						host['num_instance'] = 1
						host['default'] = 0
					end
					return host
				else
					host['num_instance'] = 0
				end
			end
end
end
end
