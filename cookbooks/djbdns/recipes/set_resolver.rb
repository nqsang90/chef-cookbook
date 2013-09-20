  if ['debian','ubuntu'].member? node['platform']

    dhclientconf = '/etc/dhcp3/dhclient.conf'
    resolvconf = '/etc/resolv.conf'
    if node['lsb']['codename'] == 'precise'
      dhclientconf = '/etc/dhcp/dhclient.conf'
      resolvconf = '/etc/resolvconf/resolv.conf.d/base'
    end

    template dhclientconf do
      source "dhclient.conf.erb"
      owner "root"
      group "root"
      mode "0644"
      variables({
        "dns_domain" => node['djbdns']['dns_domain'],
	"dns_ip" => node['djbdns']['dns_ip']
      })
    end

    execute "update_resolvconf_2" do
      command "/etc/init.d/networking restart && /sbin/resolvconf -u"
      action :nothing
      only_if { node['lsb']['codename'] == 'precise' }
    end

    template resolvconf do
      source "resolv.conf.erb"
      owner "root"
      group "root"
      mode "0644"
      variables({
	"dns_domain" => node['djbdns']['dns_domain'],
        "dns_ip" => node['djbdns']['dns_ip'],
        "dns_ips" => node['djbdns']['dns_defaults']
      })
      notifies :run, "execute[update_resolvconf_2]", :immediately
    end

  end
