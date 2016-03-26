#
# Cookbook Name:: ibm-mq
# Recipe:: default
#
# Copyright 2016, Elten Group (Pty) Ltd.
#
# All rights reserved - Do Not Redistribute
#

bash 'set_mq_environment' do
  cwd ::File.dirname(node[:mq][:install_script_dir])
  code <<-EOH
    ./setenv.sh
    EOH
end

bash 'install_websphere_mq' do
  cwd ::File.dirname(node[:mq][:install_script_dir])
  code <<-EOH
    ./mqinstall.sh
    EOH
end