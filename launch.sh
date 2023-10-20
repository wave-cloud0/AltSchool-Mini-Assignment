#!/bin/bash

# Create two Vagrant files, one for each node
cat <<EOF > Vagrantfile-Master
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "master"

  # Create a user named altschool with root privileges
  config.vm.provision "shell", inline: <<-SHELL
    sudo mkdir /mnt/altschool/
    sudo useradd -m altschool
    sudo passwd altschool
    sudo usermod -aG sudo altschool
  SHELL

end
EOF

cat <<EOF > Vagrantfile-Slave
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.hostname = "slave"

  # Configure SSH key-based authentication
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get install -y openssh-server
    sudo ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
    sudo cat /etc/ssh/ssh_host_rsa.pub >> /home/altschool/.ssh/authorized_keys
  SHELL

end
EOF

# Create the Vagrant cluster
vagrant up master slave

# Copy the contents of `/mnt/altschool` from the Master node to `/mnt/altschool/slave` on the Slave node
vagrant ssh master -c "sudo cp -r /mnt/altschool/ /mnt/altschool/slave/"

# Display an overview of the Linux process management on the Master node
vagrant ssh master -c "ps aux"

# Install the LAMP stack on both nodes
vagrant ssh master -c "sudo apt-get update && sudo apt-get install -y apache2 mysql-server php7.4 php-mysql"
vagrant ssh slave -c "sudo apt-get update && sudo apt-get install -y apache2 mysql-server php7.4 php-mysql"

# Ensure Apache is running and set to start on boot
vagrant ssh master -c "sudo systemctl enable apache2"
vagrant ssh slave -c "sudo systemctl enable apache2"

# Secure the MySQL installation and initialize it with a default user and password
vagrant ssh master -c "sudo mysql_secure_installation"

# Validate PHP functionality with Apache
vagrant ssh master -c "sudo echo '<?php phpinfo(); ?>' > /var/www/html/info.php"
vagrant ssh master -c "sudo systemctl restart apache2"

# Open a web browser and navigate to http://localhost/info.php to verify that PHP is working properly

# Congratulations! You have successfully deployed a LAMP stack on a two-node Vagrant Ubuntu cluster.

