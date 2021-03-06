#!/usr/bin/python

import base64, urllib2, json, datetime, time, sys, getpass, plistlib

import os
import ConfigParser
import logging
from pprint import pprint

LOG_FORMAT = '%(asctime)s [%(levelname)s] [%(name)s] %(message)s'

logging.getLogger('').setLevel(logging.DEBUG)

formatter = logging.Formatter(LOG_FORMAT)
# filename = "%s/lifestream.log" % LOG_DIR
# logfile = TimedRotatingFileHandler(filename, when='W0', interval=1, utc=True)
# logfile.setLevel(logging.DEBUG)
# logfile.setFormatter(formatter)
# logging.getLogger('').addHandler(logfile)

console = logging.StreamHandler()
console.setFormatter(formatter)
logging.getLogger('').addHandler(console)

if ('--debug' in sys.argv):
    console.setLevel(logging.DEBUG)
    DEBUG = True
else:
    console.setLevel(logging.ERROR)
    DEBUG = False

logger = logging.getLogger(__name__)



def tokenFactory(dsid, mmeAuthToken):
    mmeAuthTokenEncoded = base64.b64encode("%s:%s" % (dsid, mmeAuthToken))
    #now that we have proper auth code, we will attempt to get all account tokens.
    url = "https://setup.icloud.com/setup/get_account_settings"
    headers = {
        'Authorization': 'Basic %s' % mmeAuthTokenEncoded,
        'Content-Type': 'application/xml',
        'X-MMe-Client-Info': '<iPhone6,1> <iPhone OS;9.3.2;13F69> <com.apple.AppleAccount/1.0 (com.apple.Preferences/1.0)>'
    }

    request = urllib2.Request(url, None, headers)
    response = None
    try:
        response = urllib2.urlopen(request)
    except urllib2.HTTPError as e:
        if e.code != 200:
            return ("HTTP Error: %s" % e.code, 0) #expects tuple
        else:
            print e
            raise HTTPError
    #staple it together & call it bad weather; only need FMFAppToken
    content = response.read()
    mmeFMFAppToken = plistlib.readPlistFromString(content)["tokens"]["mmeFMFAppToken"]
    return mmeFMFAppToken

def dsidFactory(uname, passwd): #can also be a regular DSID with AuthToken
    creds = base64.b64encode("%s:%s" % (uname, passwd))
    url = "https://setup.icloud.com/setup/authenticate/%s" % uname
    headers = {
        'Authorization': 'Basic %s' % creds,
        'Content-Type': 'application/xml',
    }

    request = urllib2.Request(url, None, headers)
    response = None
    try:
        response = urllib2.urlopen(request)
    except urllib2.HTTPError as e:
        if e.code != 200:
            if e.code == 401:
                return ("HTTP Error 401: Unauthorized. Are you sure the credentials are correct?", 0)
            elif e.code == 409:
                return ("HTTP Error 409: Conflict. 2 Factor Authentication appears to be enabled. You cannot use this script unless you get your MMeAuthToken manually (generated either on your PC/Mac or on your iOS device).", 0)
            elif e.code == 404:
                return ("HTTP Error 404: URL not found. Did you enter a username?", 0)
            else:
                return ("HTTP Error %s.\n" % e.code, 0)
        else:
            print e
            raise HTTPError
    content = response.read()
    DSID = int(plistlib.readPlistFromString(content)["appleAccountInfo"]["dsPrsID"]) #stitch our own auth DSID
    mmeAuthToken = plistlib.readPlistFromString(content)["tokens"]["mmeAuthToken"] #stitch with token
    return (DSID, mmeAuthToken)

def HeardItFromAFriendWho(dsid, mmeFMFAppToken, user):
    while 1:
        url = 'https://p04-fmfmobile.icloud.com/fmipservice/friends/%s/refreshClient' % dsid
        headers = {
            'Authorization': 'Basic %s' % base64.b64encode("%s:%s" % (dsid, mmeFMFAppToken)),#FMF APP TOKEN
            'Content-Type': 'application/json; charset=utf-8',
        }
        data = {
            "clientContext": {
                "appVersion": "5.0" #critical for getting appropriate config / time apparently.
            }
        }
        jsonData = json.dumps(data)
        request = urllib2.Request(url, jsonData, headers)
        i = 0
        while 1:
            try:
                response = urllib2.urlopen(request)
                break
            except: #for some reason this exception needs to be caught a bunch of times before the request is made.
                i +=1
                continue
        x = json.loads(response.read())
        dsidList = []
        phoneList = [] #need to find how to get corresponding name from CalDav
        for y in x["following"]: #we need to get contact information.
            for z, v in y.items():
                #do some cleanup
                if z == "invitationAcceptedHandles":
                    v = v[0] #v is a list of contact information, we will grab just the first identifier
                    phoneList.append(v)
                if z == "id":
                    v = v.replace("~", "=")
                    v = base64.b64decode(v)
                    dsidList.append(v)
        zippedList = zip(dsidList, phoneList)
        retString = ""
        i = 0
        return x["locations"]


if __name__ == '__main__':

    config = ConfigParser.RawConfigParser()

    working_dir = os.path.dirname(sys.argv[0])
    config_location = os.path.expanduser("{}/config.ini".format(working_dir))

    config.read(config_location)

    # user = raw_input("Apple ID: ")
    # try: #in the event we are supplied with an DSID, convert it to an int
    #     int(user)
    #     user = int(user)
    # except ValueError: #otherwise we have an apple id and can not convert
    #     pass
    # passw = getpass.getpass()
    user = config.get("account", "username");
    passw = config.get("account", "password");

    (DSID, authToken) = dsidFactory(user, passw)
    
    logger.info('DSID '+str(DSID)+', auth '+authToken)

    if authToken == 0: #http error
        print DSID
        sys.exit()
    mmeFMFAppToken = tokenFactory(DSID, authToken)
    data = HeardItFromAFriendWho(DSID, mmeFMFAppToken, user)

    if DEBUG:
        pprint(data)

    abandon = False
    for person in data:
        if person['location'] == None:
            abandon = True
            logger.debug("Abandoning due to absent data")
    
    if not abandon:
        logger.info("Writing to file")
        with open(config.get('location', 'filename'), 'w') as outfile:
            json.dump(data, outfile)

