#!/bin/bash

# Chef Server
# wget https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-server-11.0.10-1.el6.x86_64.rpm
# rpm -Uvh chef-server-11.0.10-1.el6.x86_64.rpm

#chef_binary=/usr/local/bin/chef-solo
chec_solo=/usr/bin/chef-solo

# Are we on a vanilla system?
if ! type "$chec_solo" > /dev/null; then
	# update system to latest
	yum -y update
	yum -y install gcc ruby-devel rubygems git tree
	# chef client
	curl -L https://www.opscode.com/chef/install.sh | sudo bash
fi &&

# goto working directory
cd /var 

# check out cookbooks into working directory
git clone https://github.com/thato-mokaila/chef.git
chmod -R 755 ./chef && cd ./chef/ 
cp ./chef/mq/config/qm.ini.tmp /tmp/mq_install
cp ./chef/mq/config/config.mqsc /tmp/mq_install

# run chef to prep the system
"$chec_solo" -c solo.rb -j node.json
