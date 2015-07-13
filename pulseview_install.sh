#!/bin/bash

# Authored by Ilias Giechaskiel, https://ilias.giechaskiel.com
# Based on directions at http://sigrok.org/wiki/Linux,
# http://sigrok.org/wiki/Firmware, and http://sigrok.org/wiki/Fx2lafw
# DO NOT RUN AS ROOT AND USE WITH CAUTION.
# Delete $TEMP_DIR folder manually once finished.

set -e

TEMP_DIR=sigrok-download-dir

function install_prerequisites {
    # packages needed
    sudo apt-get install \
        git-core gcc make autoconf automake libtool g++ autoconf-archive pkg-config libglib2.0-dev \
        libglibmm-2.4-dev libzip-dev libusb-1.0-0-dev libftdi-dev check doxygen python-numpy python-dev \
        python-gi-dev python-setuptools swig default-jdk python3-dev libqt4-dev libboost-all-dev sdcc

    # this doesn't exist in autoconf-archive for some distributions
    sudo wget "http://git.savannah.gnu.org/gitweb/?p=autoconf-archive.git;a=blob_plain;f=m4/ax_cxx_compile_stdcxx_11.m4" -O "/usr/share/aclocal/ax_cxx_compile_stdcxx_11.m4"
}

function install_postrequisites {
    # rules for identifying USB devices. assumes have downloaded libsigrokdecode from git already
    sudo cp libsigrokdecode/contrib/z60_libsigrok.rules /etc/udev/rules.d/
    sudo /etc/init.d/udev restart
    sudo gpasswd -a $USER plugdev
    
    # So that pulseview finds necessary shared objects
    sudo ldconfig /usr/local/lib
}

function install_package {
    git clone "git://sigrok.org/$1"
    cd "$1"
    ./autogen.sh
    ./configure
    make
    sudo make install
    cd -
}

function install_pulseview {
    git clone git://sigrok.org/pulseview
    cd pulseview
    cmake .
    make
    sudo make install
    cd -
}

mkdir "$TEMP_DIR"
cd "$TEMP_DIR"
install_prerequisites

install_package libserialport
install_package libsigrok
install_package libsigrokdecode
install_package sigrok-cli
install_package sigrok-firmware
install_pulseview
install_package sigrok-firmware-fx2lafw

install_postrequisites
cd -
