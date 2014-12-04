#!/bin/bash

DATE=`date +%Y-%m -d "-1 day"`

mv -n ~/mail-archive/aquarionics-backup.mbox ~/mail-archive/aquarionics/aquarionics-$DATE && touch ~/mail-archive/aquarionics-backup.mbox
mv -n ~/mail-archive/istic-backup.mbox ~/mail-archive/istic/istic-$DATE && touch ~/mail-archive/istic-backup.mbox
