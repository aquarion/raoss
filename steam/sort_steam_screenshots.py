#!/usr/bin/env python

# This is a script to take a directory of Steam Uncompressed Screenshots
# (as set in the settings of Steam, with the directory to put them)
# I'm running it as a cronjob.

import requests
import ConfigParser
import re
import sys, os
import errno
import glob
import simplejson
from pprint import pprint

config = ConfigParser.RawConfigParser()
config.read('config.ini');

### Config file in this form:
# [steam]
# api_key = Steam API Key
# screenshots = Directory where .jpg files are
# destination = Directory to put the renamed things


source        = config.get("steam", "screenshots")
destination   = config.get("steam", "destination")
STEAM_API_KEY = config.get("steam", "api_key")
GAMES_CACHE = {}

# Non-steam games and some others return badly. So:
CHEAT_CACHE = {
	'215280' : "The Secret World",
	'218230' : "Planetside 2",
	'22380'  : "Fallout: New Vegas"
}

URL_BASE = "http://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/"

files = glob.glob("{}/*.png".format(source))

match = re.compile("(\d*)_(\d{4}\-?\d{2})\-?\d{2}\d{6}?_\d*\.png")
# match = re.compile("\d*_\d{4}.*\.png")

def fetch_game_data(gameid):
	if gameid in CHEAT_CACHE:
		return {'game' : {'gameName' : CHEAT_CACHE[gameid]}}
	if gameid not in GAMES_CACHE:
		payload = {
			"key" : STEAM_API_KEY,
			"appid" : gameid
		}
		response = requests.get(URL_BASE, params=payload).json()
		if "game" not in response or "gameName" not in response['game']:
			# print gameid
			# pprint(response)
			# sys.exit(5)
			GAMES_CACHE[gameid] = False
			return False
		GAMES_CACHE[gameid] = response
		print "Fetched {}".format(GAMES_CACHE[gameid]['game']['gameName'])

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
		(gameid, month) = matches.groups()
		game = fetch_game_data(gameid)
		if not game:
			print "{} -> Game ID {} not matched".format(filename, gameid)
			continue
		else:
			gamename = game['game']['gameName']
			dest_file = os.path.join(destination,gamename,filename)
			mkdir_p(os.path.join(destination,gamename))
			os.rename(src_file, dest_file)
			print "{} -> {}".format(filename, gamename)
	# else:
	# 	print "{} -> Not matched".format(filename)
