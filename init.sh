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

	yum install -y gcc ruby-devel rubygems git

	# Chef Client
	curl -L https://www.opscode.com/chef/install.sh | sudo bash

	#gem update --no-rdoc --no-ri
	#gem install chef --no-rdoc --no-ri
fi &&

"$chec_solo" -c solo.rb -j solo.json