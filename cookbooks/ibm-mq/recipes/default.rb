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
    setenv.sh
  EOH
end