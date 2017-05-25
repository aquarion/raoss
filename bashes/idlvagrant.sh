#!/bin/bash
#
# For repositories that store their vagrant files in a "./vagrant" directory of root
# this can be run at any point in the repository file structure to run vagrant commands
#

pushd $HOME/code/IDL/ansible-webstack
IDL_HOME=$PWD
vagrant $@
popd
