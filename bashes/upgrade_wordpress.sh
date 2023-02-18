#!/bin/bash

wp core update && wp plugin update --all && wp theme update --all && wp language plugin --all update && wp language theme --all update
