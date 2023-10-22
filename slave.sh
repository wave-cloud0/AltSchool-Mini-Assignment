#!/bin/bash

echo "Provisioning slave..."


   
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


   
# Install Apache web server and make it start on boot_
   
sudo apt install -y apache2
sudo apachectl -k start 

   
# Define the path to the sshd_config file_
   
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
sshd_config="/etc/ssh/sshd_config"


   
# Define the new setting for PasswordAuthentication (yes or no)_
   
new_password_auth="yes"


   
# Define the new setting for PubkeyAuthentication (yes or no)_
   
new_pubkey_authentication="yes"


   
# Use sed to modify the PasswordAuthentication setting in the sshd_config file_
   
sed -i "s/^PasswordAuthentication.*/PasswordAuthentication $new_password_auth/" "$sshd_config"


   
# Use sed to modify the PubkeyAuthentication setting in the sshd_config file_
   
sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication $new_pubkey_authentication/" "$sshd_config"


   
# Restart the SSH service to apply the changes_
   
sudo systemctl restart sshd


   
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


   
# Clean up and exit_
   
exit 0
