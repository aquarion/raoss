#!/bin/bash
# Downloads recent videos from a set of YouTube channels/playlists using
# youtube-dl, recoding to MP4 and limiting to the last 30 days / 20 videos.

function youtube {
	series=$1
	url=$2
	addcmd=$3

	if [[ $DEBUG -eq 1 ]]; then
		echo "[$series]: $url - $addcmd"
		v="-v"
	else
		v="-q"
	fi

	after=$(date -d "-30 days" +%Y%m%d)
	if [[ ! -e /home/aquarion/hosts/podcasts.aqxs.net/htdocs/"$series" ]]; then
		mkdir /home/aquarion/hosts/podcasts.aqxs.net/htdocs/"$series"
	fi

	#/usr/local/bin/youtube-dl $v $url --extract-audio --audio-format mp3 --ignore-errors --write-info-json --write-thumbnail -o "/home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/%(title)s-%(id)s.%(ext)s" --dateafter $after --max-filesize 800m --playlist-end 20 $addcmd
	#/usr/local/bin/youtube-dl $v $url --ignore-errors -f 'bestvideo[height<=1080][ext=mp4]+bestaudio'  --merge-output-format mp4 --write-info-json --write-thumbnail -o "/home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/%(title)s-%(id)s.%(ext)s" --dateafter $after --max-filesize 800m --playlist-end 20 $addcmd
	# shellcheck disable=SC2086
	/usr/local/bin/youtube-dl --recode-video mp4 --prefer-ffmpeg "$v" "$url" --ignore-errors --write-info-json --write-thumbnail -o "/home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/%(title)s-%(id)s.%(ext)s" --dateafter "$after" --max-filesize 800m --playlist-end 20 $addcmd >>/tmp/log/ytl-"$series".log
	chmod 664 /home/aquarion/hosts/podcasts.aqxs.net/htdocs/"$series"/*.json
}

youtube checkpoint "http://www.youtube.com/user/loadingreadyrun/" "--match-title ^CheckPoint* --dateafter 20140107"
youtube lrr "http://www.youtube.com/user/loadingreadyrun/" "--reject-title ^CheckPoint"
youtube tabletop "https://www.youtube.com/playlist?list=PL7atuZxmT954wz47aofSlvu0zbD4YuPOF"
youtube moviebob "https://www.youtube.com/user/moviebob"
youtube jimsterling "https://www.youtube.com/user/JimSterling"
#youtube extracredit "http://www.youtube.com/user/ExtraCreditz"
#youtube polygon "https://www.youtube.com/playlist?list=PLaDrN74SfdT65yOrX_xTAbQrJsaxIzM_v"
#youtube polygon "https://www.youtube.com/playlist?list=PLaDrN74SfdT4eCidvom_wIIDEnB7ACn5x"
#youtube polygon "https://www.youtube.com/playlist?list=PLaDrN74SfdT6t99vKcil_lANBqB1Ew7RR"
#youtube feedbackula 	"http://www.youtube.com/playlist?list=SPpg6WLs8kxGP6ETW0PjSiQbdG-1nHqaEa"
#youtube listshow "http://www.youtube.com/playlist?list=SPYT7t0pcxEIOFPo75jYgdDGaH8F4lRmjK"
youtube vlogbrothers "http://www.youtube.com/user/vlogbrothers"
youtube erb "http://www.youtube.com/user/ERB"
youtube errant_signal "http://www.youtube.com/user/Campster/"
#youtube lobby "https://www.youtube.com/playlist?list=PLpg6WLs8kxGM6snSwAXszWF2v2Bpzx8R9" "--dateafter 20140107"
#youtube hardnews https://www.youtube.com/user/ScrewAttackNews
youtube femfreq "https://www.youtube.com/user/feministfrequency/videos?flow=grid&view=0&sort=dd"
