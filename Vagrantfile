Vagrant.configure("2") do |config|
    # Use ubuntu:22.04 as the base image
    config.vm.box = "generic/ubuntu2204"
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 2
    end
    config.vm.network "public_network"
    # volume mount
    config.vm.synced_folder ".", "/home/vagrant"
    # ssh
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y strace ltrace
    SHELL
end