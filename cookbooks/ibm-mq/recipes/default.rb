#
# Cookbook Name:: ibm-mq
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.debug "Output: #{ output.stdout }"
::Chef::Recipe.send(:include, MQCookbook::Helper)

# create group 'mqm'
group node[:MQ][:USER][:GROUP]

# add mq install user
user node[:MQ][:USER][:NAME] do
	comment 'A user required to install MQ'
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