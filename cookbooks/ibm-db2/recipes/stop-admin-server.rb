rightscale_marker :begin

log "Stopping DB2 Administration Server"

execute_as_user "db2admin stop" do
    user "db2inst1"
  action :run
end

rightscale_marker :end