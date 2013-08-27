name              'chef_ruby'
maintainer        "Lytro"
maintainer_email  "cookbooks@lytro.com"
license           "WTFPL"
description       "Installs Ruby 1.9 from source"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.mdown'))
version           "2.2.1"
supports          "ubuntu"

%w( apt build-essential ).each do |d|
  depends d
end

recipe            "chef_ruby::default", "Installs Ruby 1.9 from source."
