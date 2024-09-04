#!/bin/bash

# Update the package manager
sudo apt-get update -y

# Install required dependencies
sudo apt-get install -y openjdk-11-jdk wget unzip

# Download and install SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip
sudo unzip sonarqube-9.6.1.59531.zip
sudo mv sonarqube-9.6.1.59531 sonarqube
sudo useradd -m -d /opt/sonarqube sonarqube

# Set permissions
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Start SonarQube
sudo -u sonarqube /opt/sonarqube/bin/linux-x86-64/sonar.sh start

# Enable SonarQube to start on boot
sudo bash -c 'cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Start and enable the SonarQube service
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

# Open the firewall port 9000 if UFW is enabled
sudo ufw allow 9000/tcp
