# -*- mode: ruby -*-
# vi: set ft=ruby :

class CloudUbuntuVagrant < VagrantVbguest::Installers::Ubuntu
  def install(opts=nil, &block)
    communicate.sudo('sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list ', opts, &block)
    communicate.sudo('apt-get update', opts, &block)
    communicate.sudo('apt-get -y -q purge virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11', opts, &block)
    @vb_uninstalled = true
    super
  end

  def running?(opts=nil, &block)
    return false if @vb_uninstalled
    super
  end
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
  config.vbguest.installer = CloudUbuntuVagrant

  script = <<SCRIPT
  set -e
  set -x

  DEBIAN_FRONTEND=noninteractive

  gem install bundler
  apt-get -qy install libxml2-dev libxslt-dev

  echo DONE

SCRIPT
  config.vm.provision :shell, :inline => script
end
