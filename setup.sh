#!/bin/bash
sudo apt-get update && sudo apt-get install -y git
sudo mkdir /src && sudo chown -R ubuntu:ubuntu /src
cd /src && git clone https://github.com/openstack-dev/devstack
cp -rvf /tmp/local.conf /src/devstack/
cd /src/devstack/ && ./stack.sh
