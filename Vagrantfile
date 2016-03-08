# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

###############################
# General project settings
# -----------------------------
# This first one doesn't seem to exist...
# box_name                = "chef/debian-7.4"
box_name                = "mbman/debian-7"
box_memory              = 2048
box_cpus                = 1
box_cpu_max_exec_cap    = "100"

# Hardcode VM client IP
ip_address = "192.168.10.10"

# Hardcode Proxy settings
proxy_ip = "10.0.2.2"
proxy_port = "7890"


# Plugins to setup the proxy stuff

required_plugins = %w(vagrant-proxyconf)
# -----------------------------

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

###############################

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = box_name

  config.vm.provider "virtualbox" do |v|
    v.memory = box_memory
    v.cpus   = box_cpus
    v.customize ["modifyvm", :id, "--cpuexecutioncap", box_cpu_max_exec_cap]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: ip_address

  # We'll just connect to the guest IP directly on port 80
  # config.vm.network "forwarded_port", guest:80, host:8080

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.proxy.http     = "http://#{proxy_ip}:#{proxy_port}"
  config.proxy.https    = "https://#{proxy_ip}:#{proxy_port}"
  config.proxy.no_proxy = "localhost,127.0.0.1,#{proxy_ip}"


  # Provisioning
  config.vm.provision "shell" do |s|
    s.path = "./provision/bootstrap.sh"
    s.args = [proxy_ip, proxy_port, ip_address]
    s.privileged = true
  end

  config.vm.provision "shell", run: "always" do |s|
    s.path = "./provision/always.sh"
    s.privileged = true
  end
end
