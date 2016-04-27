rightscale_marker :begin

log "Starting DB2"

execute_as_user "db2start" do
    user "db2inst1"
  action :run
end

rightscale_marker :end