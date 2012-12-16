require 'uuidtools'

def load_current_resource
  @current_resource = Chef::Resource::LibvirtDomain.new(new_resource.name)
  @hypervisor = Vpslab::Libvirt::Hypervisor.new(new_resource.uri)
  @current_resource
end

action :define do
  unless @hypervisor.domain_defined?(domain_name)
    memory_in_bytes = to_bytes(new_resource.memory)
    libvirt_arch    = to_arch(new_resource.arch)

    domain_xml = Tempfile.new(new_resource.name)
    t = template domain_xml.path do
      cookbook "libvirt"
      source   "kvm_domain.xml"
      variables(
        :name   => domain_name,
        :memory => memory_in_bytes,
        :vcpu   => new_resource.vcpu,
        :arch   => libvirt_arch,
        :uuid   => ::UUIDTools::UUID.random_create
      )
      action :nothing
    end
    t.run_action(:create)

    @hypervisor.define_domain(::File.read(domain_xml.path))
    new_resource.updated_by_last_action(true)
  end
end

action :autostart do
  if @hypervisor.autostart_domain(domain_name)
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  if @hypervisor.create_domain(domain_name)
    new_resource.updated_by_last_action(true)
  end
end

def domain_name
  new_resource.name
end

private

def to_arch(arch)
  case arch
  when /64/
    "x86_64"
  end
end

def to_bytes(value)
  case value
  when /M$/
    value.to_i * 1024
  when /G$/
    value.to_i * 1024**2
  else
    value.to_i
  end
end
