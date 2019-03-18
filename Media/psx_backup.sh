#!/bin/bash
#
#  This is a script to create a .bin image with corresponding .cue out of your
#  PSX game discs as backup and/or for usage with emulators.
#
#  Run-time requirements: cdrdao

set -e

PSXDIR=~/Backups/PSX
DRIVE=/dev/sr0
IMAGENAME=""
IMAGEDIR=""
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
Script for ripping PSX game discs into .bin files with corresponding .cue files.

Usage:
  $(basename ${0}) [{--outputdir} <value>] [{--drive} <value>] [{--no-subchan] [{--help|-h}] [filename]

The parameter [filename] is mandatory. Without it, the script will abort. Plain
spaces in the filename are prohibited!

Available switches:
  --drive       Define the device to be used. Default: $DRIVE

  --help / -h   Displays this help text.

  --no-subchan  Don't extract subchannel data. Subchannel data might be
                required for some PSX copy protection though it *could* create
                problems. Retry with this parameter set if any problems occur
                when trying to use the resulting image. 

  --outputdir   Define the folder in which the resulting image directory and files 
                should be saved. If the folder does not exist, it will be created.
		Default: $PSXDIR

  --imagedir    Define the folder the bin and cue files in which the files are created.
                Use this option for multi-disc games. Default: filename

  --eject       Eject the drive once the backup is finished.

This tool requires cdrdao (http://cdrdao.sourceforge.net/) to be installed and
available in PATH.
EOSTREAM
}

# go through provided parameters
while [ "${1}" != "" ]; do
	if [ "${1}" = "--drive" ]; then
		DRIVE=$2
		shift 2
	elif [ "${1}" = "--outputdir" ]; then
		PSXDIR=$2
		shift 2
	elif [ "${1}" = "--imagedir" ]; then
		IMAGEDIR=$2
		shift 2
	elif [ "${1}" = "--eject" ]; then
		EJECT=1
		shift 1
	elif [ "${1}" = "--nosubchan" ]; then
		NOSUBCHAN="true"
		shift 2
	elif [ "${1}" = "--nosubchan" ]; then
		NOSUBCHAN="true"
		shift 2
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
which cdrdao &> /dev/null ||
	report_missing_requirement cdrdao 'http://cdrdao.sourceforge.net/'

if ! [ -e $DRIVE ]; then
	echo "ERROR: Device $DRIVE does not exist!"
	echo ""
	print_help
	exit -1
fi
# check if user has non-root access to the drive
drive_group=$(ls -lA $DRIVE | cut -d' ' -f4 | head -1)
if [ $UID -ne 0 ] && getent group $drive_group | grep -v $USER &> /dev/null;then
	echo "ERROR: You are not a member of the system group: $drive_group"
	echo "Add your account to this group or re-run the program as root."
	echo ""
	exit -1
fi
# check if imagename is defined
if [ "$IMAGENAME" = "" ]; then
	echo "ERROR: Invalid usage. Found no name for resulting image. Displaying help:"
	echo ""
	print_help
	exit -1
fi

if [ "$IMAGEDIR" = "" ]; then
	IMAGEDIR="$IMAGENAME"
fi

# output recognized parameters
echo "Program "$(basename ${0})" called. The following parameters will be used for"
echo "Folder for saving images: "$PSXDIR
echo "Drive used for reading the image: "$DRIVE
echo "Resulting filenames: "$PSXDIR"/"$IMAGEDIR"/"$IMAGENAME"[.bin|.cue]"
if [ "$NOSUBCHAN" = "true" ]; then
	echo "Not extracting subchan data."
else
	echo "Extracting subchan data."
fi
echo ""

# create dir for resulting image if it does not exist yet
if ! [ -d "$PSXDIR/$IMAGEDIR" ]; then
	echo "outputdir not found, creating folder: "$PSXDIR"/"$IMAGEDIR
	echo ""
	mkdir -p $PSXDIR/$IMAGEDIR
fi

old_dir=$PWD
cd $PSXDIR/$IMAGEDIR
echo "Starting disc backup now..."
echo ""
# final commandline for reading the disc and creating the image
if [ "$NOSUBCHAN" = "true" ]; then
	cdrdao read-cd --read-raw --datafile $IMAGENAME.bin --device $DRIVE --driver generic-mmc-raw $IMAGENAME.toc
else
	cdrdao read-cd --read-raw --read-subchan rw_raw --datafile $IMAGENAME.bin --device $DRIVE --driver generic-mmc-raw $IMAGENAME.toc
fi
toc2cue $IMAGENAME.toc $IMAGENAME.cue
cd $old_dir
echo "Done."
if [ $EJECT -eq 1 ]; then
	eject $DRIVE
fi
