#!/bin/bash
#
# xplanet-gnome.sh
# shows Earth on your Gnome desktop with current lighting conditions,i.e. day and night

# Required packages (on Ubuntu):
# - xplanet
# - xplanet-images
# - imagemagick

# Usage:
# xplanet-gnome.sh --help   
# xplanet-gnome.sh --start  start as daemon (old instances will be closed first)
# xplanet-gnome.sh --stop   stop the daemon
# xplanet-gnome.sh          run in the foreground (to see errormessages)
# xplanet-gnome.sh --test   dry run (show commands)
# xplanet-gnome.sh --clouds download cloud images (at most every 3 hours). (e.g. for use via crontab)
# xplanet-gnome.sh --init   check the binaries and download all required images

# Versions
# 0.23	initial fork from original xplanet-gnome
#	- added option to download fancy images from NASA site
#	- added option to download cloud-images
#	- change background according to month
#
# 0.42	some additions
#	- translated german parts to english
#	- added check for required binaries in --init
#	- resize and cut the image to propper resolution (so there's no scaling to be done by Gnome)

# for more information visit http://nullniveau.org/
#						Bapf

###############################################################################
# Change these parameters als needed (uncomment not used parameters with #)
# Not all combinations are working
# If there's a problem uncomment all and re-activate them one by one

#### the following parameters have to be set
# delay between updates
DELAY=30m

# screen resolution (only tested for width > height)
RESOLUTION=1920x1080

# temporary files
OUTPUT1=~/.xplanet/xplanet1.png
OUTPUT2=~/.xplanet/xplanet2.png

#### the following parameters can be changed
# Working directory
BASE=$HOME/.xplanet/

# Latitude and Longitue of target (doesn't work with ORIGIN)
# LONGITUDE can be set to RANDOM
#LONGITUDE=7.45898; LATITUDE=51.51758 # Dortmund
#LONGITUDE=20; LATITUDE=20 # Afrika, Tschad
LONGITUDE=13.4167; LATITUDE=52.5333 # Berlin
#LONGITUDE=random; LATITUDE=20 # random Longitude
#LONGITUDE=-10; LATITUDE=52

# Planets (Why not just land on Rhea?)
# sun, mercury, venus, earth, moon, mars, phobos, deimos, jupiter, io, europa, ganymede,  callisto,  saturn,
# mimas, enceladus, tethys, dione, rhea, titan, hyperion, iapetus, phoebe, uranus, miranda, ariel, umbriel,
# titania,  oberon, neptune, triton, nereid, pluto, charon,
# random, and major. "naif" or "norad", along with the satellite id.
# naif-82 (Cassini orbiter) norad20580 (Hubble Space Telescope) norad25544 (iss)
# ORIGIN doesn't work with LONGITUDE LATITUDE
#ORIGIN=naif-82
#ORIGIN=moon
#TARGET=earth
#TARGET=random # in CONFIG-Datei random_target=false for all planets without map!
#TARGET=major

#STARMAP=BSC # you need a projection for this e.g. ortographic
#RANGE=1000
#RADIUS=42

#default is no projection,i.e. render a globe
# ancient, azimuthal, bonne, gnomonic,  hemisphere,  lambert,  mercator,  mollweide, orthographic, peters,
# polyconic, rectangular, tsc
# Multiple bodies will not be shown if this option is specified, although shadows will still be drawn.
PROJECTION=rectangular

# Background (Color or file; whitespace is ok)
#BACKGROUND=0x080B31 #Ozean-Blau
#BACKGROUND=0x282B61
#BACKGROUND="/path/to/file 123.jpg"

# Rotate the Longitude after every image by ROTATION
# ROTATION and LANGITUDE have to be integer
#ROTATION=10

# Screen position of the center of the planet
#CENTER=+256+192 # +x+y

# Multiple planets
#TILE=256   # tile size (not in conjugation with CENTER)
#TILEX=128; TILEY=128 # point of origin (center of 1. tile)
#TILEMAXX=1280; TILEMAXY=1024 # max values <= screen resolution

#LABEL="-labelpos -10+40" # show planet name and informations

# own config-file (no whitespaces!)
# use /usr/share/xplanet/config/default as template for own config
#CONFIG=/home/user/.xplanet/config/config
#CONFIG=/home/user/.xplanet/config/default

# end of parameters
############################

# calculate GEOMETRY from RESOLUTION
if [ `echo $RESOLUTION | sed -e 's/[0-9]*x//'` -gt 1024 ]; then
	GEOMETRY=4096x2048
else
	GEOMETRY=2048x1024
fi

# calculate BACKRES from GEOMETRY
if [ `echo $GEOMETRY | sed -e 's/x[0-9]*//'` -gt 2048 ]; then
	BACKRES=4096
else
	BACKRES=2048
fi

XPLANETFLAGS="-num_times 1 -config $BASE/config $LABEL"
if [ ! -z $GEOMETRY ]; then XPLANETFLAGS="$XPLANETFLAGS -geometry $GEOMETRY"; fi
if [ ! -z $LATITUDE ]; then XPLANETFLAGS="$XPLANETFLAGS -latitude $LATITUDE"; fi
if [ ! -z $ORIGIN ]; then XPLANETFLAGS="$XPLANETFLAGS -origin $ORIGIN"; fi
if [ ! -z $TARGET ]; then XPLANETFLAGS="$XPLANETFLAGS -target $TARGET"; fi
if [ ! -z $STARMAP ]; then XPLANETFLAGS="$XPLANETFLAGS -starmap $STARMAP"; fi
if [ ! -z $RANGE ]; then XPLANETFLAGS="$XPLANETFLAGS -range $RANGE"; fi
if [ ! -z $RADIUS ]; then XPLANETFLAGS="$XPLANETFLAGS -radius $RADIUS"; fi
if [ ! -z $PROJECTION ]; then XPLANETFLAGS="$XPLANETFLAGS -projection $PROJECTION"; fi
if [ ! -z $CONFIG ]; then XPLANETFLAGS="$XPLANETFLAGS -config $CONFIG"; fi
if [ ! -z $CENTER ]; then XPLANETFLAGS="$XPLANETFLAGS -center $CENTER"; fi
if [ ! -z "$BACKGROUND" ]; then XPLANETFLAGS="$XPLANETFLAGS -background"; fi

if [ ! -e $BASE/config ]; then
	echo "[earth]" >> $BASE/config
	echo "map=earth.jpg" >> $BASE/config
	echo "night_map=night.jpg" >> $BASE/config
	echo "cloud_map=clouds.jpg" >> $BASE/config
fi

case $1 in
	("--help")
		echo "usage: $0 [OPTION]"
		echo "  --help   show this help"
		echo "  --start  start as daemon (old instances will be closed first)"
		echo "  --stop   stop the daemon"
		echo "  --init   check the binaries and download all required images (takes some time)"
		echo "  --clouds download cloud images (at most every 3 hours). (e.g. for use via crontab)"
		echo " witout options the program runs in the foreground (to display errormessages)"
		echo ""
		exit;;
	("--start")
		kill $(pidof -x -o %PPID $(basename $0)) 2>/dev/null
		nice -n 19 $0 >/dev/null 2>&1 &
		exit;;
	("--stop")
		kill $(pidof -x -o %PPID $(basename $0)) 2>/dev/null
		exit;;
	("--test")
		TEST=echo;;
	("--clouds")

		STAMP=$(perl -e '($ss, $mm, $hh, $DD, $MM, $YY) = localtime(time() - 10800); printf "%04d%02d%02d%02d%02d", $YY + 1900, $MM + 1, $DD, $hh, $mm')

		cd $BASE

		touch -t $STAMP reference
		TOOLD=$(find . -type f ! -newer reference -name clouds.jpg | wc -l)

		if [ -e clouds.jpg ]; then
			if [ $TOOLD -eq 1 ]; then
				wget --no-cache -O clouds.tmp.jpg http://xplanetclouds.com/free/coral/clouds_2048.jpg
				if [ $? -eq 0 ]; then
					convert -resize 4096x2048 clouds.tmp.jpg clouds.jpg
					#mv clouds.tmp.jpg clouds.jpg;
				fi
			fi
		else
			wget --no-cache -O clouds.tmp.jpg http://xplanetclouds.com/free/coral/clouds_2048.jpg
			convert -resize 4096x2048 clouds.tmp.jpg clouds.jpg
		fi
		exit;;
	("--init")
		if [ ! `which xplanet` ]; then
			echo "Please install 'xplanet' and 'xplanet-images'";
			exit 1;
		fi
		if [ ! `which convert` ]; then
			echo "Please install 'imagemagick'";
			exit 1;
		fi
		if [ ! -e $BASE/backgrounds ]; then
			mkdir $BASE/backgrounds
		fi
		cd $BASE/backgrounds
		wget -O 00_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/55000/55167/earth_lights_lrg.jpg >/dev/null 2>&1
		wget -O 01_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73580/world.topo.bathy.200401.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 02_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73605/world.topo.bathy.200402.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 03_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73630/world.topo.bathy.200403.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 04_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73655/world.topo.bathy.200404.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 05_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73701/world.topo.bathy.200405.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 06_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73726/world.topo.bathy.200406.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 07_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/world.topo.bathy.200407.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 08_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73776/world.topo.bathy.200408.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 09_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73801/world.topo.bathy.200409.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 10_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73826/world.topo.bathy.200410.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 11_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73884/world.topo.bathy.200411.3x5400x2700.jpg >/dev/null 2>&1
		wget -O 12_full.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg >/dev/null 2>&1
		convert -resize 2048x1024 00_full.jpg 00_2048.jpg
		convert -resize 4096x2048 00_full.jpg 00_4096.jpg
		convert -resize 2048x1024 01_full.jpg 01_2048.jpg
		convert -resize 4096x2048 01_full.jpg 01_4096.jpg
		convert -resize 2048x1024 02_full.jpg 02_2048.jpg
		convert -resize 4096x2048 02_full.jpg 02_4096.jpg
		convert -resize 2048x1024 03_full.jpg 03_2048.jpg
		convert -resize 4096x2048 03_full.jpg 03_4096.jpg
		convert -resize 2048x1024 04_full.jpg 04_2048.jpg
		convert -resize 4096x2048 04_full.jpg 04_4096.jpg
		convert -resize 2048x1024 05_full.jpg 05_2048.jpg
		convert -resize 4096x2048 05_full.jpg 05_4096.jpg
		convert -resize 2048x1024 06_full.jpg 06_2048.jpg
		convert -resize 4096x2048 06_full.jpg 06_4096.jpg
		convert -resize 2048x1024 07_full.jpg 07_2048.jpg
		convert -resize 4096x2048 07_full.jpg 07_4096.jpg
		convert -resize 2048x1024 08_full.jpg 08_2048.jpg
		convert -resize 4096x2048 08_full.jpg 08_4096.jpg
		convert -resize 2048x1024 09_full.jpg 09_2048.jpg
		convert -resize 4096x2048 09_full.jpg 09_4096.jpg
		convert -resize 2048x1024 10_full.jpg 10_2048.jpg
		convert -resize 4096x2048 10_full.jpg 10_4096.jpg
		convert -resize 2048x1024 11_full.jpg 11_2048.jpg
		convert -resize 4096x2048 11_full.jpg 11_4096.jpg
		convert -resize 2048x1024 12_full.jpg 12_2048.jpg
		convert -resize 4096x2048 12_full.jpg 12_4096.jpg
		rm *full.jpg
		cd $BASE
		ln -s backgrounds/00_$BACKRES.jpg night.jpg
		ln -s backgrounds/06_$BACKRES.jpg earth.jpg
		exit;;
esac

function random2b () { dd if=/dev/random count=1 bs=2 2>/dev/null | hexdump -e '"%d"'; }
function random () { echo $(( `random2b`*$1/65536-$1/2)); }

OUTPUT=$BACKGROUND

while true;
do
	# do rotation
	if [ ! -z $ROTATION ]; then LONGITUDE=$(( ($LONGITUDE+$ROTATION)%360 )); fi
	if [ ! -z $LONGITUDE ]; then
		if [ $LONGITUDE = random ]; then
			XPLANETFLAGS2="-longitude `random 360`";
		else
			XPLANETFLAGS2="-longitude $LONGITUDE";
		fi
	fi
	if [ $TILE ]; then
		XPLANETFLAGS2="$XPLANETFLAGS2 -center +$TILEX+$TILEY";
		TILEX=$(( ($TILEX+$TILE)%$TILEMAXX ))
		TILEY=$(( ($TILEY+$TILE)%$TILEMAXY ))
		BACKGROUND=$OUTPUT
	fi

	# rename background image so Gnome realises image has changed - thx to dmbasso
	if [ -e "$OUTPUT1" ]; then
		$TEST rm "$OUTPUT1"
		OUTPUT="$OUTPUT2"
	else
		$TEST rm "$OUTPUT2"
		OUTPUT="$OUTPUT1"
	fi

	# set background regarding month and screen size
	cd $BASE
	rm earth.jpg; ln -s backgrounds/`date +%m`_$BACKRES.jpg earth.jpg
	rm night.jpg; ln -s backgrounds/00_$BACKRES.jpg night.jpg

	# calculate picture
	if [ "$BACKGROUND" ]; then
	$TEST xplanet -output $OUTPUT $XPLANETFLAGS2 $XPLANETFLAGS -background "$BACKGROUND"
	else
	$TEST xplanet -output $OUTPUT $XPLANETFLAGS2 $XPLANETFLAGS
	fi

	# resize picture
	$TEST convert $OUTPUT -resize ${RESOLUTION}^ -support 0.00001 -gravity center -extent $RESOLUTION ${OUTPUT}.t
	$TEST mv ${OUTPUT}.t $OUTPUT

	# update Gnome backgound
	$TEST gconftool -t str -s /desktop/gnome/background/picture_filename "$OUTPUT"

	if [ ! $TEST ]; then
		sleep $DELAY
	else
		exit 0
	fi
done
