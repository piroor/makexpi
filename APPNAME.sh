#!/bin/sh

appname=${0##*/}
appname=${appname%.sh}

cp buildscript/makexpi.sh ./
./makexpi.sh $appname version=0
rm ./makexpi.sh

