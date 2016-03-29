
if ::File.exist?("/tmp/vagrant-chef-1/client.rb")
  ruby_block "Copy Chef config file if running in a Vagrant guest" do
   block do
    ::FileUtils.cp "/tmp/vagrant-chef-1/client.rb", "#{node['chef-client']['conf_dir']}/client.rb"
   end
   if ::File.exist?("#{node['chef-client']['conf_dir']}/client.rb")
     not_if { ::FileUtils.compare_file("/tmp/vagrant-chef-1/client.rb", "#{node['chef-client']['conf_dir']}/client.rb") }
   end
  end
end