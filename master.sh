#!/bin/bash

echo "Provisioning master..."

## Install software, configure settings, etc.
## Update the package manager
sudo apt update


## Upgrade applications
sudo apt upgrade -y
echo "Update and upgrade done"


## Install Ifconfig
sudo apt install net-tools


## Install the SSH server
sudo apt-get install -y openssh-server


## Define the username and password for the new user
new_username="altschool"
new_password="altschool1234"


## Create the user with a home directory and set the password
useradd -m -s /bin/bash "$new_username" && \
echo "$new_username:$new_password" | chpasswd && \
mkdir -p /home/vagrant/.ssh && \
chmod 700 /home/vagrant/.ssh && \
chown -R vagrant:vagrant /home/vagrant/.ssh


## Add the user to the sudo group (for systems using sudo)
usermod -aG sudo "$new_username"
echo "User '$new_username' has been created and granted root privileges."


## Enable SSH key-based authentication between the master and slave nodes
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@192.168.100.100


## Restart the SSH service to apply the changes

sudo systemctl restart sshd


## Copy the contents of /mnt/altschool on the master node to /mnt/altschool/slave on the slave node
ssh altschool@192.168.100.100 "rsync -av /mnt/altschool /home/altschool/"


## Install Apache web server and make it start on boot
sudo apt install -y apache2
sudo apachectl -k start 


## Install MySQL server and set root password
sudo apt install -y mysql-server


## Start the MySQL Server and redirect standard error ouput to file
echo "Starting MySQL server for the first time"

sudo systemctl start mysql 2> /dev/null


## Secure MySQL installation with the options set in the fix.txt file
sudo mysql_secure_installation < fix.txt


## Confirm Installation Status
echo "MySQL installation and security configuration completed."


## Install PHP and required modules
sudo apt install -y php libapache2-mod-php php-mysql


## Enable Apache modules
a2enmod php7.4
sudo systemctl reload apache2


## Create a PHP test file to verify the installation
sudo echo "<?php

// Show all information, defaults to INFO_ALL
phpinfo();

// Show just the module information.
// phpinfo(8) yields identical results.
phpinfo(INFO_MODULES);

?>" > /var/www/html/index.php


## Reload Apache to apply changes
sudo systemctl reload apache2


## Display a message indicating the LAMP stack is installed
echo "LAMP stack (Apache, MySQL, PHP) has been successfully installed."


## Update packages and install rsync
sudo apt update && sudo apt install rsync -y


## Copy the test.php file to the web directory
rsync -avz test.php altschool@slave:/var/www/html/


## Install Nginx on the Master node (for load balancing)
sudo apt install -y nginx


## Create an Nginx configuration file
echo "
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server 192.168.100.101;
        server 192.168.100.100;
    }

    server {
        listen 800;
        location / {
            proxy_pass http://backend;
        }
    }
}" > nginx-load-balancer.conf



## Move the configuration file to the nginx foler in the etc directory
sudo mv /home/vagrant/nginx-load-balancer.conf /etc/nginx/nginx.conf


## Test if configuration is correct and restart nginx
sudo nginx -t
sudo systemctl restart nginx


## Clean up and exit
exit 0
