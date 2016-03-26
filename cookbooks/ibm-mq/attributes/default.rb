
default[:MQ][:WMQ_INSTALL_DIR] = "/opt/mqm"
default[:MQ][:INSTALL_SCRIPT_DIR] = "/tmp/mq_install/scripts"
default[:MQ][:INSTALL_SCRIPT] = "mqinstall.sh"

default[:MQ][:LD_LIBRARY_PATH] = ""
default[:MQ][:JAVA_HOME] = ""
default[:MQ][:PATH] = ""
default[:MQ][:QM] = "DEV_QM"
default[:MQ][:PORT] = "1414"
default[:MQ][:REQUESTQ] = "REQUEST_Q"
default[:MQ][:REPLYQ] = "REPLY_Q"
default[:MQ][:INSTALL_USER] = "developer"
default[:MQ][:MQ_EXLPODED_DIR] = "MQServer"

default[:MQ][:USER][:NAME] = "mqm"
default[:MQ][:USER][:GROUP] = "mqm"
default[:MQ][:GROUP][:HOME] = "/home/mqm"

default[:MQ][:QUEUE_BUFFER_SIZE] = "1048576"
default[:MQ][:LOG_BUFFER_PAGES] = "512"
default[:MQ][:LOG_PRIMARY_FILES] = "16"
default[:MQ][:LOG_FILE_PAGES] = "16384"
default[:MQ][:MAX_HANDLES] = "50000"
default[:MQ][:FDMAX] = "1048576"

default[:MQ][:QMGR][:DATAPATH] = "/var/mqm/DEV_QM_DATA"
default[:MQ][:QMGR][:LOGPATH]	 = "/var/mqm/DEV_QM_LOG"

default[:MQ][:SOURCE][:URL] = "http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev80_linux_x86-64.tar.gz"
default[:MQ][:SOURCE][:FILENAME] = "mqadv_dev80_linux_x86-64.tar.gz"
default[:MQ][:EXPLODED][:DIR] = "mqadv_dev80_linux_x86-64.tar.gz"
default[:MQ][:SOURCE][:DOWNLOAD][:PATH] = "/tmp/mq_install"

