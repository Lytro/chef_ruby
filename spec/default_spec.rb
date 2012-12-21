require 'chefspec'

describe 'chef-ruby1.9::default' do
  let(:chef_run) { ChefSpec::ChefRunner.new.converge 'chef-ruby1.9::default' }

  it "pending" do
    pending "implement me!"
    chef_run.should do_something
  end
end
