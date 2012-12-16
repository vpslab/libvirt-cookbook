module Vpslab
  module Libvirt
    class Hypervisor

      class DomainNotFoundError < RuntimeError; end

      def initialize(uri)
        @libvirt = ::Libvirt.open(uri)
      end

      def define_domain(xml)
        @libvirt.define_domain_xml(xml)
      end

      def create_domain(name)
        domain = load_domain(name)
        domain.create unless domain.active?
      end

      def autostart_domain(name)
        domain = load_domain(name)
        domain.autostart = true unless domain.autostart?
      end

      def load_domain(name)
        @libvirt.lookup_domain_by_name(name)
      rescue ::Libvirt::RetrieveError
        raise DomainNotFoundError.new("You have to define libvirt domain '#{name}' first")
      end

      def domain_defined?(name)
        load_domain(name)
      rescue DomainNotFoundError
        false
      end

    end
  end
end
