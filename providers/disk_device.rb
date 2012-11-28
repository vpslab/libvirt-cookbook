def load_current_resource
  @current_resource = Chef::Resource::LibvirtDiskDevice.new(new_resource.name)
  @libvirt = ::Libvirt.open(new_resource.uri)
  @current_resource
end

action :attach do
  begin
    domain = load_domain
    device_xml = Tempfile.new(new_resource.name)
    t = template device_xml.path do
      cookbook "libvirt"
      source   "disk_device.xml"
      variables(
        :type   => new_resource.type,
        :bus    => new_resource.bus,
        :source => new_resource.source,
        :target => new_resource.target
      )
      action :nothing
    end
    t.run_action(:create)

    domain.attach_device(::File.read(device_xml.path))
    new_resource.updated_by_last_action(true)
  rescue Libvirt::RetrieveError
    raise "You have to define libvirt domain '#{new_resource.domain}' first"
  end
end

private

def load_domain
  @libvirt.lookup_domain_by_name(new_resource.domain)
end
