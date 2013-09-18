#
# Cookbook Name:: cpan-mods
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# install YAML
cpan_client 'YAML' do
	action 'install'
	install_type 'cpan_module'
	user 'root'
	group 'root'
end
# install URI::Escape
cpan_client 'URI::Escape' do
	action 'install'
	install_type 'cpan_module'
	user 'root'
	group 'root'
end
