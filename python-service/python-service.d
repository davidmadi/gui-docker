#!/bin/bash
### BEGIN INIT INFO
# Provides:          python-service
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: My custom service
# Description:       A custom service script.
### END INIT INFO

case "$1" in
    start)
        echo "Starting python-service"
        # Command to start your service
        /usr/local/bin/python-service.sh
        ;;
    stop)
        echo "Stopping python-service"
        # Command to stop your service
        pkill -f /usr/local/bin/python-service.sh
        ;;
    restart)
        echo "Restarting python-service"
        $0 stop
        $0 start
        ;;
    status)
        # This is optional but useful to check if the script is running
        if pgrep -f /usr/local/bin/python-service.sh > /dev/null
        then
            echo "Script is running."
        else
            echo "Script is not running."
        fi
        ;;        
    *)
        echo "Usage: /etc/init.d/python-service {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0