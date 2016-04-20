#
# Cookbook Name:: ibm-db2
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

# create group 'db2sdfe1'
group 'db2fsdm1'

# create group 'db2admin'
group 'db2admin'

# add db2sdfe1 user
user 'db2fsdm1' do
    comment 'A user required to run DB2'
  	group 'db2fsdm1'
    home '/home/db2fsdm1'
  	system true
  	shell '/bin/bash'
end

# add db2admin user
user 'db2admin' do
    comment 'A user required to run DB2'
  	group 'db2admin'
    home '/home/db2admin'
  	system true
  	shell '/bin/bash'
end

# create mq install directory
directory "/home/db2fsdm1" do
  owner 'db2fsdm1'
  group 'db2fsdm1'
  mode '0755'
  action :create
end

# create mq install directory
directory "/home/db2admin" do
  owner 'db2admin'
  group 'db2admin'
  mode '0755'
  action :create
end

# update kernel parameters
bash "update_kernel_parameters" do
code <<-EOH
sysctl -w kernel.sem=250 256000 32 4096
sysctl -w kernel.msgmnb=65536
sysctl -w kernel.msgmax=65536
sysctl -w kernel.msgmni=16384
sysctl -w kernel.shmmni=4096
sysctl -w kernel.shmall=8388608
sysctl -w kernel.shmmax=17179869184
EOH
end

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