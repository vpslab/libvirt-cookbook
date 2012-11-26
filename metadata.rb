maintainer       "VPSLab"
maintainer_email "pawel.pacana@gmail.com"
license          "Apache 2.0"
description      "Installs libvirt and provides libvirt resources."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w(ubuntu debian).each do |os|
  supports os
end
