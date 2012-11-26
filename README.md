Description
===========

Installs libvirt with Ruby bindings. Provides set of resources to manage domain, network and several devices.

Usage
=====

    libvirt_network 'fake_network' do
      netmask    '255.255.0.0'
      gateway    '192.168.42.1'
      bridge     'fakebr'
      forward    'nat'
      dhcp_range :start => '192.168.42.100', :end => '192.168.42.200'

      action [:define, :create, :autostart]
    end

    libvirt_domain 'fake_dummy' do
      provider 'libvirt_domain_kvm'
      vcpu     '2'
      memory   '512M'
      arch     'amd64'

      action [:define, :create, :autostart]
    end

    libvirt_disk_device 'vda' do
      source '/dev/mapper/vdisk-vm--dummy'
      domain 'fake_dummy'

      action :nothing
      subscribes :attach, resources(:libvirt_domain => 'fake_dummy'), :immediately
    end

    libvirt_network_interface 'eth0' do
      source 'fakebr'
      mac_address '00:57:20:f8:94:cf'
      domain 'fake_dummy'

      action :nothing
      subscribes :attach, resources(:libvirt_domain => 'fake_dummy'), :immediately
    end

