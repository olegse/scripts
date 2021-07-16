#!/bin/bash
#
# Find listening program line
sudo netstat -nlpt4 | grep $1
