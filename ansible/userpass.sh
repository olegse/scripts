#!/bin/bash

# Find user password from the hosts file. Also show SELECT prompt

test "$1" || { echo -e "Usage: `basename $0` USER"; exit; }
