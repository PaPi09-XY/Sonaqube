#!/bin/bash 

# Author: Chris Parbey

logfile="/var/log/nexus-install.log"
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

# Function to log to both file and terminal
log () {
    echo "$1" | sudo tee -a "$logfile"
}

# Function to log and exit on error
log_and_exit () {
    echo "$1" | sudo tee -a "$logfile"
    exit 1
}

# Changing the Hostname of The EC2
log "[$current_datetime] Setting the hostname to nexus..."
sudo hostnamectl set-hostname nexus || log_and_exit "[$current_datetime] Unable to set the hostname for the Nexus server."

# Update and upgrade packages
log "[$current_datetime] Updating and upgrading packages..."
sudo apt update -y || log_and_exit "[$current_datetime] Unable to update packages."
sudo apt upgrade -y || log_and_exit "[$current_datetime] Failed to upgrade packages."

# Create user 'nexus' with sudo access
log "[$current_datetime] Creating user 'nexus' and granting sudo access..."
sudo adduser --disabled-password --gecos "" nexus || log_and_exit "[$current_datetime] Failed to create user 'nexus'."
echo "nexus ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nexus > /dev/null || log_and_exit "[$current_datetime] Failed to add nexus to sudoers."

log "[$current_datetime] User nexus created successfully."

# Switch to 'nexus' user to perform further tasks
su - nexus -c 'bash << EOF
logfile="/var/log/nexus-install.log"
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

log () {
    echo "\$1" | sudo tee -a "\$logfile"
}

log_and_exit () {
    echo "\$1" | sudo tee -a "\$logfile"
    exit 1
}

# Change to /opt directory
log "[$current_datetime] Changing to /opt directory..."
cd /opt || log_and_exit "[$current_datetime] Unable to change to /opt directory."

# Install Java (required for Nexus)
log "[$current_datetime] Installing Java..."
sudo apt install openjdk-11-jdk -y || log_and_exit "[$current_datetime] Failed to install Java."

log "[$current_datetime] Java installation complete."

# Download and install Nexus
log "[$current_datetime] Downloading Nexus 3.68.0-01..."
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz -O nexus-3.68.0-01-unix.tar.gz > /dev/null || log_and_exit "[$current_datetime] Failed to download Nexus."

log "[$current_datetime] Extracting Nexus..."
sudo tar -xzvf nexus-3.68.0-01-unix.tar.gz > /dev/null || log_and_exit "[$current_datetime] Failed to extract Nexus."

log "[$current_datetime] Removing downloaded archive..."
sudo rm -rf nexus-3.68.0-01-unix.tar.gz || log_and_exit "[$current_datetime] Failed to remove the downloaded archive."

log "[$current_datetime] Renaming extracted directory..."
sudo mv nexus-3.68.0-01 nexus || log_and_exit "[$current_datetime] Failed to rename extracted directory."

# Change ownership of Nexus and Sonatype-work directories
log "[$current_datetime] Changing ownership of Nexus directory..."
sudo chown -R nexus:nexus /opt/nexus || log_and_exit "[$current_datetime] Unable to change ownership of the nexus directory."

log "[$current_datetime] Changing ownership of Sonatype-work directory..."
sudo chown -R nexus:nexus /opt/sonatype-work || log_and_exit "[$current_datetime] Unable to change ownership of the Sonatype-work directory."

# Configure Nexus to run as user 'nexus'
log "[$current_datetime] Configuring Nexus to run as user 'nexus'..."
echo "run_as_user=\"nexus\"" | sudo tee /opt/nexus/bin/nexus.rc > /dev/null || log_and_exit "[$current_datetime] Failed to configure Nexus run-as user."

# Create systemd service for Nexus
log "[$current_datetime] Creating systemd service for Nexus..."
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOL
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

log "[$current_datetime] Reloading the systemd daemon..."
sudo systemctl daemon-reload || log_and_exit "[$current_datetime] Failed to reload the daemon."

log "[$current_datetime] Starting and enabling Nexus service..."
sudo systemctl enable --now nexus.service || log_and_exit "[$current_datetime] Failed to start and enable Nexus service."

log "[$current_datetime] Nexus installation completed successfully."
EOF
'

log "[$current_datetime] Script execution completed."
