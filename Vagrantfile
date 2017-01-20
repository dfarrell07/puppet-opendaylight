# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Re-map sync'd dir so it has the same name as the module
  # Not doing this causes `puppet apply` to fail at catalog compile
  config.vm.synced_folder ".", "/home/vagrant/puppet-opendaylight", type: "rsync"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

  # We run out of RAM once ODL starts with default 500MB
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 4096
    libvirt.cpus = 2
  end

  # We run out of RAM once ODL starts with default 500MB
  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.memory = 4096
    virtualbox.cpus = 2
  end

  config.vm.define "fedora" do |fedora|
    fedora.vm.box = "fedora/25-cloud-base"

    fedora.vm.provision "shell", inline: "dnf update -y"

    # Install required gems via Bundler
    fedora.vm.provision "shell", inline: "dnf install -y rubygems ruby-devel gcc-c++ zlib-devel patch redhat-rpm-config make"
    fedora.vm.provision "shell", inline: "gem install bundler"
    fedora.vm.provision "shell", inline: "echo export PATH=\\$PATH:/usr/local/bin >> /home/vagrant/.bashrc"
    fedora.vm.provision "shell", inline: "echo export PATH=\\$PATH:/usr/local/bin >> /root/.bashrc"
    fedora.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle install" vagrant'
    fedora.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle update" vagrant'

    # Git is required for cloning Puppet module deps in `rake test`
    fedora.vm.provision "shell", inline: "dnf install -y git"

    # Install Docker for Docker-based Beaker tests
    fedora.vm.provision "shell", inline: "tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/fedora/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
"
    fedora.vm.provision "shell", inline: "dnf install -y docker-engine xfsprogs"
    fedora.vm.provision "shell", inline: "usermod -a -G docker vagrant"
    fedora.vm.provision "shell", inline: "systemctl start docker"
    fedora.vm.provision "shell", inline: "systemctl enable docker"
  end

  config.vm.define "cent" do |cent|
    cent.vm.box = "centos/7"

    cent.vm.provision "shell", inline: "yum update -y"

    # RVM to get recent Ruby. >=2.2.5 required by ruby_dep Gem, 2.0.0 in CentOS
    cent.vm.provision "shell", inline: "yum install -y ruby-devel gcc-c++ zlib-devel patch redhat-rpm-config make"
    cent.vm.provision "shell", inline: "gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
    cent.vm.provision "shell", inline: "curl -L get.rvm.io | bash -s stable"
    cent.vm.provision "shell", inline: "echo source /etc/profile.d/rvm.sh >> /home/vagrant/.bashrc"
    cent.vm.provision "shell", inline: "rvm install 2.4.0"
    cent.vm.provision "shell", inline: "ruby --version"
    # This has to be done as a login shell to get rvm fns
    # https://rvm.io/support/faq#what-shell-login-means-bash-l
    # http://superuser.com/questions/306530/run-remote-ssh-command-with-full-login-shell
    cent.vm.provision "shell", inline: 'bash -lc "rvm use 2.4.0 --default"'
    cent.vm.provision "shell", inline: "ruby --version"

    # Install required gems via Bundler
    cent.vm.provision "shell", inline: "yum install -y rubygems"
    cent.vm.provision "shell", inline: "gem install bundler"
    cent.vm.provision "shell", inline: "echo export PATH=\\$PATH:/usr/local/bin >> /home/vagrant/.bashrc"
    cent.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle install" vagrant'
    cent.vm.provision "shell", inline: 'su -c "cd /home/vagrant/puppet-opendaylight; bundle update" vagrant'


    # Git is required for cloning Puppet module deps in `rake test`
    cent.vm.provision "shell", inline: "yum install -y git"

    # Install Docker for Docker-based Beaker tests
    cent.vm.provision "shell", inline: "tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
"
    cent.vm.provision "shell", inline: "yum install -y docker-engine"
    cent.vm.provision "shell", inline: "usermod -a -G docker vagrant"
    cent.vm.provision "shell", inline: "systemctl start docker"
    cent.vm.provision "shell", inline: "systemctl enable docker"
  end
end
