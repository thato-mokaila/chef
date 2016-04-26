#
# Cookbook Name:: ibm-db2
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#!/bin/bash

log "  Install DB2"
bash "install_db2_using_response_file" do
    code <<-EOH

groupadd db2grp1
groupadd db2fgrp1
groupadd dasadm1

useradd -g db2grp1 -m -d /home/db2inst1 db2inst1 -p db2inst1
useradd -g db2fgrp1 -m -d /home/db2fenc1 db2fenc1 -p db2fenc1
useradd -g dasadm1 -m -d /home/dasusr1 dasusr1 -p dasusr1

cd /tmp/db2_install/
tar -xvzf ./v10.5_linuxx64_expc.tar.gz
chmod -R 755 /tmp/db2_install
cd /tmp/db2_install/expc/

./db2setup -r /tmp/db2_install/db2-express.rsp
echo "db2inst1" | passwd db2inst1 --stdin

notifies :run, "execute[setup-ibm-java]", :immediately

su - db2inst1
db2start
    
EOH
end

log "  Configure Java"
bash "setup-ibm-java" do
code <<-EOH
    update-alternatives --install "/usr/bin/java" "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java" 0
    update-alternatives --set "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java"
EOH
action :nothing
end