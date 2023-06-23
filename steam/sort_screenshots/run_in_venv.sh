#!/bin/bash


# Exit immediately if a pipeline returns non-zero.
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail


here=`dirname $0`

if [[ ! -d $here/.venv ]];
then
	python -m venv $here/.venv
fi

source $here/.venv/bin/activate

pip install -qq -r $here/requirements.txt

python $here/sort_steam_screenshots.py $1

exit $?
