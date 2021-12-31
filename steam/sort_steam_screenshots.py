#!/usr/bin/env python

# This is a script to take a directory of Steam Uncompressed Screenshots
# (as set in the settings of Steam, with the directory to put them)
# I'm running it as a cronjob.

import requests
import configparser
import re
import sys, os
import errno
import glob
import simplejson
from pprint import pprint

config = configparser.RawConfigParser()

working_dir = os.path.dirname(sys.argv[0])
config_location = os.path.expanduser("{}/config.ini".format(working_dir))

config.read(config_location);

### Config file in this form:
# [steam]
# screenshots = Directory where .jpg files are
# destination = Directory to put the renamed things


source        = config.get("steam", "screenshots")
destination   = config.get("steam", "destination")
GAMES_CACHE = {}

# Non-steam games return badly. So:
CHEAT_CACHE = {
	# '215280' : "The Secret World",
	# '218230' : "Planetside 2",
	# '22380'  : "Fallout: New Vegas"
}

URL_BASE = "http://store.steampowered.com/api/appdetails/"

files = glob.glob("{}/*.png".format(source))

# match = re.compile("(\d*)_(\d{4}\-?\d{2})\-?\d{2}\d{6}?_\d*\.png")
match = re.compile("^(\d*)_\d{4}.*\.png")

def fetch_game_data(gameid):
	if gameid in CHEAT_CACHE:
		return {'name' : CHEAT_CACHE[gameid]}
	if gameid not in GAMES_CACHE:
		payload = {
			"appids" : gameid
		}
		response = requests.get(URL_BASE, params=payload).json()
		if gameid not in response or "success" not in response[gameid]:
			GAMES_CACHE[gameid] = False
			return False
		GAMES_CACHE[gameid] = response[gameid]['data']
		print("Fetched {}".format(GAMES_CACHE[gameid]['name']))

	return GAMES_CACHE[gameid]

def mkdir_p(path):
    """ 'mkdir -p' in Python """
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

for src_file in files:
	filename = os.path.basename(src_file)
	gamename = "Unknown"
	matches = match.match(filename)

	if matches:
		gameid = matches.groups()[0]
		game = fetch_game_data(gameid)
		if not game:
			print("{} -> Game ID {} not matched".format(filename, gameid))
			continue
		else:
			gamename = game['name']
			dest_file = os.path.join(destination,gamename,filename)
			mkdir_p(os.path.join(destination,gamename))
			os.rename(src_file, dest_file)
			print("{} -> {}".format(filename, gamename))
	# else:
	# 	print "{} -> Not matched".format(filename)
