#!/bin/sh
filebot -script fn:amc --output "/var/lib/plexmediaserver" --log-file amc.log --action move --conflict override -non-strict --def music=y subtitles=en artwork=y --def "seriesFormat=TV Shows/{n}/{'S'+s}/{s00e00} - {t}" "animeFormat=Anime/{n}/{fn}" "movieFormat=Movies/{n} {y}/{fn}" "musicFormat=Music/{n}/{fn}" --def plex=localhost "/var/lib/plexmediaserver/Torrential"
