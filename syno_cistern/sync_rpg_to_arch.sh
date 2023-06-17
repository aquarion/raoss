#!/bin/bash

 rsync -avz --size-only --progress --delete-after /volume1/RPG aquarion@archipelago.water.gkhs.net:/mnt/storagebox/ --exclude="#recycle" --exclude=".DS_Store" --exclude=".*" --exclude="@eaDir"
