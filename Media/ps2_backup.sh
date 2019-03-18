#!/bin/bash
#
#  This is a script to create a .iso out of your
#  PS2 game discs as backup and/or for usage with emulators.
#
#  Run-time requirements: dd, dcfldd

set -e 

PS2DIR=~/Backups/PS2
DRIVE=/dev/sr0
RIP_COMMAND=dd
IMAGENAME=""
EJECT=0

report_missing_requirement()
{
	echo "$1 is not present in PATH. $(basename ${0}) requires it in order to work properly."
	if [ -n "$2" ]; then
		echo "You can obtain $1 at <${2}>."
	fi
	exit -1
}

print_help()
{
cat << EOSTREAM
Script for ripping PS2 game discs into ISO files with DD

Usage:
  $(basename ${0}) [{--outputdir} <value>] [{--drive} <value>] [{--help|-h}] [filename]

The parameter [filename] is mandatory. Without it, the script will abort. Plain
spaces in the filename are prohibited!

Available switches:
  --drive       Define the device to be used. Default: $DRIVE
              
  --dcfldd      Use dcfldd instead of dd. (Better progress output)

  --help / -h   Displays this help text.

  --outputdir   Define the folder in which the resulting image should be saved.
                If the folder does not exist, it will be created.
		Default: $PS2DIR
	
  --eject       Eject the drive once the backup is finished.

EOSTREAM
}

# go through provided parameters
while [ "${1}" != "" ]; do
	if [ "${1}" = "--drive" ]; then
		DRIVE=$2
		shift 2
	elif [ "${1}" = "--outputdir" ]; then
		PS2DIR=$2
		shift 2
	elif [ "${1}" = "--dcfldd" ]; then
		RIP_COMMAND=dcfldd
		shift 2
	elif [ "${1}" = "--eject" ]; then
		EJECT=1
		shift 1
	elif [ "${1}" = "--help" ] || [ "${1}" = "-h" ]; then
		print_help
		exit 0
	elif [ "${2}" != "" ] ; then
		echo "ERROR: Inval id usage. Displaying help:"
		echo ""
		print_help
		exit -1
	else
		IMAGENAME=$1
		shift
	fi
done

# check for required dependencies
if [ "$RIP_COMMAND" = "dcfldd" ]; then
	which dcfldd &> /dev/null ||
		report_missing_requirement dcfldd 'http://dcfldd.sourceforge.net/'
else
	which dd &> /dev/null ||
		report_missing_requirement dd 'https://www.gnu.org/software/coreutils/manual/coreutils.html'
fi

if [ "$IMAGENAME" = "" ]; then
	echo "ERROR: Invalid usage. Found no name for resulting image. Displaying help:"
	echo ""
	print_help
	exit -1
fi

if ! [ -e $DRIVE ]; then
	echo "ERROR: Device $DRIVE does not exist!"
	echo ""
	print_help
	exit -1
fi

#check if user has non-root access to the drive
drive_group=$(ls -lA $DRIVE | cut -d' ' -f4 | head -1)
if [ $UID -ne 0 ] && getent group $drive_group | grep -v $USER &> /dev/null;then
	echo "ERROR: You are not a member of the system group: $drive_group"
	echo "Add your account to this group or re-run the program as root"
	echo ""
	exit -1
fi

# output recognized parameters
echo "Program "$(basename ${0})" called. The following parameters will be used for"
echo "creating an image of a PS2 disc:"
echo "Folder for saving images: "$PS2DIR
echo "Drive used for reading the image: "$DRIVE
echo "Resulting filenames: "$PS2DIR"/"$IMAGENAME".iso"
echo "Ripping with $RIP_COMMAND"
echo ""

# check if imagename is defined
# create dir for resulting image if it does not exist yet
if ! [ -d "$PS2DIR" ]; then
	echo "outputdir not found, creating folder: "$PS2DIR"/"
	echo ""
	mkdir -p $PS2DIR
fi

echo "Starting disc backup now..."
echo ""
$RIP_COMMAND if="$DRIVE" of="$PS2DIR/$IMAGENAME.iso"
echo "Done."
if [ $EJECT -eq 1 ]; then
	eject $DRIVE
fi
