#!/bin/bash

tools_dir=$(cd $(dirname $0) && pwd)

while getopts d:p: OPT
do
  case $OPT in
    # リポジトリをcloneした先のディレクトリ。
    "d" ) project_dir="$OPTARG" ;;
    # keyfile.pubのパス。
    "p" ) public_key="$OPTARG" ;;
  esac
done

if [ "$project_dir" = '' ]; then
  echo "no project directory specified"
  exit 1
fi
project_dir=$(cd "$project_dir" && pwd)

if [ "$public_key" = '' ]; then
  echo "no public key specified"
  exit 1
fi
public_key="$(cd $(dirname "$public_key") && pwd)/$(basename "$public_key")"

# sedのオプションの違いを吸収しておく。
case $(uname) in
  Darwin|*BSD|CYGWIN*) sed="sed -E" ;;
  *)                   sed="sed -r" ;;
esac

cd "$project_dir"

package_name=$(cat "$project_dir/Makefile" | \
               grep "PACKAGE_NAME" | \
               head -n 1 | cut -d "=" -f 2 | \
               $sed -e "s/\\s*//#")
public_key=$(cat "$public_key" | \
             grep -v -E "^--" | \
             tr -d "\r" | tr -d "\n")
version=$(cat "$project_dir/history.en.md" | \
          grep -E "^ - [0-9\\.]+" | \
          head -n 1 | \
          $sed -e "s/^ - //" | \
          tr -d "\r" | tr -d "\n")

# 自動生成されたバージョン番号を控えておく。
echo "$version" > release_version.txt

cp install.rdf install.rdf.bak

# リリースビルド用として、install.rdfを書き換える。
# バージョン番号の末尾に今日の日付を付ける。
$sed -e "s/(em:version=\")[^\"]*/\\1$version/" \
     -i install.rdf
update_rdf="${package_name}.update.rdf"
# update.rdfの参照先と、公開鍵を書き換える。
$sed -e "s#/xul/update.rdf#/xul/xpi/updateinfo/${update_rdf}#" \
     -i install.rdf
$sed -e "s#([^/]em:updateKey[=>\"]+)[^\"<]+#\\1${public_key}#" \
     -i install.rdf

make

rm install.rdf
mv install.rdf.bak install.rdf

exit 0
