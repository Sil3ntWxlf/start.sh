#!/bin/bash

# Offered under MIT license
# USING THIS SCRIPT TO START YOUR SERVER SIGNIFIES YOU WILL COMPLY WITH MOJANG'S EULA.

service="<server>" # Name of the service
initialRam="4G" # RAM the server will start with
maximumRam="4G" # RAM the server will try to limit itself to
maxPlayers="256" # Maximum player count (overrides server.properties)
serverPort="25565" # Server port (overrides server.properties) ** DOES NOT FUNCTION WITH WATERFALL OR Velocity. Set these in config.yml after you've started and stopped it once **
bindingAddress="0.0.0.0" # Bind address (overrides server.properties) ** DOES NOT FUNCTION WITH WATERFALL OR Velocity. Set these in config.yml after you've started and stopped it once **
restartDelay="10" # Wait this long before restarting (0 to just hard-exit the server on stop, -1 to wait for user input to restart)

# Check for jar updates every this many days (determined from server jar's last downloaded date)
# Disable by setting to 0, but set the jarfile variable properly!
updateCheckInterval="3" # DO NOT SET THIS BELOW 3! Seriously!
jarFile="paperclip.jar" # Name of the jarfile (if it's updatable dynamically it'll be updated)
# Supported auto-update jar names
#  - "velocity.jar" - Velocity's latest 1.19.2 jar - * Proxy * - * Recommended proxy *
#  - "paperclip.jar" - PaperMC's latest 1.19.2 paperclip version (Update regularly!)

# Server folder cleanups
# only executed at server start, set to 0 to disable
daysToCleanLogs="0" # logs older than this many days are removed
daysToCleanFtbBackups="0" # FTB (most FTB modpack servers use this mod) server backups older than this many days are removed
daysTocleanLPData="0" # Cleans out LuckPerms userdata

# 1 = enable, 0 = disable
cleanHsErrLogs="0" # clean all hard-crash logs made by java
cleanCacheJars="0" # clean Paperclip cache jars
cleanProxyModules="0" # clean proxied module jars
cleanOpsList="0" # remove op perms from all known players
cleanWhiteList="0" # de-whitelist all players
cleanUsercache="0" # remove the UUID/username cache file

# Execution options
processname="java" # point this at your java binary

# For most minecraft servers
jvmArgs="-Xms$initialRam -Xmx$maximumRam -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar"
jarCmdline="--host $bindingAddress --port $serverPort --max-players $maxPlayers nogui -W worlds" # Adding -W <folder> puts worlds there instead of in ./*
processargs="-Dgamemode=$service -server $jvmArgs -jar $jarFile $jarCmdline"

# For Proxy only
# Comment the above lines out and uncomment these if you're using this for a velocity instance
# jvmArgs="-XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15"
# processargs="-Dgamemode=$service -server -Xms$initialRam -Xmx$maximumRam -Xmn512M $jvmArgs -Dfile.encoding=UTF-8 -jar $jarFile"

# Remote jar locations
velocityJarUrl="https://api.papermc.io/v2/projects/velocity/versions/3.1.2-SNAPSHOT/builds/169/downloads/velocity-3.1.2-SNAPSHOT-169.jar" # Velocity 1.19.2
paperclipJarUrl="https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/113/downloads/paper-1.19.2-113.jar" # Paperclip 1.19.2

# End configuration

# If you touch what's below here, it could vaporize your cat!

if [[ ! $(whoami) == '<user>' ]]; then # prevent people from running stuff under the wrong users
	clear
	echo -e "$(toilet "HEY!")\nDon't run this script as the wrong user!"| lolcat
	exit 1
fi

countdown(){
	local OLD_IFS="${IFS}"
	IFS=":"

	local ARR
	# shellcheck disable=SC2206
	ARR=( $1 )

	local SECONDS
	SECONDS=$((  (ARR[0] * 60 * 60) + (ARR[1] * 60) + ARR[2]  ))

	local START
	START=$(date +%s)

	local END
	END=$((START + SECONDS))

	local CUR
	CUR=$START

	while [[ $CUR -lt $END ]]
	do
		CUR=$(date +%s)
		LEFT=$((END-CUR))
		printf "\r%02d:%02d:%02d" \
			$((LEFT/3600)) $(( (LEFT/60)%60)) $((LEFT%60))
		sleep 1
	done
	IFS="${OLD_IFS}"
	echo "        "
}

cleanServer(){ # Clean up our server files
	echo "cleanServer: Cleaning!"
	if [[ $daysToCleanLogs != "0" ]];then
		echo "cleanServer: Cleaned $(find logs/ -maxdepth 1 -type f -mtime +"$daysToCleanLogs" -name '*.log.gz' -delete | wc -l) server logs older than $daysToCleanLogs days."
	fi

	if [[ $daysToCleanFtbBackups != "0" ]];then
		echo "cleanServer: Cleaned $(find backups/ -maxdepth 1 -type d -mtime +"$daysToCleanLogs" -name '*.log.gz' -delete | wc -l) FTB backups older than $daysToCleanFtbBackups days."
	fi

	if [[ "$daysTocleanLPData" != "0" ]];then
      echo "cleanServer: Cleaned $(find plugins/LuckPerms/perms/ -maxdepth 1 -type f -mtime +"$daysTocleanLPData" -name 'perms' -delete | wc -l) LuckPerms userdata older than $daysTocleanLPData days."
  fi

	if [[ $cleanCacheJars != "0" ]]; then
		rm -rf cache/
		echo "cleanServer: Cleaned Paperclip cached jars."
	fi

	if [[ $cleanProxyModules != "0" ]]; then
		rm -rf modules/ modules.yml
		echo "cleanServer: Cleaned Proxy cached jars."
	fi

	if [[ $cleanHsErrLogs != "0" ]]; then
		echo "cleanServer: Cleaned $(rm -vf hs_err_pid* | wc -l) Java hard-crash logs."
	fi

	if [[ $cleanOpsList != "0" ]]; then
		rm "ops.json"
		echo "cleanServer: Deopped all players."
	fi

	if [[ $cleanWhiteList != "0" ]]; then
		rm "whitelist.json"
		echo "cleanServer: Dewhitelisted all players."
	fi

	if [[ $cleanUsercache != "0" ]]; then
		rm "usercache.json"
		echo "cleanServer: Flushed user cache."
	fi

	echo "cleanServer: Complete!"
}

jarUpdate(){ # Update our server's jars and a few other things

	if [[ $updateCheckInterval != "0" ]]; then
		if [[ ! -f "$jarFile" ]] || [[ $(find "$jarFile" -mtime +"$updateCheckInterval" -print) ]]; then
			doJarUpdate
		else
			echo "jarUpdate: not updating jar (too young)"
		fi
	else
		echo "jarUpdate: not updating jar (config override)"
	fi
}

doJarUpdate() { # Moved so forcing jar updates is a little less of a mess
	echo "jarUpdate: attempting to update server jar..."

	if   [[ "$jarFile" == "paperclip.jar" ]]; then # paperclip 1.17.1
		rm -rf cache/ # Special part because paperclip creates caches of a couple jarfiles
		echo "jarUpdate: updating $jarFile with latest version..."
		wget --no-use-server-timestamps -q --show-progress --no-check-certificate -O "$jarFile" "$paperclipJarUrl"

	elif [[ "$jarFile" == "velocity.jar" ]]; then # velocity 1.17.1
		rm -rf modules/ modules.yml cache/
		echo "jarUpdate: updating $jarFile with latest version..."
		wget --no-use-server-timestamps -q --show-progress --no-check-certificate -O "$jarFile" "$velocityJarUrl"

	else # Jar not recognized
		echo "jarUpdate: not updating jar (non-standard jarfile named or CI server unavailable)"
	fi
}

freePort() { # Forcibly frees server's running port just in case it wasn't cleanly stopped or some real bad things happened.
	echo "freePort: Attempting to forcibly unbind port. If this asks for a password, contact your systems administrator."
	# Needs '<yourusername> ALL=(ALL:ALL) NOPASSWD: /bin/fuser' in /etc/sudoers
	# This will grant this user to use the command fuser without a password being asked.
	# You should be fully apprised of what 'fuser' does before allowing anyone you don't trust to access this machine's user.
	sudo fuser -s -k "$serverPort"/tcp
	echo "freePort: Done!"
}

case "$1" in
	start)
		while true; do
			touch running.lck
			toilet -F crop -F border "$service" | lolcat # stop removing this. i mean it.
			echo "$service started." | wall &
			cleanServer
			jarUpdate
			freePort

			# Okay, now we start the program
			$processname "$processargs"

			# Not run until the service has stopped.
			rm running.lck
			echo "ALERT! $service has stopped!"
			if [[ $restartDelay == "0" ]]; then
				echo "Not restarting. Shell exiting. Restart with ./$0"
				echo "Alert! $service stopped! NOT RESTARTING!!"
				sleep 1
				exit 0
			elif [[ $restartDelay == "-1" ]]; then
				echo -e "Not restarting. Waiting for instruction.\nPress Enter to restart the server..."
				echo "Alert! $service stopped! NOT RESTARTING!!"
				read -r
			else
				echo -e "Restarting $service automatically in...\n(Press Ctrl-C to cancel)"
				echo "Alert! $service stopped! Restarting!"
				countdown "00:00:$restartDelay"
			fi
		done
	;;
	tmux)
		echo "Creating tmux session for $service..."
		tmux new-session -d -n $service -s $service bash
		echo "Session created! Attach to it with 'tmux a -t $service'"
	;;
	jarupdate)
		echo "jarUpdate: Forcing a jar update!"
		doJarUpdate
	;;
	restart)
		echo "restarter: Attempting to restart the server via tmux-send"
		tmux send-keys -t $service:$service 'say Server restart in ONE MINUTE!' Enter
		echo "restarter: waiting one minute to allow work to be saved."
		countdown "00:00:60"
		tmux send-keys -t $service:$service 'stop' Enter
	;;
	help)
		echo "Usage: $0 [tmux/jarupdate/restart]"
		echo " - tmux: creates a properly-named tmux session for the server to reside in."
		echo " - jarupdate: forcibly retrieves a new server jar"
		echo " - restart: uses tmux-send to restart the server. crontab automatable!"
		exit 0
	;;
	*)
		if [[ -f running.lck ]]; then
			echo "Server already running! Attach to the session with 'tmux a -t $service'"
		else
			echo "Starting $service..."
			bash "$0" start
		fi
	;;
esac
