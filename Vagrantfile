Vagrant.configure("2") do |config|
  # Configuration for the master virtual machine
  config.vm.define "master" do |node|
    node.vm.box = "ubuntu/bionic64"
    node.vm.boot_timeout = 800
    node.vm.network "private_network", type: "private_network", ip: "192.168.56.101"
    config.vm.network "public_network"
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  # Configuration for the slave virtual machine
  config.vm.define "slave" do |node|
    node.vm.box = "ubuntu/bionic64"
    node.vm.boot_timeout = 800
    node.vm.network "private_network", type: "private_network", ip: "192.168.56.102"
    config.vm.network "public_network"
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
  end
end

