#
# Cookbook Name:: ibm-mq
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "#{node['mq']['install_script_dir']}/setenv.sh" do
  source "setenv.sh"
  mode 0755
end

execute 'set_mq_environment' do
  command "sh #{node['mq']['install_script_dir']}/setenv.sh"
end