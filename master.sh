#!/bin/bash

echo "Provisioning master..."

  
# Install software, configure settings, etc_
# Update the package manager_
  
sudo apt update


  
# Upgrade applications_
  
sudo apt upgrade -y
echo "Update and upgrade done"


  
# Install Ifconfig_
  
sudo apt install net-tools


  
# Install the SSH server_
  
sudo apt-get install -y openssh-server


  
# Define the username and password for the new user_
  
new_username="altschool"
new_password="altschool1234"


  
# Create the user with a home directory and set the password_
useradd -m -s /bin/bash "$new_username" && \
echo "$new_username:$new_password" | chpasswd && \
mkdir -p /home/vagrant/.ssh && \
chmod 700 /home/vagrant/.ssh && \
chown -R vagrant:vagrant /home/vagrant/.ssh

  
# Add the user to the sudo group (for systems using sudo)_
  
usermod -aG sudo "$new_username"
echo "User '$new_username' has been created and granted root privileges."


  
# Enable SSH key-based authentication between the master and slave nodes_
  
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@192.168.130.1


  
# Restart the SSH service to apply the changes_
  
sudo systemctl restart sshd


  
# Copy the contents of /mnt/altschool on the master node to /mnt/altschool/slave on the slave node_
  
ssh altschool@192.168.130.0 "rsync -av /mnt/altschool /home/altschool/"


  
# Install Apache web server and make it start on boot_
  
sudo apt install -y apache2
sudo apachectl -k start 


  
# Install MySQL server and set root password_
  
sudo apt install -y mysql-server


  
# Start the MySQL Server and redirect standard error ouput to file_
  
echo "Starting MySQL server for the first time"

sudo systemctl start mysql 2> /dev/null


  
# Secure MySQL installation with the options set in the response.txt file_
  
sudo mysql_secure_installation < response.txt


  
# Confirm Installation Status_
  
echo "MySQL installation and security configuration completed."


  
# Install PHP and required modules_
  
sudo apt install -y php libapache2-mod-php php-mysql


  
# Enable Apache modules_
  
a2enmod php7.4
sudo systemctl reload apache2


  
# Create a PHP test file to verify the installation_
  
sudo echo "<?php

// Show all information, defaults to INFO_ALL
phpinfo();

// Show just the module information.
// phpinfo(8) yields identical results.
phpinfo(INFO_MODULES);

?>" > /var/www/html/index.php


  
# Reload Apache to apply changes_
  
sudo systemctl reload apache2


  
# Display a message indicating the LAMP stack is installed_
  
echo "LAMP stack (Apache, MySQL, PHP) has been successfully installed."


  
# Update packages and install rsync_
  
sudo apt update && sudo apt install rsync -y


  
# Copy the test.php file to the web directory_
  
rsync -avz test.php altschool@slave:/var/www/html/


  
# Install Nginx on the Master node (for load balancing)_
  
sudo apt install -y nginx


  
# Create an Nginx configuration file_
  
echo "
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server 192.168.130.0;
        server 192.168.130.1;
    }

    server {
        listen 800;
        location / {
            proxy_pass http://backend;
        }
    }
}" > nginx-load-balancer.conf


  
# Move the configuration file to the nginx foler in the etc directory_
  
sudo mv /home/vagrant/nginx-load-balancer.conf /etc/nginx/nginx.conf


  
# Test if configuration is correct and restart nginx_
  
sudo nginx -t
sudo systemctl restart nginx

  
# Clean up and exit_
  
exit 0
