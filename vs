#!/bin/bash
# Author:
# Date:
# Purpose: To automate virtual machine back up and restoration
# Usage: ./vs [options]
#
# possible options:
# 	-b  - Backup
#	-r  - Restore
#	-f  - Restore on Fresh Install of Host OS
#	-o  - Run on one vm, not all

# NOTE: This script should be run as root

# In order to work properly this script requires some initial configuration for the variables dpath and spath.  Read further, as all the configuration occurs at the top of this script immediately following the comment block.

# Error Codes:
#	1 - User provided invalid option
#	2 - Script not run using root privileges
#	3 - User didn't provide an option
#	4 - User selected both -b and -r
#	5 - User selected neither -b or -r
#	6 - User provided a vm name but no action to perform (-b or -r)
#	7 - User selected -o but didn't provide a vm name
#	8 - Destination path not found
#	9 - Source path not found

#########################################################################
## Variable Configuration - change these values to reflect your system ##
#########################################################################

# these path names should reflect your own directory structure and backup storage location
###### IMPORTANT! ######
# For this to work properly the directories contained in the variable must exist.  If you're doing a restore on a fresh install of the host, create the directory contained in dpath and copy the files there before you begin the process.

# destination path:
dpath='/home/jmcarman/backups'

# source path:
spath='/var/lib/libvirt/images'

# Array to store virtual machine names, to add more virtual machines to this copy the same format.  To change these names to reflect your system, keep the single quotes and change the content inbetween.
#
# format vms=(nameofmachine1 nameofmachine2 nameofmachine3 nameofmachine4) ect....
vms=(ubu1 ubu2)

# Variable for log text file for easy reference
logfile=virtualsafety-log.txt

#########################################################################################
## Changes beyond this point not recommended unless you really know what you're doing, ##
## as results may be unpredictable.                                                    ##
#########################################################################################

# A function to back up the virtual machines


	# Change directory to where the virtual machines are stored as files

	
	# Use virsh dumpxml to create a backup of the xml file for the virtual machine


	# tell the user the back up is in progress

	
	# Use touch to create the backup destination file if it doesn't exist, update the time and date stamp if it does

	
	# gzip images and store them in back up directory, run in the background

	
	# Append the name of the virtual machine to the log message variable (logMsg)



# A function to restore the virtual machines


	# Change directory to where the virtual machine backups are stored


	# Tell the user the restoration is in progress


	# Use the gunzip command to unzip the backup file and restore it to /var/lib/libvirt/images


	# Append the name of the virtual machine to the log message variable (logMsg)


	# Copy the xml file to the /var/lib/libvirt/images directory


	# Use virsh define to define the virtual machine



# A function to create and update the log file
function logfile () {

	# Check to see if the destination path exists
	if [[ ! -e "$dpath" ]]; then

		# if the destination path doesn't exist, tell the user and exit the script
		echo "Destination path: "$dpath" does not exist, please reconfigure your script and run again"
		exit 8
	fi

	# Check to see if the source path exists
	if [[ ! -e "$spath" ]]; then

		# if the source path doesn't exist, tell the user and exit the script
		echo "Source path: "$dpath" does not exist, please reconfigure your script and run again"
		exit 9
	fi

	# Check to see if the log file exists
	if [[ ! -f $dpath/$logfile ]]; then # log file doesn't exist, create it
		echo "VIRTUAL SAFETY LOG" > $dpath/$logfile
		echo "FOR: $HOSTNAME" >> $dpath/$logfile
		echo "Backup Source Location: $spath" >> $dpath/$logfile
		echo "Backup Destination Location: $dpath" >> $dpath/$logifle
		echo "Start: " $(date +'%d-%b-%Y') >> $dpath/$logfile
		echo "End: " >> $dpath/$logfile
		echo "--------------------------------------" >> $dpath/$logfile
	else # update the end date
		sed -i "s/End\:.*/End\:\ $(date +'%d-%b-%Y')/" $dpath/$logfile
	fi
}

# A function to complete the process of logging the backup or restoration
function completion() {

	# Check to see if the user selected backup or restoration
	if [[ $b == 1 ]]; then
		action=Backup
	elif [[ $r == 1 ]]; then
		action=Restoration
	fi

	# tell the user the backup process has finished
	echo "Automated $action Complete, process logged to $dpath/$logfile"
	
	# append log time and date to a file for use in future documentation, add a blank line after for easier readability
	logMsg="$logMsg created with virtualsafety script on"
	echo "$logMsg" $(date) >> $dpath/$logfile
	echo "" >> $dpath/$logfile
}

# Use getopts to parse the command line options
while getopts brfo: options; do
	case $options in
		b) b=1
			;;
		r) r=1
			;;
		f) f=1
			;;
		o) o=1;vm=$OPTARG
			;;
		\?) echo "You have selected an invalid option, please use one of the following: -b for backup, -r for restore and if using -r please use -f if this restore is being done on a fresh install of the host"
		exit 1
			;;
	esac
done

# Check to see if the script is being run as root
if [[ $(id -u) -ne 0 ]]; then
	echo "You must run this script using sudo."
	exit 2
fi

# Check to see if the user provided an option
if [[ $# == 0 ]]; then
	echo "./vs must be called with at least one argument, -b to back up -r to restore, -f with -r if doing the restoration on a fresh install of the host"
	exit 3
fi

# Check to see if the user selected both backup and restore
if [[ "$b" == 1 && "$r" == 1 ]]; then
	echo "You must select either backup (-b) or restore (-r), not both"
	exit 4

# Check to see if the user selected neither backup or restore
elif [[ "$b" == 0 && "$r" == 0 ]]; then
	echo "You must select either backup (-b) or restore (-r)"
	exit 5

# Check to see if the user provided a vm name but no action to perform
elif [[ "$b" == 0 || "$r" == 0 && "$o" == 1 ]]; then
	echo "You must select either backup (-b) or restore (-r) with -o"
	exit 6

# Check to see if the user selected -o but didn't provide a vm name
elif [[ "$o" == 1 && $vm == "" ]]; then
	echo "You must provide the name of a virtual machine with -o"
	exit 7
fi

# Call the logfile function to create or update the log file
logfile $dpath $logfile

# Check to see if the user selected backup
if [[ "$b" == 1 ]]; then
	# tell the user the back up is in progress
	echo "Beginning automated back up..."
	logMsg="Backups of"

	# If the user selected -o, run the backup function on one machine
	if [[ "$o" == 1 ]]; then
		time backup $vm $dpath $spath
	# Else, call the backup function in a for loop referencing the array set above, passing it the parameters stored in the array $vms and variables $dpath, $spath.
	else
		for vm in "${vms[@]}"; do
			time backup $vm $dpath $spath
		done
		# Call the completion function to log the message to the appropriate file
		completion $b $dpath $logfile $logMsg
	fi	
fi

# Check to see if the user selected restore
if [[ "$r" == 1 ]]; then
	logMsg="Restoration of"

	# Check to see if the user selected -f (indicating a fresh install of the host)
	if [[ "$f" == 1 ]]; then
		echo "Installing virtual machine manager and updating the host"
		# Install virtualization software and update the host
		apt -y install sudo apt install virt-manager
		apt -y update && apt -y upgrade
	else
		echo "Beginning automated restoration..."
		if [[ "$o" == 1 ]]; then # restore only one machine
			time restore $vm $dpath $spath
		else
			# call the restore function in a for loop referencing the array set above, passing it the parameters stored in the array $vms and variables $dpath, $spath.
			for vm in "${vms[@]}"; do
				time restore $vm $dpath $spath
			done
			# Call the completion function to log the message to the appropriate file
			completion $r $dpath $logfile $logMsg
		fi		
	fi
fi