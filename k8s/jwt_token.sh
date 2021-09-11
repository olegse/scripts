#!/bin/bash
#
# jwt token

test "$1" || { echo "Missing secret name"; exit 1; }
kubectl describe secret "$1"  | awk -F: '/^token/ {print $2}' | tr -d " "
