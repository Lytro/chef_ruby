include_recipe "apt"
include_recipe "build-essential"

ruby_installed_check = "ruby -v | grep #{ node[:chef_ruby][:version].gsub( '-', '' ) }"

%w( wget zlib1g-dev libssl-dev libffi-dev libxml2-dev libncurses-dev libreadline-dev libyaml-0-2 libyaml-dev ).each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/ruby-#{node[:chef_ruby][:version]}.tar.bz2" do
  source "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{node[:chef_ruby][:version]}.tar.bz2"
  not_if ruby_installed_check
end

bash "unpack ruby-#{ node[:chef_ruby][:version] }.tar.bz2 and build" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -xjf ruby-#{ node[:chef_ruby][:version] }.tar.bz2
    cd ruby-#{ node[:chef_ruby][:version] } && ./configure && make && make install
  EOH
  not_if ruby_installed_check
end

%w( openssl readline ).each do |ext|
  bash "configure & make #{ node[:chef_ruby][:version] } #{ext} support" do
    user "root"
    cwd "#{Chef::Config[:file_cache_path]}/ruby-#{ node[:chef_ruby][:version] }/ext/#{ext}"
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

rubygems_installed_check = "gem -v | grep #{node[:chef_ruby][:rubygems][:version]}"

remote_file "#{Chef::Config[:file_cache_path]}/rubygems-#{node[:chef_ruby][:rubygems][:version]}.tgz" do
  source "http://production.cf.rubygems.org/rubygems/rubygems-#{node[:chef_ruby][:rubygems][:version]}.tgz"

  not_if rubygems_installed_check
end

execute "extract and install rubygems" do
  cwd Chef::Config[:file_cache_path]
  command "tar zxf rubygems-#{node[:chef_ruby][:rubygems][:version]}.tgz && cd rubygems-#{node[:chef_ruby][:rubygems][:version]} && ruby setup.rb --no-format-executable"

  not_if rubygems_installed_check
end

gem_package "bundler"

ohai "reload" do
  action :reload
end
