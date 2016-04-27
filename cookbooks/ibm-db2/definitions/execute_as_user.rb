define :execute_as_user, :user => "root", :command => nil do
  log params.inspect
  execute params[:name] do
    command "su - #{params[:user]} -c \"#{params[:command] || params[:name]}\""
	params.delete_if { |key, value| [:user, :command].include?(key) }.each do |meth, value|
	  send(meth, value)
	end
  end
end