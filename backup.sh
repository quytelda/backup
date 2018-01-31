#!/bin/bash

# backup.sh - simple incremental backup script
# Run ./backup.sh as root to create an incremental backup of your system to /backups.
# To reduce the chance of data loss, back up to some external media such as a
# removable hard drive or network share.

# BACKUPS is the destination directory where backups will be stored.
# Edit BACKUPS to change the backup destination.
BACKUPS=${1:-/backups}
PREV_BACKUP=$BACKUPS/current
CURR_BACKUP=$BACKUPS/backup-$(date "+%Y%m%d_%H%M%S")

# SOURCE is the top level of the directory tree to back up.
# Edit SOURCE to change the backup source.
SOURCE=${2:-/}

# this script should be run as root
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root."
   exit
fi

echo "Backing up $SOURCE to $BACKUPS..."

# do an incremental backup with rsync, skipping "special" files
rsync -aAXP --link-dest=$PREV_BACKUP --exclude={"/dev","/proc","/sys","/tmp","/run","/mnt","/media","/lost+found"} $SOURCE $CURR_BACKUP

# $BACKUPS/current should always link to the most recent backup
rm -f $PREV_BACKUP
ln -s $CURR_BACKUP $PREV_BACKUP
