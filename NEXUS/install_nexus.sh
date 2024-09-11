#!/bin/bash

# Update the package manager
sudo apt-get update -y

# Install Java OpenJDK 11 (required by Nexus)
sudo apt-get install openjdk-11-jdk -y

# Create a user for Nexus (without creating a home directory)
sudo useradd -r -s /bin/bash -d /opt/nexus nexus

# Download Nexus (OSS version)
sudo mkdir -p /opt/nexus
cd /opt/nexus
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract the Nexus files
sudo tar -zxvf latest-unix.tar.gz --strip-components=1
sudo rm latest-unix.tar.gz

# Create the sonatype-work directory for Nexus data
sudo mkdir -p /opt/sonatype-work/nexus3
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Create a systemd service file for Nexus
cat <<EOF | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus run
User=nexus
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Nexus service
sudo systemctl enable nexus
sudo systemctl start nexus

# Open port 8081 in the firewall (if UFW is used)
sudo ufw allow 8081/tcp

# Print out the initial Nexus admin password
echo "Nexus installation complete. The initial admin password is:"
sudo cat /opt/sonatype-work/nexus3/admin.password