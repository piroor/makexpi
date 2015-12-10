#!/usr/bin/env bash

work_dir=$(pwd)
tools_dir=$(cd $(dirname $0) && pwd)

case $(uname) in
  Darwin|*BSD|CYGWIN*) sed="sed -E" ;;
  *)                   sed="sed -r" ;;
esac

while getopts t:p:o:k:s:e: OPT
do
  case $OPT in
    "n" ) name="$OPTARG" ;;
  esac
done

while [ "$name" = "" ]
do
  read -p "Input the name of the package> " name
done

cat "$tools_dir/APPNAME.bat.in" | \
  $sed -e "s/%APPNAME%/$name/g" > "$work_dir/$name.bat"
cat "$tools_dir/APPNAME.sh.in" | \
  $sed -e "s/%APPNAME%/$name/g" > "$work_dir/$name.sh"
cat "$tools_dir/Makefile.in" | \
  $sed -e "s/%APPNAME%/$name/g" > "$work_dir/Makefile"

if [ -d "$work_dir/.git" ]
then
  git add "$name.bat"
  git add "$name.sh"
  git add Makefile
  git commit -m "Add scripts to build XPI package" makexpi "$name.bat" "$name.sh" Makefile
fi
