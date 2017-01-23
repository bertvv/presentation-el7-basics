# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.define 'centosbox' do |node|
    node.vm.box = 'bertvv/centos72'
    node.vm.network :private_network,
      ip: '192.168.56.72'
    #node.vm.provider :virtualbox do |vb|
    #end
    node.vm.provision :shell,
      path: 'centosbox.sh'
  end
end
