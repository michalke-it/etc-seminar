# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "demo"
  config.disksize.size = '50GB'
  config.vm.provider "virtualbox" do |v|
    v.name = "demo"
    v.memory = 8192
    v.cpus = 6
    v.gui = false
  end
  config.vm.provision :shell, path: "install.sh"
end
