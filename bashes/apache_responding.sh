#!/bin/bash

# Check if Apache is responding

APACHE_RESPONE=`mktemp --suffix=.apache_responding_te`

LOG_DIRECTORY=/var/log/apache2/last_responding
mkdir -p $LOG_DIRECTORY || exit 1

LAST_WORKING=$LOG_DIRECTORY/apache_responding_last_working.log
LAST_BEFORE_CRASH=$LOG_DIRECTORY/apache_responding_last_before_crash.log


www-browser -dump https://cenote.gkhs.net/server-status > $APACHE_RESPONE
LYNX_RETURN=$?

if [ $LYNX_RETURN -ne 0 ]; then
    echo "> Apache is not responding, restarting apache"
    if [ -f $LAST_WORKING ]; then
        echo "> Found last working file"
        if [ -f $LAST_BEFORE_CRASH  ]; then
            echo "> Found last before crash file"
            if [ `diff $LAST_WORKING $LAST_BEFORE_CRASH | wc -l` -gt 0 ]; then
                # Last before crash was different to last working
                echo "> Last before crash was different to last working"
                mv $LAST_BEFORE_CRASH $LAST_BEFORE_CRASH.`stat -c %Y $LAST_BEFORE_CRASH`
                cp $LAST_WORKING $LAST_BEFORE_CRASH
            else
                echo "> Last before crash was the same as last working, do nothing"
                # Last before crash was the same as last working, do nothing
                true
            fi
        else
            echo "> Last before crash file not found"
            cp $LAST_WORKING $LAST_BEFORE_CRASH
        fi
        cat $LAST_BEFORE_CRASH
    else
        echo "> Last working file not found"
    fi
    systemctl restart apache2

    exit 1
else
    # echo "> Apache is responding"
    cp $APACHE_RESPONE $LAST_WORKING
    exit 0
fi
