require 'serverspec'
require 'net/ssh'
require 'net/ssh/proxy/command'

# Jumpbox Configuration
inventory = JSON.load(File.read(ENV['SRVSPEC_INVENTORY_FILE']))
jumpbox = inventory['jumpbox']

# Host
host = ENV['TARGET_HOST']

# SSH Options
# options = Net::SSH::Config.for(host)
options = {
  user: ENV['TARGET_HOST_USER'] || 'ubuntu',
  key_data: [File.read(ENV['SRVSPEC_SSH_KEY'])],
  paranoid: false,
  proxy: Net::SSH::Proxy::Command.new("ssh -W %h:%p -i #{ENV['SRVSPEC_SSH_KEY']} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{jumpbox['user']}@#{jumpbox['host']}")
}

# Serverspec options
set :backend,     :ssh
set :host,        host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
