#!/usr/bin/env bash
#
# Usage: get_token.sh -k <key> -s <secret> -e <expire-seconds>
#
#          -k : key aka JWT issuer, like "user:xxxxxx:xxx"
#          -s : JWT secret, like "0123456789abcdef..."
#          -e : seconds to expire the token
#
# See also: https://blog.mozilla.org/addons/2015/11/20/signing-api-now-available/

tools_dir=$(cd $(dirname $0) && pwd)

if [ ! -d ./node_modules/jsonwebtoken ]
then
  npm install jsonwebtoken --save
fi

while getopts k:s:e: OPT
do
  case $OPT in
    "k" ) key="$OPTARG" ;;
    "s" ) secret="$OPTARG" ;;
    "e" ) expire="$OPTARG" ;;
  esac
done

[ "$key" = "" ] && echo 'You must specify the issuer via "-k"' 1>&2 && exit 1
[ "$secret" = "" ] && echo 'You must specify the secret via "-s"' 1>&2 && exit 1

[ "$expire" = "" ] && expire=60

echo "var jwt = require('jsonwebtoken'); \
 \
var issuedAt = Math.floor(Date.now() / 1000); \
var payload = { \
  iss: '$key', \
  jti: Math.random().toString(), \
  iat: issuedAt, \
  exp: issuedAt + $expire \
}; \
 \
var secret = '$secret'; \
var token = jwt.sign(payload, secret, { algorithm: 'HS256' }); \
 \
console.log(token);" | nodejs

exit 0
