require 'spec_helper'

describe 'chef_ruby::default' do
  let(:chef_run) { runner.converge described_recipe }

  before do
    stub_command('ruby -v | grep 2.0.0p247').and_return(false)
    stub_command('gem -v | grep 2.0.6').and_return(false)
  end

  %w( wget zlib1g-dev libssl-dev libffi-dev libxml2-dev libncurses-dev libreadline-dev libyaml-0-2 libyaml-dev ).each do |package|
    it "installs package #{package}" do
      expect(chef_run).to install_package package
    end
  end

  it "downloads ruby" do
    expect(chef_run).to create_remote_file "#{Chef::Config[:file_cache_path]}/ruby-#{chef_run.node[:chef_ruby][:version]}.tar.bz2"
  end

  it "creates a gemrc" do
    expect(chef_run).to create_file('/etc/gemrc').with(user: 'root', group: 'root').with_content("install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri\n")
  end

  it "downloads rubygems" do
    expect(chef_run).to create_remote_file "#{Chef::Config[:file_cache_path]}/rubygems-#{chef_run.node[:chef_ruby][:rubygems][:version]}.tgz"
  end

  it "gem installs bundler" do
    expect(chef_run).to install_gem_package 'bundler'
  end
end
