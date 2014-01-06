#!/bin/sh
##############################################################
#
# Rock-Solid Node.js Platform on Ubuntu
# Auto-config by apptob.org
# Author: Ruslan Khissamov, email: rrkhissamov@gmail.com
# GitHub: https://github.com/rushis
#
##############################################################

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 VERSION"
    exit 1
fi

if [ $(id -u) -ne 0 ]; then
    echo "Please re-run as root"
    exit 2
fi

TMP="/tmp/node-install"
VERSION=$1

# Update System
echo "System Update"
apt-get -y update
echo "Update completed"

# Install help app
apt-get -y install libssl-dev git-core pkg-config build-essential curl gcc g++ checkinstall

# Download & Unpack Node.js
echo "Download Node.js - v. $VERSION"
mkdir $TMP
curl -L http://nodejs.org/dist/v${VERSION}/node-v${VERSION}.tar.gz | tar -C $TMP -xz
echo "Node.js download & unpack completed"

# Install Node.js
echo "Install Node.js"
cd $TMP/node-v${VERSION}
./configure && make && checkinstall --install=yes --pkgname=nodejs --pkgversion "$VERSION" --default
echo "Node.js install completed"
