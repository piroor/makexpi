#!/bin/sh

for dirname in *
do

	if [ -d $dirname/.svn ]
	then
		cd $dirname
		echo "cleanup: $dirname"
		svn cleanup
		echo "update: $dirname"
		svn up
		cd ..
	fi

	if [ -d $dirname/.git ]
	then
		cd $dirname
		echo "pull: $dirname"
		git pull
		echo "submodule update: $dirname"
		git submodule update --init ""
		git submodule foreach 'git fetch;git checkout origin/master'
		cd ..
	fi

done

