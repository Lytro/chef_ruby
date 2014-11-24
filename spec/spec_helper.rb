require 'chefspec'
require 'chefspec/berkshelf'
require 'pry'

Dir['./spec/support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '12.04'
  config.role_path = 'spec/roles'
end

def runner(environment = 'test', attributes = {})
  ChefSpec::SoloRunner.new do |node|
    # Create a new environment (you could also use a different :let block or :before block)
    env = Chef::Environment.new
    env.name environment

    # Stub the node to return this environment
    allow(node).to receive(:chef_environment).and_return(env.name)

    # Stub any calls to Environment.load to return this environment
    allow(Chef::Environment).to receive(:load).and_return(env)

    attributes.each_pair do |key, val|
      node.set[key] = val
    end
  end
end
