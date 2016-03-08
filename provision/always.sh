#!/usr/bin/env bash

echo "Starting always.sh, now named $0, called with arguments $*"

echo "===================================================================="
echo "Testing internet connectivity..."
wget -q www.google.com > /dev/null
if [ $? -gt 0 ]; then
	echo "No internet access (wget returned error code $?).  Aborting bootstrap.sh"
	exit 1
fi

echo "Internet access is working.  Continuing always.sh ..."


apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes upgrade
