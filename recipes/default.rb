%w(libvirt-bin libvirt-dev).each do |name|
  package name do
    action :nothing
  end.run_action(:install)
end

%w(ruby-libvirt uuidtools).each do |name|
  chef_gem name do
    action :install
  end
end

$LOAD_PATH.delete("/usr/bin/../lib") # scumbag LOAD_PATH: https://github.com/opscode/chef/blob/master/bin/chef-solo#L22
require 'libvirt'
