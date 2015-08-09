require 'uuidtools'

def load_current_resource
  @current_resource = Chef::Resource::LibvirtNetwork.new(new_resource.name)
  @libvirt = ::Libvirt.open(new_resource.uri)
  @network = load_network rescue nil
  @current_resource
end

action :define do
  unless network_defined?
    network_xml = Tempfile.new(new_resource.name)
    t = template network_xml.path do
      cookbook "libvirt"
      source   "network.xml"
      variables(
        :name    => new_resource.name,
        :bridge  => new_resource.bridge,
        :netmask => new_resource.netmask,
        :gateway => new_resource.gateway,
        :forward => new_resource.forward,
        :domain  => new_resource.domain,
        :dhcp    => new_resource.dhcp_range,
        :uuid    => ::UUIDTools::UUID.random_create
      )
      action :nothing
    end
    t.run_action(:create)

    @libvirt.define_network_xml(::File.read(network_xml.path))
    @network = load_network
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  require_defined_network
  unless network_active?
    @network.create
    new_resource.updated_by_last_action(true)
  end
end

action :autostart do
  require_defined_network
  unless network_autostart?
    @network.autostart = true
    new_resource.updated_by_last_action(true)
  end
end

private

def load_network
  @libvirt.lookup_network_by_name(new_resource.name)
end

def require_defined_network
  error = RuntimeError.new "You have to define network '#{new_resource.name}' first"
  raise error unless network_defined?
end

def network_defined?
  @network
end

def network_autostart?
  @network.autostart?
end

def network_active?
  @network.active?
end
