#!/bin/sh


appname=$1
if [ "$appname" = '' ]
	# スクリプト名でパッケージ名を明示している場合：
	# スクリプトがパッケージ用のファイル群と一緒に置かれている事を前提に動作
#	cd "${0%/*}"
then
	# 引数でパッケージ名を明示している場合：
	# スクリプトがパッケージ用のファイル群のあるディレクトリで実行されていることを前提に動作
	appname="${0##*/}"
	appname="${appname%.sh}"
	appname="${appname%_test}"
fi


version=`grep 'em:version=' install.rdf | sed -r -e 's#em:version=##g' | sed -r -e 's#[ \t\r\n"]##g'`
if [ "$version" = '' ]
then
	version=`grep '<em:version>' install.rdf | sed -r -e 's#</?em:version>##g' | sed -r -e 's#[ \t\r\n"]##g'`
fi
if [ "$version" != '' ]
then
	use_version=`echo "$2" | sed -r -e 's#version=(1|yes|true)#1#ig'`
	if [ "$use_version" = '1' ]; then version_part="-$version"; fi;
fi


xpi_contents="chrome components modules isp defaults license platform *.js *.rdf *.manifest *.inf *.cfg *.light"


rm -r -f xpi_temp
rm -f $appname.xpi
rm -f ${appname}_noupdate.xpi
rm -f $appname-*.xpi
rm -f ${appname}-*_noupdate.xpi


# create temp files
mkdir -p xpi_temp

for f in ${xpi_contents}; do
	cp -rp ${f} xpi_temp
done

cp -r content ./xpi_temp/
cp -r locale ./xpi_temp/
cp -r skin ./xpi_temp/


# pack platform related resources
if [ -d ./platform ]
then
	cp -r platform ./xpi_temp/
	cd xpi_temp/platform

	for dirname in *
	do
		if [ -f $dirname/chrome.manifest ]
		then
			cd $dirname
			mkdir -p chrome
			zip -r -0 chrome/$appname.jar content locale skin -x \*/.svn/\*
			rm -r -f content
			rm -r -f locale
			rm -r -f skin
			cd ..
		fi
	done
	cd ../..
fi


cd xpi_temp
chmod -R 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest


# create jar
mkdir -p chrome
zip -r -0 ./chrome/$appname.jar content locale skin -x \*/.svn/\*
if [ ! -f ./chrome/$appname.jar ]
then
	rm -r -f chrome
fi


#create xpi
zip -r -9 ../$appname${version_part}.xpi $xpi_contents -x \*/.svn/\* || exit 1

#create xpi without update info
rm -f install.rdf
sed -e "s#^.*<em:*\(updateURL\|updateKey\)>.*</em:*\(updateURL\|updateKey\)>##g" -e "s#^.*em:*\(updateURL\|updateKey\)=\(\".*\"\|'.*'\)##g" ../install.rdf > install.rdf
zip -r -9 ../${appname}${version_part}_noupdate.xpi $xpi_contents -x \*/.svn/\* || exit 1


#create meta package
if [ -d ../meta ]
then
	rm -f ../meta/$appname.xpi
	cp ../$appname${version_part}.xpi ../meta/$appname.xpi
fi

# end
cd ..
rm -r -f xpi_temp

# create hash
sha1sum -b ${appname}*.xpi > sha1hash.txt

exit 0;
