#!/usr/bin/env bash

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


tag=$(git describe | cut -d "-" -f 1)
current=$(git describe | cut -d "-" -f 3)

git stash save
git checkout "$tag"

package_name=$(cat "$project_dir/Makefile" | \
               grep "PACKAGE_NAME" | \
               head -n 1 | cut -d "=" -f 2 | \
               $sed -e "s/\\s*//")
public_key=$(cat "$public_key" | \
             grep -v -E "^--" | \
             tr -d "\r" | tr -d "\n")
version=$(cat "$project_dir/history.en.md" | \
          grep -E "^ - [0-9\\.]+" | \
          head -n 1 | \
          $sed -e "s/^ - //" | \
          $sed -e "s/ *\([^\)]+\) *\$//" | \
          tr -d "\r" | tr -d "\n")

result=0
if [ "$package_name" = "" ]; then
  echo "ERROR: couldn't detect the project name for $project_dir"
  result=1
elif [ "$version" = "" ]; then
  echo "ERROR: couldn't detect the latest release version of $package_name"
  result=1
else
  # 自動生成されたバージョン番号を控えておく。
  echo "$version" > release_version.txt

  # リリースビルド用として、install.rdfを書き換える。
  $sed -e "s/(em:version=\")[^\"]*/\\1$version/" \
       -i install.rdf
  update_rdf="${package_name}.update.rdf"
  # update.rdfの参照先と、公開鍵を書き換える。
  $sed -e "s#([^/]em:updateURL[=>\"]+)[^\"<]*#\\1http://piro.sakura.ne.jp/xul/xpi/updateinfo/${update_rdf}#" \
       -i install.rdf
  $sed -e "s#([^/]em:updateKey[=>\"]+)[^\"<]*#\\1${public_key}#" \
       -i install.rdf

  make

  git reset --hard
fi

git checkout master
#master_head_commit=$(git describe | cut -d "-" -f 3)
#if [ "$master_head_commit" != $current ]; then
#  git checkout $current
#fi

git stash pop

exit $result
