#!/usr/bin/env bash
#
# Usage: makexpi.sh -n <addonname> -v -s <suffix> -o
#
#          -v : generate XPI file with version number
#          -f : generate only XPI (high complression)
#          -o : generate only XPI (no complression, omnixpi)
#          -m : minVersion
#          -x : maxVersion
#
#        ex.
#         $ ./makexpi.sh -n myaddon -v 1
#         $ ./makexpi.sh -n myaddon
#
# This script creates two XPI files, <addonname>.xpi and <addonname>_noupdate.xpi.
# If "updateURL" is specified in the install.rdf, it will be removed automatically
# for <addonname>_noupdate.xpi. So, "_noupdate" file can be uplodad to Mozilla Add-ons.
#
# You have to put files in following pattern:
#
#  +[<addonname>]
#    + makexpi.sh           : this script
#    + install.rdf
#    + bootstrap.js
#    + chrome.manifest
#    + [chrome]              : jar, etc.
#    + [content]             : XUL, JavaScript
#    + [locale]              : DTD, properties
#    + [skin]                : CSS, images
#    + [defaults]
#    |  + [preferences]
#    |     + <addonname>.js  : default preferences
#    + [components]          : XPCOM components, XPT
#    + [modules]             : JavaScript code modules
#    + [license]             : license documents
#    + [isp]                 : ISP definitions for Thunderbird
#    + [platform]
#       + [WINNT]            : Microsoft Windows specific files
#       |  + chrome.manifest
#       |  + [chrome]
#       |  + [content]
#       |  + [locale]
#       |  + [skin]
#       + [Darwin]           : Mac OS X specific files
#       |  + chrome.manifest
#       |  + [chrome]
#       |  + [content]
#       |  + [locale]
#       |  + [skin]
#       + [Linux]            : Linux specific files
#          + chrome.manifest
#          + [chrome]
#          + [content]
#          + [locale]
#          + [skin]

work_dir="$(pwd)"
tools_dir="$(cd "$(dirname "$0")" && pwd)"

case $(uname) in
  Darwin|*BSD|CYGWIN*)
    sed="sed -E"
    if gcp --version && gcp --version | grep GNU
    then
      cp="gcp"
    else
      cp="cp"
    fi
    if gsha1sum --version
    then
      sha1sum="gsha1sum"
    else
      sha1sum="sha1sum"
    fi
    ;;
  *)
    sed="sed -r"
    cp="cp"
    sha1sum="sha1sum"
    ;;
esac

use_version=0
nojar=0
xpi_compression_level=9
min_version=0
max_version=0

while getopts fm:n:os:vx: OPT
do
  case $OPT in
    "f" ) nojar=1 ;;
    "m" ) min_version="$OPTARG" ;;
    "n" ) appname="$OPTARG" ;;
    "o" ) nojar=1; xpi_compression_level=0 ;;
    "s" ) suffix="$OPTARG" ;;
    "v" ) use_version=1 ;;
    "x" ) max_version="$OPTARG" ;;
  esac
done

if [ "$suffix" != '' ]
then
	suffix=-$suffix
fi


# for backward compatibility

if [ "$appname" = '' ]
then
	appname=$1
fi
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

if [ "$use_version" = '' ]
then
	use_version=`echo "$2" | $sed -e 's#version=(1|yes|true)#1#ig'`
fi


version=$(grep 'em:version=' install.rdf | \
            $sed -e 's#em:version=##g' | \
            $sed -e 's#[ \t\r\n"]##g')
if [ "$version" = '' ]
then
	version=$(grep '<em:version>' install.rdf | \
	            $sed -e 's#</?em:version>##g' | \
	            $sed -e 's#[ \t\r\n"]##g')
fi
if [ "$version" != '' ]
then
	if [ "$use_version" = '1' ]; then version_part="-$version"; fi;
fi


xpi_contents="chrome components/*.js components/*.xpt components/*/*.xpt modules isp defaults license platform *.js *.rdf chrome.manifest *.inf *.cfg *.light icon*.png"



rm -r -f xpi_temp
rm -f ${appname}${suffix}.xpi
rm -f ${appname}${suffix}_en.xpi
rm -f ${appname}${suffix}_noupdate.xpi
rm -f ${appname}${suffix}_noupdate_en.xpi
rm -f ${appname}${suffix}.lzh
rm -f ${appname}${suffix}-*.xpi
rm -f ${appname}${suffix}-*_en.xpi
rm -f ${appname}${suffix}-*_noupdate.xpi
rm -f ${appname}${suffix}-*_noupdate_en.xpi
rm -f ${appname}${suffix}-*.lzh


# create temp files
mkdir -p xpi_temp

for f in ${xpi_contents}; do
	$cp -rp --parents ${f} xpi_temp/
done

$cp -r content ./xpi_temp/
$cp -r locale ./xpi_temp/
$cp -r skin ./xpi_temp/

cd xpi_temp
mv install.rdf ./install.rdf.base
if [ "$min_version" != "0" ]
then
  cat install.rdf.base \
    | $sed -e "s#<em:minVersion>.*</em:minVersion>#<em:minVersion>${min_version}</em:minVersion>#g" \
           -e "s#em:minVersion=\(\".*\"\|'.*'\)#em:minVersion=\"${min_version}\"#g" \
    > install.rdf
  rm install.rdf.base
  mv install.rdf ./install.rdf.base
fi
if [ "$max_version" != "0" ]
then
  cat install.rdf.base \
    | $sed -e "s#<em:maxVersion>.*</em:maxVersion>#<em:maxVersion>${max_version}</em:maxVersion>#g" \
           -e "s#em:maxVersion=\(\".*\"\|'.*'\)#em:maxVersion=\"${max_version}\"#g" \
    > install.rdf
  rm install.rdf.base
  mv install.rdf ./install.rdf.base
fi
cd ..

# pack platform related resources
if [ -d ./platform ]
then
	$cp -r platform ./xpi_temp/
	cd xpi_temp/platform

	rm components/*.idl

    if [ "$nojar" = "0" ]
    then
		for dirname in *
		do
			if [ -d $dirname/content -o -d $dirname/skin -o -d $dirname/locale ]
			then
				cd $dirname
				mkdir -p chrome
				zip -r -0 chrome/$appname.jar content locale skin -x \*/.svn/\*
				rm -r -f content
				rm -r -f locale
				rm -r -f skin
			fi
		done
	fi
	cd ../..
fi


cd xpi_temp
chmod -R 644 *.*


if [ "$nojar" = "0" ]
then
	# create jar
	mkdir -p chrome
	zip -r -0 ./chrome/$appname.jar content locale skin -x \*/.svn/\*
	if [ ! -f ./chrome/$appname.jar ]
	then
		rm -r -f chrome
	fi
else
	xpi_contents="content locale skin $xpi_contents"
fi


if [ -f ./install.js ]
then
	$cp ../ja.inf ./locale.inf
	$cp ../options.$appname.ja.inf ./options.inf
	chmod 644 *.inf
fi


#create xpi (Japanese)
$cp install.rdf.base install.rdf
zip -r -$xpi_compression_level ../$appname${version_part}${suffix}.xpi $xpi_contents -x \*/.svn/\* || exit 1

#create xpi without update info (Japanese)
rm -f install.rdf
cat install.rdf.base \
  | $sed -e "s#^.*<em:(updateURL|updateKey)>.*</em:(updateURL|updateKey)>##g" \
         -e "s#^.*em:(updateURL|updateKey)=(\".*\"|'.*')##g" \
  > install.rdf

zip -r -$xpi_compression_level ../${appname}${version_part}${suffix}_noupdate.xpi $xpi_contents -x \*/.svn/\* || exit 1



# create lzh
if [ -f ../readme.txt ]
then
	lha a ../$appname${version_part}.lzh ../${appname}${suffix}.xpi ../readme.txt
fi


#create xpi (English)
if [ -f ./install.js ]
then
	rm -f install.rdf
	rm -f locale.inf
	rm -f options.inf
	$cp ../install.rdf ./install.rdf
	$cp ../en.inf ./locale.inf
	$cp ../options.$appname.en.inf ./options.inf
	chmod 644 *.inf
	zip -r -$xpi_compression_level ../${appname}${suffix}${version_part}_en.xpi $xpi_contents -x \*/.svn/\* || exit 1

	rm -f install.rdf
	$sed -e "s#^.*<em:*\(updateURL\|updateKey\)>.*</em:*\(updateURL\|updateKey\)>##g" -e "s#^.*em:*\(updateURL\|updateKey\)=\(\".*\"\|'.*'\)##g" ../install.rdf > install.rdf
	zip -r -$xpi_compression_level ../${appname}${suffix}${version_part}_noupdate_en.xpi $xpi_contents -x \*/.svn/\* || exit 1
fi



#create meta package
if [ -d ../meta ]
then
	rm -f ../meta/${appname}${suffix}.xpi
	$cp ../${appname}${suffix}${version_part}.xpi ../meta/${appname}${suffix}.xpi
fi

# end
cd ..
rm -r -f xpi_temp

# create hash
$sha1sum -b ${appname}*.xpi > sha1hash.txt

exit 0;
