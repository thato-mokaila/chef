rightscale_marker :begin

log "Starting DB2 Administration Server"

execute_as_user "db2admin start" do
    user "db2inst1"
  action :run
end

rightscale_marker :end