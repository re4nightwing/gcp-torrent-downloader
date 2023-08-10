#!/bin/bash

# Update package lists and install Nginx
sudo apt update
sudo apt install -y nginx transmission-cli

# Create the /var/www/downloads directory
sudo mkdir -p /var/www/downloads

# Set permissions for the directory
sudo chown -R www-data:www-data /var/www/downloads
sudo chmod -R 755 /var/www

# Create a virtual host configuration for Nginx
sudo tee /etc/nginx/sites-available/downloads <<EOF
server {
    listen 80;
    server_name _;
    
    location /downloads {
        alias /var/www/downloads;
        autoindex on;
    }
    
    error_log /var/log/nginx/downloads-error.log;
    access_log /var/log/nginx/downloads-access.log;
}
EOF

# Enable the virtual host
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/downloads /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx to apply changes
sudo systemctl restart nginx

# Get the VM's IP address
ip_address=curl ifconfig.me

# Print the IP address
echo "Nginx server is running. Address: http://$ip_address/downloads"