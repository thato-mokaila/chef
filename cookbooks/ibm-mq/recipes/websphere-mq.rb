#
# Cookbook Name:: ibm-mq
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

#Chef::Log.debug "Output: #{ output.stdout }"
#Chef::Recipe.send(:include, MQCookbook::Helper)

# rebbot node
reboot 'reboot_machine' do
  action :nothing
  reason 'Cannot continue Chef run without a reboot.'
  delay_mins 1
end

# create group 'mqm'
group node[:MQ][:USER][:GROUP]

# add mq user
user node[:MQ][:USER][:NAME] do
	comment 'A user required to run MQ'
  	group node[:MQ][:USER][:GROUP]
  	home node[:MQ][:USER][:HOME]
  	system true
  	shell '/bin/bash'
end

# add root to mqm before any sub-processes
group node[:MQ][:USER][:GROUP] do
  action :modify
  members 'root'
  append true
end

ENV['LD_LIBRARY_PATH'] = "#{node[:MQ][:WMQ_INSTALL_DIR]}/java/lib64"
ENV['JAVA_HOME'] = "#{node[:MQ][:WMQ_INSTALL_DIR]}/java/jre64/jre"
ENV['PATH'] = "#{ENV['PATH']}:#{node[:MQ][:WMQ_INSTALL_DIR]}/bin:#{ENV['JAVA_HOME']}/bin"

# prep mq environment
bash "prepare_mq_environment" do
    code <<-EOH

	echo "#**********************************************************"
    echo "# Environment Variables 								     "
	echo "#**********************************************************"

	echo "#**********************************************************"
    export LD_LIBRARY_PATH=#{node[:MQ][:WMQ_INSTALL_DIR]}/java/lib64
    export JAVA_HOME=#{node[:MQ][:WMQ_INSTALL_DIR]}/java/jre64/jre
    export PATH=#{ENV['PATH']}:#{node[:MQ][:WMQ_INSTALL_DIR]}/bin:#{ENV['JAVA_HOME']}/bin
	echo "#**********************************************************"

	echo "# Finished exporting variables..."
    
EOH
end

# update user limits
file "/etc/security/limits.d/#{node[:MQ][:USER][:NAME]}.conf" do
    content "
        #{node[:MQ][:USER][:NAME]} soft nofile #{node[:MQ][:FDMAX]}
        #{node[:MQ][:USER][:NAME]} hard nofile #{node[:MQ][:FDMAX]}
        #{node[:MQ][:USER][:NAME]} soft nproc #{node[:MQ][:FDMAX]}
        #{node[:MQ][:USER][:NAME]} hard nproc #{node[:MQ][:FDMAX]}
      "
    mode '0755'
    owner 'mqm'
    group 'mqm'
end

# update user limits [root]
file "/etc/security/limits.d/root.conf" do
    content "
        root soft nofile #{node[:MQ][:FDMAX]}
        root hard nofile #{node[:MQ][:FDMAX]}
        root soft nproc #{node[:MQ][:FDMAX]}
        root hard nproc #{node[:MQ][:FDMAX]}
      "
    mode '0755'
    owner 'root'
    group 'root'
end

# update kernel parameters
bash "update_kernel_parameters" do
code <<-EOH
sysctl -w fs.file-max=#{node[:MQ][:FDMAX]}
sysctl -w net.ipv4.ip_local_port_range='1024 65535'
sysctl -w vm.max_map_count=#{node[:MQ][:MAX_MAP_COUNT]}
sysctl -w kernel.pid_max=#{node[:MQ][:PID_MAX]}
sysctl -w kernel.sem='1000 1024000 500 8192'
sysctl -w kernel.msgmnb=#{node[:MQ][:MSGMNB]}
sysctl -w kernel.msgmax=#{node[:MQ][:MSGMAX]}
sysctl -w kernel.msgmni=#{node[:MQ][:MSGMNI]}
sysctl -w kernel.shmmni=#{node[:MQ][:SHMMNI]}
sysctl -w kernel.shmall=#{node[:MQ][:SHMALL]}
sysctl -w kernel.shmmax=#{node[:MQ][:SHMAX]}
sysctl -w net.ipv4.tcp_keepalive_time=#{node[:MQ][:NET_IPV4_TCP_KEEPALIVE_TIME]}
EOH
end

# create mq install directory
directory "#{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/wmq_install_unzipped" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# install websphere mq
bash "install_websphere_mq" do
code <<-EOH
echo #*****************************************************************************"
echo " Installation Summary "
echo #*****************************************************************************"
echo " This script will install WebSphere MQ on your Linux OS"
echo " Read more about this script here: http://WhyWebSphere.com"
echo " Today's date: `date`"
echo " Here are the default values used in the script (feel free to change these):"
echo "   Insalling user:            `whoami`"
echo "   WebSphere MQ Install Path: #{node[:MQ][:WMQ_INSTALL_DIR]}"
echo "   Queue Manager Name:        #{node[:MQ][:QM]}"
echo "   Queue Mgr Listener Port:   #{node[:MQ][:PORT]}"
echo "   Queue Mgr Data Path:       #{node[:MQ][:QMGR][:DATAPATH]}"
echo "   Queue Mgr Log Path:        #{node[:MQ][:QMGR][:LOGPATH]}"
echo "   Test Queue #1:             #{node[:MQ][:REQUESTQ]}"
echo "   Test Queue #2:             #{node[:MQ][:REPLYQ]}"
echo "   WMQ installation image:    #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/#{node[:MQ][:SOURCE][:FILENAME]}"
echo #*****************************************************************************"

echo "# installing  WebSphere MQ 8.0 Developers Edition..."
#wget #{node[:MQ][:SOURCE][:URL]} -O #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/#{node[:MQ][:SOURCE][:FILENAME]}

# temp
cp /tmp/#{node[:MQ][:SOURCE][:FILENAME]} #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}

cd #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/wmq_install_unzipped
tar xvf #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/#{node[:MQ][:SOURCE][:FILENAME]}
cd #{node[:MQ][:MQ_EXLPODED_DIR]}

# Accept IBM license
./mqlicense.sh -accept

# install MQ binaries
rpm --prefix #{node[:MQ][:WMQ_INSTALL_DIR]} -ivh MQSeriesRuntime-*.rpm MQSeriesServer-*.rpm MQSeriesClient-*.rpm MQSeriesSDK-*.rpm  MQSeriesMan-*.rpm MQSeriesSamples-*.rpm MQSeriesJRE-*.rpm MQSeriesExplorer-*.rpm MQSeriesJava-*.rpm
EOH
end

# define this as a primary installation
execute 'define_mq_primary_installation' do
    command "#{node[:MQ][:WMQ_INSTALL_DIR]}/bin/setmqinst -i -p #{node[:MQ][:WMQ_INSTALL_DIR]}"
    user 'root'
end

# display mq version
execute 'display_mq_version' do
    command "#{node[:MQ][:WMQ_INSTALL_DIR]}/bin/dspmqver"
    user 'root'
end

# create queue manager data directories /var/mqm/LOCALQUEMGR_DATA
directory "#{node[:MQ][:QMGR][:DATAPATH]}" do
    owner 'mqm'
    group 'mqm'
    mode '0755'
    action :create
    ignore_failure true
end

# create queue manager log directories /var/mqm/LOCALQUEMGR_LOG
directory "#{node[:MQ][:QMGR][:LOGPATH]}" do
    owner 'mqm'
    group 'mqm'
    mode '0755'
    action :create
    ignore_failure true
    #notifies :reboot_now, 'reboot[reboot_machine]', :immediately
end

# create queue manager
bash "create_queue_manager" do
code <<-EOL
    su -c "crtmqm -q -u SYSTEM.DEAD.LETTER.QUEUE -h #{node[:MQ][:MAX_HANDLES]} -lc -ld #{node[:MQ][:QMGR][:LOGPATH]} -lf #{node[:MQ][:LOG_FILE_PAGES]} -lp #{node[:MQ][:LOG_PRIMARY_FILES]} -md #{node[:MQ][:QMGR][:DATAPATH]} #{node[:MQ][:QM]}" mqm
EOL
end

# start queue manager
bash "start_queue_manager" do
code <<-EOL
    su -c "strmqm -c #{node[:MQ][:QM]}" mqm
EOL
end

# modify qm.ini.tmp group and permissions
bash "modify_mq_ini_file" do
code <<-EOL
    chown mqm:mqm /tmp/mq_install/qm.ini.tmp
EOL
end

# overiding default configuration
bash "overiding_default_configuration" do
code <<-EOL
    yes | cp /tmp/mq_install/qm.ini.tmp #{node[:MQ][:QMGR][:DATAPATH]}/#{node[:MQ][:QM]}/qm.ini
EOL
end

# start queue manager
bash "start_queue_manager" do
code <<-EOL
    su -c "strmqm #{node[:MQ][:QM]}" mqm
EOL
end

# configure queue manager
bash "configure_queue_manager" do
code <<-EOL
    su -c "runmqsc #{node[:MQ][:QM]} < /tmp/mq_install/config.mqsc" mqm
EOL
end

# stop queue manager
bash "stop_queue_manager" do
code <<-EOL
    su -c "endmqm -i #{node[:MQ][:QM]}" mqm
EOL
end

# start queue manager
bash "start_queue_manager" do
code <<-EOL
    su -c "strmqm #{node[:MQ][:QM]}" mqm
EOL
end

# complete
bash "display_complete_status" do
    code <<-EOH
	echo "---------------------------------------------------------------------------"
	echo " SUCCESS: WMQ installation, setup and test are complete."
	echo " To test your message queues you may want to run this script: ./mqtest.sh"
	echo "---------------------------------------------------------------------------"
EOH
end

