#!/bin/bash

# Chef Server
# wget https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-server-11.0.10-1.el6.x86_64.rpm
# rpm -Uvh chef-server-11.0.10-1.el6.x86_64.rpm

#chef_binary=/usr/local/bin/chef-solo
chec_solo=/usr/bin/chef-solo

# Are we on a vanilla system?
if ! type "$chec_solo" > /dev/null; then

	# update system to latest
	yum update

	yum -y install gcc ruby-devel rubygems git

	# Chef Client
	curl -L https://www.opscode.com/chef/install.sh | sudo bash

fi &&

# goto working directory
cd /var && mkdir -p /tmp/mq_install/scripts

# check out cookbooks into working directory
git clone https://github.com/thato-mokaila/chef.git
chmod -R 755 ./chef && cd ./chef/ 
cp -r ./scripts/mq/ /tmp/mq_install/scripts

# run chef to prep the system
"$chec_solo" -c solo.rb -j node.json