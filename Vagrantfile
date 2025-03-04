# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  #config.vm.box = "boxcutter/ubuntu1604"
  #config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider :docker do |d|
    d.build_dir = "."
    d.remains_running = true
    d.privileged = true
    d.has_ssh = true
    d.create_args = ["--cgroupns=host"]
  end

  config.vm.define "devD", primary: true do |dev|
    config.ssh.forward_agent = true
    config.vm.hostname = "absys-dev"

    # Port forwarding for Django's development server.
    config.vm.network "forwarded_port", guest: 8000, host: 8000,
      auto_correct: true

    # Port forwarding for Glances server.
    config.vm.network "forwarded_port", guest: 61208, host: 61208,
      auto_correct: true
  end

  config.vm.define "deploymentD", autostart: false do |deployment|
    config.vm.hostname = "absys-deployment"

    # Port forwarding for Apache server.
    config.vm.network "forwarded_port", guest: 443, host: 8080,
      auto_correct: true
    config.vm.network "forwarded_port", guest: 80, host: 8081,
      auto_correct: true
  end

  # Salt provisioning.
  config.vm.synced_folder "salt/roots/", "/srv/"
  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "salt/minion"
    salt.run_highstate = true
    salt.version = "3005"
    salt.install_type = "stable"
  end
end