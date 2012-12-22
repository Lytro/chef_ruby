require 'chefspec'

describe 'chef-ruby1.9::default' do
  let(:runner) { ChefSpec::ChefRunner.new }
  let(:chef_run) { runner.converge 'chef-ruby1.9::default' }

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
end
