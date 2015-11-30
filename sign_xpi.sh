#!/usr/bin/env bash
#
# Usage: sign_xpi.sh -t <token> -p <path-to-xpi>
#
#          -t : JWT token generated by get_token.sh, like: "ABCD..."
#          -p : Path to uploading XPI, like "./path/to/file.xpi"
#
# See also: https://blog.mozilla.org/addons/2015/11/20/signing-api-now-available/

case $(uname) in
  Darwin|*BSD|CYGWIN*) sed="sed -E" ;;
  *)                   sed="sed -r" ;;
esac

while getopts t:p: OPT
do
  case $OPT in
    "t" ) token="$OPTARG" ;;
    "p" ) xpi="$OPTARG" ;;
  esac
done

[ "$token" = "" ] && echo 'You must specify a JWT token via "-t"' && exit 1
[ "$xpi" = "" ] && echo 'You must specify a path to XPI via "-p"' && exit 1

install_rdf=$(unzip -p $xpi install.rdf)

extract_initial_em_value() {
  echo "$install_rdf" | \
    grep "em:$1" | head -n 1 | \
    $sed -e "s/.*em:$1=['\"]([^'\"]+).+/\1/" \
         -e "s/.*<em:$1>([^<]+).+/\1/"
}

id=$(extract_initial_em_value id)
version=$(extract_initial_em_value version)

response=$(curl "https://addons.mozilla.org/api/v3/addons/$id/versions/$version/" \
             -H "Authorization: JWT $token" \
             -g -XPUT --form "upload=@$xpi")


exit 0