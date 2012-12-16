actions :define, :create, :autostart

def initialize(*args)
  super
  @action = :define
end

attribute :vcpu, :kind_of => [Integer, String], :required => true
attribute :memory, :kind_of => [Integer, String], :required => true
attribute :arch, :kind_of => String, :required => true
attribute :filesystems, :kind_of => Array
attribute :network, :kind_of => String
attribute :uri, :kind_of => String, :default => 'qemu:///system'
