#
# Cookbook Name:: ibm-mq
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#
script "prepare_mq_environment" do
  interpreter "bash"
  user "root"
  cwd "#{node['mq']['install_script_dir']}"
  code <<-EOH
    #insert bash script
	export WMQ_INSTALL_DIR=/opt/mqm
	export LD_LIBRARY_PATH=$WMQ_INSTALL_DIR/java/lib64
	export JAVA_HOME=$WMQ_INSTALL_DIR/java/jre64/jre
	export PATH=$PATH:$WMQ_INSTALL_DIR/bin:$JAVA_HOME/bin
	export QM=QM1
	export PORT=1414
	export REQUESTQ=REQUEST_Q
	export REPLYQ=REPLY_Q
	export INSTALL_USER=developer
	export MQ_EXLPODED_DIR=MQServer
  EOH
end