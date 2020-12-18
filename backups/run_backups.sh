#!/bin/bash
run-parts /var/backups/backups.d
mount /mnt/storagebox
#mkdir /mnt/backup
#sshfs -o idmap=user,IdentityFile=/root/.ssh/backup_server u69788@u69788.your-backup.de:backups /mnt/backup
rsync -urlt --delete /var/backups /mnt/storagebox/
umount /mnt/storagebox
