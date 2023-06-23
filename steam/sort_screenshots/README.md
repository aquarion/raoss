# Sort Steam Screenshots

Sort Steam's screenshots directory into directories with game names.

## How to run

### I Know Python

 # Use your favoured virtualenv solution
 # Install the packages from the requirements.txt file
 # run `./sort_steam_screenshots.py [screenshots directory]`

### Just Do It

 # Run `./run_in_venv.sh [screenshots directory]`
 # This will set up a python environment with the right packages without touching the rest of your system


### Containerisation Is The Future Of DevOps

 # Build it with something like `docker build . -t steam-sort-screenshots`
 # Run it with something like `docker run -v [local screenshots directory]:/screenshots -t steam-sort-screenshots`


### I'm On Windows

 # This works great with WSL2
 # Native Windows Python is an entity with which I fucketh not. You're on your own.


### I Have A Problem

 # File an issue in https://github.com/aquarion/raoss/issues
 # Even better, fork it and fix it
 # This script has no warrenty
