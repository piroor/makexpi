#!/usr/bin/env bash

work_dir=$(pwd)
tools_dir=$(cd $(dirname $0) && pwd)

case $(uname) in
  Darwin|*BSD|CYGWIN*) sed="sed -E" ;;
  *)                   sed="sed -r" ;;
esac

while getopts n: OPT
do
  case $OPT in
    "n" ) name="$OPTARG" ;;
  esac
done

while [ "$name" = "" ]
do
  read -p "Input the name of the package> " name
done

cat "$tools_dir/make.bat.in" | \
  $sed -e "s/%APPNAME%/$name/g" > "$work_dir/make.bat"
cat "$tools_dir/make.sh.in" | \
  $sed -e "s/%APPNAME%/$name/g" > "$work_dir/make.sh"
cat "$tools_dir/Makefile.in" | \
  $sed -e "s/%APPNAME%/$name/g" > "$work_dir/Makefile"

if [ -d "$work_dir/.git" ]
then
  git add "make.bat"
  git add "make.sh"
  git add Makefile
  git commit -m "Add scripts to build XPI package" makexpi "make.bat" "make.sh" Makefile
fi
