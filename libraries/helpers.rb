module Vpslab
  module Libvirt
    module Helpers
      module_function

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

    end
  end
end
