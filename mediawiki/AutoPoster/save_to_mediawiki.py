#!/usr/bin/python

# Rapidly created script to save a given file to
# a mediawiki server, used for Profound Decisions' Empire & Odyssey Events

# To use, you need a config.ini file, like config.ini.example, but with
# values in it

import wikitools
import argparse
import os
import datetime
import logging
import ConfigParser
import sys


class AutoUploader():

    config = False

    def __init__(self):
        self.config = self.getConfig()

    def getConfig(self):
        myDirectory = os.path.dirname(os.path.realpath(__file__))

        config = ConfigParser.ConfigParser()
        try:
            config.readfp(open(myDirectory + '/config.ini'))
        except IOError:
            logging.error("Config file not found at %s" %
                          (myDirectory + '/config.ini'))
            sys.exit(5)

        return config

    def doTheThing(self, filename):
        wikisite = self.log_in()

        now = datetime.datetime.now()
        nowstring = now.strftime("%Y-%m-%d_%H:%M")

        pagename = "Scan %s %s" % (nowstring, os.path.basename(filename))
        try:
            testImage = wikitools.wikifile.File(
                wiki=wikisite, title=pagename)
            testImage.upload(fileobj=open(filename, "rb"), ignorewarnings=True)
            logging.info("Created %s" % pagename)
        except wikitools.api.APIError as e:
            logging.error("Error accessing mediawiki: %s" % e.args[1])
            sys.exit(5)

    def log_in(self):

        try:
            api_location = self.config.get("mediawiki", "api_location")
            username = self.config.get("mediawiki", "username")
            password = self.config.get("mediawiki", "password")
        except ConfigParser.NoSectionError:
            logging.error("Config file doesn't have a mediawiki section")
            sys.exit(5)
        except ConfigParser.NoOptionError as e:
            logging.error("Config file should have %s set" % e.option)
            sys.exit(5)

        site = wikitools.wiki.Wiki(api_location)
        site.login(username, password)
        return site

    def is_valid_file(self, parser, arg):
        if not os.path.exists(arg):
            parser.error("The file %s does not exist!" % arg)
        else:
            return arg  # return an open file handle

if __name__ == "__main__":

    uploader = AutoUploader()

    parser = argparse.ArgumentParser()
    parser.add_argument(
        'file', type=lambda x: uploader.is_valid_file(parser, x))
    args = parser.parse_args()

    uploader.doTheThing(args.file)
