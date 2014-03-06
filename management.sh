#!/bin/bash

function scriptUpdate {
        wget "https://raw.github.com/jewm/jasdh/master/management.sh" -O "management_new_version.sh" -nv

        diff -q "management.sh" "management_new_version.sh" 1>/dev/null
        if [[ $? == "0" ]]; then
                echo "No update required"
                rm "management_new_version.sh"
        else
                echo "Update required"
                rm "management.sh"
                mv "management_new_version.sh" "management.sh"
                chmod +x "management.sh"
                echo "Upload succesful > restart script"
                ./management.sh
        fi
}

function startServer {
	echo "Starting server..."
	$APPLICATION_SERVER_START
	echo "Server started"
}

function stopServer {
	echo "Stopping server..."
	$APPLICATION_SERVER_STOP
	echo "Server stopped"
}

function serverStatus {
	$APPLICATION_SERVER_STATUS
}

function deploy {
	echo "Start deployment"

        if [ ! -f "$WAR_PATH$CURRENT_WAR_NAME" ]; then
        	echo "$CURRENT_WAR_NAME not found"
        	echo "Deployment aborted"
        	exit 1;
        fi

	if [ ! -d $WEBAPPS_PATH ]; then
		echo "$WEBAPPS_PATH not found"
		echo "Deployment aborted"
		exit 1;
	fi

	stopServer

	if [ ! -d $WAR_BACKUP_PATH ]; then
		mkdir -p $WAR_BACKUP_PATH
		echo "Backup-folder created"
	fi

	if [ -f "$WEBAPPS_PATH$FINAL_WAR_NAME" ]; then
		mv "$WEBAPPS_PATH$FINAL_WAR_NAME" "$WAR_BACKUP_PATH$(date +"%Y-%m-%d-%H:%M").war"
		echo "Old war saved"
	fi

	rm -rf "$WEBAPPS_PATH*"
	echo "Webapps-folder cleared"

	cp "$WAR_PATH$CURRENT_WAR_NAME" "$WEBAPPS_PATH$FINAL_WAR_NAME"
	echo "New war moved"

#	if [ "$2" = "--auto-rollback" ]; then
#		echo "Rollback on failure"
#	fi

	startServer

#	if [ ! $APPLICATION_RUNNING ]; then
#		if [ "$2" = "--auto-rollback" ]; then
#			echo "Rollback on failure"
#		fi
#	fi

	echo "Deployment finished"
}


if [ $AUTO_UPDATE_ENABLED = 1 ]; then

        scriptUpdate
fi

case "$1" in
	start)
		startServer
	;;

	stop)
		stopServer
	;;

	restart)
		stopServer
		startServer
	;;

	status)
		serverStatus
	;;

	deploy)
		deploy
	;;
esac
