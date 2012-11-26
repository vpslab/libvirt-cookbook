%w(libvirt-bin libvirt-dev).each do |name|
  package name do
    action :install
  end
end

chef_gem 'ruby-libvirt' do
  action :install
end

$LOAD_PATH.delete("/usr/bin/../lib") # scumbag LOAD_PATH: https://github.com/opscode/chef/blob/master/bin/chef-solo#L22
require 'libvirt'
