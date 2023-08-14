#!/bin/bash

#error logger
function error_exit {
    echo "Error: $1"
    exit 1
}

# Update package lists and install Nginx
sudo apt update || error_exit "Failed to update package lists."
sudo apt install -y nginx transmission-daemon curl wget || error_exit "Failed to install packages."

# Create the /var/www/downloads directory
sudo mkdir -p /var/www/downloads || error_exit "Failed to create /var/www/downloads directory."

# Set permissions for the directory
sudo chown -R www-data:www-data /var/www/downloads
sudo chmod -R 755 /var/www

sudo touch /var/www/downloads/it-is-working.txt

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
sudo rm /etc/nginx/sites-enabled/default || error_exit "Failed to remove nginx default config file."
sudo ln -s /etc/nginx/sites-available/downloads /etc/nginx/sites-enabled/ || error_exit "Failed to symantic link for the new config file."

# Test Nginx configuration
sudo nginx -t || error_exit "Nginx test failed"

# Restart Nginx to apply changes
sudo systemctl restart nginx || error_exit "Failed to start the nginx server."

#start Transmission daemon
transmission-daemon

# Transmission deamon stop
sudo /etc/init.d/transmission-daemon stop

# change transmission daemon settings
json_file="/etc/transmission-daemon/settings.json"
json_content=$(sudo cat "$json_file") || error_exit "Failed to read the settings.json file."
json_content=$(echo "$json_content" | sed 's/"rpc-authentication-required": true/"rpc-authentication-required": false/g') || error_exit "Failed to find the 'rpc-authentication-required' line."
json_content=$(echo "$json_content" | sed 's#"download-dir": "/var/lib/transmission-daemon/downloads"#"download-dir": "~/"#g') || error_exit "Failed to find the 'download-dir' line."
user_home=$(eval echo ~)
json_content=$(echo "$json_content" | sed "s#~/#$user_home/#g") || error_exit "Failed to add absolute directory as download directory."
sudo echo "$json_content" > "$json_file"
echo "Changes applied successfully."

sudo /etc/init.d/transmission-daemon restart

# Get the VM's IP address
ip_address=$(curl ifconfig.me) || error_exit "Failed to fetch the external IP address."

#check if transmission is working
transmission-remote -l 

# Print the IP address
echo "Nginx server is running. Address: http://$ip_address/downloads"