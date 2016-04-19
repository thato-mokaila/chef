#
# Cookbook Name:: ibm-db2
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

# install db2
bash "install_db2_using_response_file" do
    code <<-EOH

	echo "#**********************************************************"
    echo "# installing DB2 Express C v10.5 ...					     "
	echo "#**********************************************************"

./db2setup.sh -r /tmp/db2_install/db2-express.rsp
    
EOH
end