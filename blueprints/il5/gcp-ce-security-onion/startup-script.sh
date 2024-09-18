#!/bin/bash
#Update and install necessary packages
sudo yum update
sudo yum -y install git
git clone https://github.com/Security-Onion-Solutions/securityonion
cd securityonion
# sudo bash so-setup-network
