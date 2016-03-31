#
# Cookbook Name:: ibm-mq
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

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