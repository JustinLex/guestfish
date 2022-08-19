#!/bin/bash

# Script for running guestfish to modify a disk image
# DO NOT RUN THIS OUTSIDE OF A CONTAINER
# I AM NOT RESPONSIBLE IF YOU POINT THIS AT YOUR REAL HARD DRIVE AND BORK IT

# Usage: Run script with two arguments:
# The first argument is the name of the disk image found in /root/src/
# The second argument is the number of the partition you want to modify
# Also make sure to have a file in /root/commands.txt with a list of guestfish commands to run, separated by newlines

diskimage_name=$1
partition_number=$2

set -e

# Guestfish multi-command setup stuff
# See "USING REMOTE CONTROL ROBUSTLY FROM SHELL SCRIPTS"
# https://libguestfs.org/guestfish.1.html#guestfish-commands
# Might be possible to do this with fuse, but I don't think fuse works inside containers
guestfish[0]="guestfish"
guestfish[1]="--listen"
guestfish[2]="--format=raw"
guestfish[3]="-a"
guestfish[4]="/root/src/$diskimage_name"
guestfish[5]="-m"
guestfish[6]="/dev/sda$partition_number"

GUESTFISH_PID=
eval $("${guestfish[@]}")
if [ -z "$GUESTFISH_PID" ]; then
   echo "error: guestfish didn't start up, see error messages above"
   exit 1
fi

cleanup_guestfish ()
{
   guestfish --remote -- exit >/dev/null 2>&1 ||:
}
trap cleanup_guestfish EXIT ERR

# Note that we can't use guestfish mount-local because that needs fuse

# Run guestfish commands
commands=$(cat /root/commands.txt)
for command in $commands
do
  # shellcheck disable=SC2086 # (disable IDE complaints)
  guestfish --remote -- $command
done

# exit
cleanup_guestfish
