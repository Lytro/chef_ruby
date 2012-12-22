include_recipe "apt"
include_recipe "build-essential"

ruby_installed_check = "ruby -v | grep #{ node[:ruby][:version].gsub( '-', '' ) }"

%w( wget zlib1g-dev libssl-dev libffi-dev libxml2-dev libncurses-dev libreadline-dev libyaml-0-2 libyaml-dev ).each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/ruby-#{node[:ruby][:version]}.tar.bz2" do
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{node[:ruby][:version]}.tar.bz2"
  not_if ruby_installed_check
end

bash "unpack #{ node[:ruby][:version] } and build" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -vxjf ruby-#{ node[:ruby][:version] }.tar.bz2 }
    cd ruby-#{ node[:ruby][:version] }.tar.bz2 } && ./configure && make && make install
  EOH
  not_if ruby_installed_check
end

%w( openssl readline ).each do |ext|
  bash "configure & make #{ node[:ruby][:version] } #{ext} support" do
    user "root"
    cwd "#{Chef::Config[:file_cache_path]}/ruby-#{ node[:ruby][:version] }/ext/#{ext}"
    code <<-EOH
      ruby extconf.rb && make && make install
    EOH
    not_if ruby_installed_check
  end
end

file "/usr/local/etc/gemrc" do
  action :create
  owner "root"
  group "root"
  mode 0644

  content "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri\n"
end

# install gems
# TODO abstract this into an attribute?
{"chef" => "10.14.4", "ohai" => "6.14.0"}.each do |g,v|
  gem_package g do
    version v
    gem_binary('/usr/local/bin/gem')
  end
end
