def load_current_resource
  @current_resource = Chef::Resource::LibvirtNetworkInterface.new(new_resource.name)
  @libvirt = ::Libvirt.open('qemu:///system')
  @current_resource
end

action :attach do
  begin
    domain = load_domain
    interface_xml = Tempfile.new(new_resource.name)
    t = template interface_xml.path do
      cookbook "libvirt"
      source   "network_interface.xml"
      variables(
        :type   => new_resource.type,
        :model  => new_resource.model,
        :source => new_resource.source,
        :target => new_resource.target,
        :domain => new_resource.domain,
        :mac_address => new_resource.mac_address
      )
      action :nothing
    end
    t.run_action(:create)

    domain.attach_device(::File.read(interface_xml.path))
    new_resource.updated_by_last_action(true)
  rescue Libvirt::RetrieveError
    raise "You have to define libvirt domain '#{new_resource.domain}' first"
  end
end

private

def load_domain
  @libvirt.lookup_domain_by_name(new_resource.domain)
end
