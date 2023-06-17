#!/bin/bash

# rsync -rvz --delete-after --size-only /volume1/RPG aquarion@firth.water.gkhs.net:/home/library/ --exclude="#recycle" --exclude=".DS_Store" --exclude=".*" --exclude="@eaDir" --include=Systems/.thalium
rsync -rvz --delete-after --size-only /volume1/RPG aquarion@firth.water.gkhs.net:/home/library/ --exclude="#recycle" --exclude=".DS_Store" --exclude="@eaDir"

 exit $?
