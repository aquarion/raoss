#!/usr/bin/env python

# This is a script to take a directory of Steam Uncompressed Screenshots
# (as set in the settings of Steam, with the directory to put them)
# I'm running it as a cronjob.

import requests
import re
import sys, os
import errno
import glob
import simplejson
import argparse
from pprint import pprint
from pathvalidate import sanitize_filepath

parser = argparse.ArgumentParser(
                    prog='Sort Steam Screenshots',
                    description='Sorts steam screenshots into named directories')

parser.add_argument('working_dir', default="/screenshots")

args = parser.parse_args()

working_dir = os.path.dirname(args.working_dir)

GAMES_CACHE = {}

# Non-steam games return badly. So:
CHEAT_CACHE = {
	# '215280' : "The Secret World",
	# '218230' : "Planetside 2",
	# '22380'  : "Fallout: New Vegas"
}

URL_BASE = "http://store.steampowered.com/api/appdetails/"

if not os.path.exists(working_dir):
    print(("Error: {} does not exist".format(working_dir)))
    sys.exit(5)


all_png_files = glob.glob("{}/*.png".format(working_dir))

# steam_screenshot_format = re.compile("(\d*)_(\d{4}\-?\d{2})\-?\d{2}\d{6}?_\d*\.png")
steam_screenshot_format = re.compile("^(\d*)_\d{4}.*\.png")

def fetch_game_data(steam_game_id):
	if steam_game_id in CHEAT_CACHE:
		return {'name' : CHEAT_CACHE[steam_game_id]}
	if steam_game_id not in GAMES_CACHE:
		payload = {
			"appids" : steam_game_id
		}
		response = requests.get(URL_BASE, params=payload).json()
		if steam_game_id not in response or "success" not in response[steam_game_id]:
			GAMES_CACHE[steam_game_id] = False
			return False
		GAMES_CACHE[steam_game_id] = response[steam_game_id]['data']
		print(("Fetched {}".format(GAMES_CACHE[steam_game_id]['name'])))

	return GAMES_CACHE[steam_game_id]

def mkdir_p(path):
    """ 'mkdir -p' in Python """
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

print("Processing {} Files".format(len(all_png_files)))

for src_file in all_png_files:
	screenshot_file = os.path.basename(src_file)
	game_name = "Unknown"
	screenshot_matches = steam_screenshot_format.match(screenshot_file)

	if screenshot_matches:
		steam_game_id = screenshot_matches.groups()[0]
		game_data = fetch_game_data(steam_game_id)
		if not game_data:
			print(("{} -> Game ID {} not matched".format(screenshot_file, steam_game_id)))
			continue
		else:
			game_name = sanitize_filepath(game_data['name'])
			dest_file = os.path.join(working_dir,game_name,screenshot_file)
			dest_file = sanitize_filepath(dest_file)
			mkdir_p(os.path.join(working_dir,game_name))
			os.rename(src_file, dest_file)
			print(("{} -> {}".format(screenshot_file, game_name)))
	else:
	 	print("{} -> Not matched".format(screenshot_file))
