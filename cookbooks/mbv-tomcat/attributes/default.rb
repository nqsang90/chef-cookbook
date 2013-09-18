

default['mbv_tomcat']['num_instance'] = 2
default['mbv_tomcat']['shutdown_ports'] = [8006, 8007]
default['mbv_tomcat']['connector_ports'] = [8081, 8082]
default['mbv_tomcat']['ajp_connector_ports'] = [8010, 8011]
default['mbv_tomcat']['name'] = "apache-tomcat-6.0.37"
default['mbv_tomcat']['url'] = "http://10.120.29.99/apache-tomcat-6.0.37.tar.gz"
default['mbv_tomcat']['checksum'] = "3e91abc752bf2b6ca19df9c8644bccdd92ba837397a8c1a745d72f58d5301b00"
default['mbv_tomcat']['deploy_dir'] = "/opt"


for i in 0..node['mbv_tomcat']['num_instance']-1
	default["mbv_tomcat"][i]["home"] = "/opt/apache-tomcat-#{i}"
end




