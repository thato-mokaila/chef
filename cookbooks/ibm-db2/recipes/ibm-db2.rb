#
# Cookbook Name:: ibm-db2
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
# http://www.ibm.com/support/knowledgecenter/SSEPGG_9.7.0/com.ibm.db2.luw.qb.server.doc/doc/t0007067.html

# 1. Set up users and groups
# 2. Create a DB2 Administration Server
# 3. Create a DB2 instance
# 4. Create links to DB2 files
# 5. Configure TCP/IP communication
# 6. Configure services file
# 7. Update database manager
# 8. Set communications protocols
# 9. Apply license (already done, verifiable by db2licm -l)

# #####################################
# #####################################

# create group 'db2admin'
group 'db2iadm1'
group 'db2fadm1'
group 'dasadm1'

# #####################################
# #####################################

# add db2inst1 user
user 'db2inst1' do
    comment 'A user required to run DB2'
  	group 'db2iadm1'
    home '/home/db2inst1'
  	system true
  	shell '/bin/bash'
end

# add db2sdfe1 user
user 'db2fenc1' do
    comment 'A user required to run DB2'
  	group 'db2fadm1'
    home '/home/db2fenc1'
  	system true
  	shell '/bin/bash'
end

# add db2admin user
user 'db2admin' do
    comment 'A user required to run DB2'
  	group 'db2iadm1'
    home '/home/db2admin'
  	system true
  	shell '/bin/bash'
end

# #####################################
# #####################################

# create mq install directory
directory "/home/db2inst1" do
  owner 'db2inst1'
  group 'db2iadm1'
  mode '0755'
  action :create
end

# create mq install directory
directory "/home/db2fenc1" do
  owner 'db2fenc1'
  group 'db2fadm1'
  mode '0755'
  action :create
end

# create mq install directory
directory "/home/db2admin" do
  owner 'db2admin'
  group 'db2iadm1'
  mode '0755'
  action :create
end

# #####################################
# #####################################
#for db_user in db_users do
#
#    home = "/home/#{db_user}"
#
#    file "#{home}/.profile" do
#        owner db_user
#    end
#
#    execute "/opt/ibm/db2/V10.5/instance/db2icrt -s client #{db_user}" do
#        creates "#{home}/sqllib"
#    end
#
#    execute "#{home}/sqllib/bin/db2 catalog tcpip node #{db_node} remote localhost server 50000" do
#        user db_user
#        ignore_failure true   
#    end
#
#    execute "#{home}/sqllib/bin/db2 catalog database #{db_database} as #{db_database} at node #{db_node}" do
#        user db_user
#        ignore_failure true   
#    end
#
#    execute "#{home}/sqllib/bin/db2 terminate" do
#        user db_user
#        ignore_failure true   
#    end
#
#    execute "cp #{home}/.profile #{home}/.bashrc" do
#        creates "#{home}/.bashrc"
#    end
#
#end
# #####################################
# #####################################

# update kernel parameters
bash "update_kernel_parameters" do
code <<-EOH
sysctl -w kernel.sem=250 256000 32 4096
sysctl -w kernel.msgmnb=65536
sysctl -w kernel.msgmax=65536
sysctl -w kernel.msgmni=8192
sysctl -w kernel.shmmni=2048
sysctl -w kernel.shmall=8192
sysctl -w kernel.shmmax=8589934592
EOH
end

log "# installing DB2 Express C v10.5 using response file - /tmp/db2_install/db2-express.rsp ..."
bash "install_db2_using_response_file" do
    code <<-EOH

export PATH=/opt/ibm/db2/V10.5/bin/:$PATH 

cd /tmp/db2_install/
tar -xvzf ./v10.5_linuxx64_expc.tar.gz
chmod -R 755 /tmp/db2_install
cd /tmp/db2_install/expc/

./db2setup -r /tmp/db2_install/db2-express.rsp
. /home/db2inst1/sqllib/db2profile

echo "db2inst1" | passwd db2inst1 --stdin
echo "db2admin" | passwd db2admin --stdin

#su -c "/opt/ibm/db2/V10.5/bin/db2sampl" db2admin

echo "# ******************************************* #" 
echo "# Restoring LUNOSDEV using image file #" 
echo "# ******************************************* #" 

su -c "db2 create database LUNOSDEV using codeset UTF-8 TERRITORY US;" db2inst1
su -c "db2 restore database LUNOSDEV from /tmp/db2_install/images taken at 20160421155601 without prompting;" db2inst1

echo "# ******************************************* #" 
echo "# LUNOSDEV build successfully #" 
echo "# ******************************************* #" 

su -c "/home/db2inst1/sqllib/bin/db2 catalog tcpip node NODE000 remote localhost server 50000" db2inst1
su -c "/home/db2inst1/sqllib/bin/db2 catalog database SAMPLE as SAMPLE at node NODE000 authentication server" db2inst1
#su -c "/home/db2inst1/sqllib/bin/db2 catalog database LUNOSDEV as LUNOSDEV at node NODE000 authentication server" db2inst1

#/opt/ibm/db2/v10.5/instance/dascrt -u db2admin
#/opt/ibm/db2/v10.5/instance/db2icrt -a server -u db2fenc1 db2inst1
#/opt/ibm/db2/v10.5/instance/db2ln
    
EOH
end

log "# configuring DB2 Express C v10.5 java environment"
bash "setup-ibm-java" do
code <<-EOH
    update-alternatives --install "/usr/bin/java" "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java" 0
    update-alternatives --set "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java"
EOH
action :nothing
end

#execute_as_user "db2admin start" do
#  user node[:db2][:instance][:username]
#  action :run
#end

