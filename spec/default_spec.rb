require 'chefspec'

describe 'chef-ruby::default' do
  let(:runner) { ChefSpec::ChefRunner.new }
  let(:chef_run) { runner.converge 'chef-ruby::default' }

  before do
    Chef::Recipe.any_instance.stub(:load_recipe).and_return do |arg|
      runner.node.run_state[:seen_recipes][arg] = true
    end
  end

  %w( wget zlib1g-dev libssl-dev libffi-dev libxml2-dev libncurses-dev libreadline-dev libyaml-0-2 libyaml-dev ).each do |package|
    it "installs package #{package}" do
      chef_run.should install_package package
    end
  end

  it "downloads ruby" do
    chef_run.should create_remote_file "#{Chef::Config[:file_cache_path]}/ruby-#{chef_run.node[:ruby][:version]}.tar.bz2"
  end

  it "creates a gemrc" do
    chef_run.should create_file_with_content '/usr/local/etc/gemrc', "install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri\n"
    chef_run.file('/usr/local/etc/gemrc').should be_owned_by('root', 'root')
  end
end
