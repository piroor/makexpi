#!/bin/sh

appname=${0##*/}
appname=${appname%.sh}

makexpi/makexpi.sh -n $appname -o

