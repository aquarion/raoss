# Sort Steam Screenshots

Sort Steam's screenshots directory into directories with game names.

## How to run

### I Know Python

 1. Use your favoured virtualenv solution
 1. Install the packages from the requirements.txt file
 1. run `./sort_steam_screenshots.py [screenshots directory]`

### Just Do It

 1. Run `./run_in_venv.sh [screenshots directory]`
 1. This will set up a python environment with the right packages without touching the rest of your system


### Containerisation Is The Future Of DevOps

 1. Build it with something like `docker build . -t steam-sort-screenshots`
 1. Run it with something like `docker run -v [local screenshots directory]:/screenshots -t steam-sort-screenshots`


### I'm On Windows

 1. This works great with WSL2
 1. Native Windows Python is an entity with which I fucketh not. You're on your own.


### I Have A Problem

 1. File an issue in https://github.com/aquarion/raoss/issues
 1. Even better, fork it and fix it
 1. This script has no warrenty
