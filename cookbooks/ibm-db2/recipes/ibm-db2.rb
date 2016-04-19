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

cd /tmp/db2_install/
tar -xvzf ./v10.5_linuxx64_expc.tar.gz
chmod -R 755 /tmp/db2_install
cd expc/
./db2setup -r /tmp/db2_install/db2-express.rsp
    
EOH
end