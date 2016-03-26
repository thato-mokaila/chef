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

# prep mq environment
bash "prepare_mq_environment" do
  code <<-EOH
    echo "# Exporting variables..."
	export LD_LIBRARY_PATH="#{node[:MQ][:WMQ_INSTALL_DIR]}/java/lib64"
	export JAVA_HOME="#{node[:MQ][:WMQ_INSTALL_DIR]}/java/jre64/jre"
	export PATH="#{ENV['PATH']}:#{node[:MQ][:WMQ_INSTALL_DIR]}/bin:#{ENV['JAVA_HOME']}/bin"
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

# update user limits
bash "update_kernel_parameters" do
  code <<-EOH
    echo "# updating kernel parameters..."
    sysctl -w fs.file-max=#{node[:MQ][:FDMAX]}
    sysctl -w net.ipv4.ip_local_port_range='1024 65535'
    sysctl -w vm.max_map_count=1966080
    sysctl -w kernel.pid_max=4194303
    sysctl -w kernel.sem='1000 1024000 500 8192'
    sysctl -w kernel.msgmnb=131072
    sysctl -w kernel.msgmax=131072
    sysctl -w kernel.msgmni=2048
    sysctl -w kernel.shmmni=8192
    sysctl -w kernel.shmall=536870912
    sysctl -w kernel.shmmax=137438953472
    sysctl -w net.ipv4.tcp_keepalive_time=300
    echo "# Finished udating kernel parameters ..."
  EOH
end

# update user limits
bash "install_mq" do
  code <<-EOH

    echo "# installing  WebSphere MQ 8.0 Developers Edition..."
    
    mkdir #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/wmq_install_unzipped | true
    cd #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/wmq_install_unzipped
    tar xvf #{node[:MQ][:SOURCE][:DOWNLOAD][:PATH]}/#{node[:MQ][:SOURCE][:FILENAME]}
    cd #{node[:MQ][:MQ_EXLPODED_DIR]}

    # Accept IBM license
	./mqlicense.sh -accept

	# install MQ binaries
	rpm --prefix $WMQ_INSTALL_DIR -ivh MQSeriesRuntime-*.rpm MQSeriesServer-*.rpm MQSeriesClient-*.rpm MQSeriesSDK-*.rpm  MQSeriesMan-*.rpm MQSeriesSamples-*.rpm MQSeriesJRE-*.rpm MQSeriesExplorer-*.rpm MQSeriesJava-*.rpm

	# Define this as a primary installation
	#{node[:MQ][:WMQ_INSTALL_DIR]}/bin/setmqinst -i -p #{node[:MQ][:WMQ_INSTALL_DIR]}

	# Show the version of WMQ that we just installed
	#{node[:MQ][:WMQ_INSTALL_DIR]}/bin/dspmqver

    echo "# Finished installing  WebSphere MQ 8.0 Developers Edition..."

  EOH
end

