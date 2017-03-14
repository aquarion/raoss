
function youtube {
	series=$1
	url=$2
	addcmd=$3

	if [[ $DEBUG -eq 1 ]]
	then
		echo "[$series]: $url - $addcmd"
		v="-v"
	else
		v="-q"
	fi

	after=`date -d "-30 days" +%Y%m%d`
	if [[ ! -e /home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series ]]
	then
		mkdir /home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series
	fi
	
	#/usr/local/bin/youtube-dl $v $url --extract-audio --audio-format mp3 --ignore-errors --write-info-json --write-thumbnail -o "/home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/%(title)s-%(id)s.%(ext)s" --dateafter $after --max-filesize 800m --playlist-end 20 $addcmd
	#/usr/local/bin/youtube-dl $v $url --ignore-errors -f 'bestvideo[height<=1080][ext=mp4]+bestaudio'  --merge-output-format mp4 --write-info-json --write-thumbnail -o "/home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/%(title)s-%(id)s.%(ext)s" --dateafter $after --max-filesize 800m --playlist-end 20 $addcmd
	/usr/local/bin/youtube-dl  --recode-video mp4 --prefer-ffmpeg $v $url --ignore-errors --write-info-json --write-thumbnail -o "/home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/%(title)s-%(id)s.%(ext)s" --dateafter $after --max-filesize 800m --playlist-end 20 $addcmd >> /tmp/log/ytl-$series.log
	chmod 664 /home/aquarion/hosts/podcasts.aqxs.net/htdocs/$series/*.json
}
