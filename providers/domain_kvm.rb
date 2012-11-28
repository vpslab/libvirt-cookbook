require 'uuidtools'

def load_current_resource
  @current_resource = Chef::Resource::LibvirtDomain.new(new_resource.name)
  @libvirt = ::Libvirt.open(new_resource.uri)
  @domain  = load_domain rescue nil
  @current_resource
end

action :define do
  unless domain_defined?
    memory_in_bytes = to_bytes(new_resource.memory)
    libvirt_arch    = to_arch(new_resource.arch)

    domain_xml = Tempfile.new(new_resource.name)
    t = template domain_xml.path do
      cookbook "libvirt"
      source   "kvm_domain.xml"
      variables(
        :name   => new_resource.name,
        :memory => memory_in_bytes,
        :vcpu   => new_resource.vcpu,
        :arch   => libvirt_arch,
        :uuid   => ::UUIDTools::UUID.random_create
      )
      action :nothing
    end
    t.run_action(:create)

    @libvirt.define_domain_xml(::File.read(domain_xml.path))
    @domain = load_domain
    new_resource.updated_by_last_action(true)
  end
end

action :autostart do
  require_defined_domain
  unless domain_autostart?
    @domain.autostart = true
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  require_defined_domain
  unless domain_active?
    @domain.create
    new_resource.updated_by_last_action(true)
  end
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

def load_domain
  @libvirt.lookup_domain_by_name(new_resource.name)
end

def require_defined_domain
  error = RuntimeError.new "You have to define libvirt domain '#{new_resource.name}' first"
  raise error unless domain_defined?
end

def domain_defined?
  @domain
end

def domain_autostart?
  @domain.autostart?
end

def domain_active?
  @domain.active?
end
