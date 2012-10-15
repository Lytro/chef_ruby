include_recipe "apt"
include_recipe "build-essential"

ruby_installed_check = "ruby -v | grep #{ node[:ruby][:version].gsub( '-', '' ) }"

%w( wget zlib1g-dev libssl-dev libffi-dev libxml2-dev libncurses-dev libreadline-dev libyaml-0-2 libyaml-dev ).each do |pkg|
  package pkg do
    action :install
  end
end

execute "get & unpack #{ node[:ruby][:version] }" do
  user "root"
  command "cd /usr/src && wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{ node[:ruby][:version] }.tar.bz2 && tar xjf ruby-#{ node[:ruby][:version] }.tar.bz2 && cd ruby-#{ node[:ruby][:version] }"
  not_if ruby_installed_check
end

execute "configure & make #{ node[:ruby][:version] }" do
  user "root"
  command "cd /usr/src/ruby-#{ node[:ruby][:version] } && ./configure && make && make install"
  not_if ruby_installed_check
end

%w( openssl readline ).each do |ext|
  execute "configure & make #{ node[:ruby][:version] } #{ext} support" do
    user "root"
    command "cd /usr/src/ruby-#{ node[:ruby][:version] }/ext/#{ext}/ && ruby extconf.rb && make && make install"
    not_if ruby_installed_check
  end
end

# add gemrc file
file "/usr/local/etc/gemrc" do
  action :create
  owner "root"
  group "root"
  content "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri\n"
  mode 0644
end

# install gems
# TODO abstract this into an attribute?
{"chef" => "10.14.4", "ohai" => "6.14.0"}.each do |g,v|
  gem_package g do
    version v
    gem_binary('/usr/local/bin/gem')
  end
end
