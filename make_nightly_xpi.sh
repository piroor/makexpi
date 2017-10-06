#!/usr/bin/env bash

tools_dir=$(cd $(dirname $0) && pwd)

while getopts d:p:o: OPT
do
  case $OPT in
    # リポジトリをcloneした先のディレクトリ。
    "d" ) project_dir="$OPTARG" ;;
    # keyfile.pubのパス。
    "p" ) public_key="$OPTARG" ;;
    # project owner
    "o" ) project_owner="$OPTARG" ;;
  esac
done

if [ "$project_dir" = '' ]; then
  echo "no project directory specified"
  exit 1
fi
project_dir=$(cd "$project_dir" && pwd)

if [ -f install.rdf ]; then
  if [ "$public_key" = '' ]; then
    echo "no public key specified"
    exit 1
  fi
  public_key="$(cd $(dirname "$public_key") && pwd)/$(basename "$public_key")"
fi

# sedのオプションの違いを吸収しておく。
case $(uname) in
  Darwin|*BSD|CYGWIN*) sed="sed -E" ;;
  *)                   sed="sed -r" ;;
esac

if [ -d "$project_dir" ]
then
  cd "$project_dir"
else
  project_name=$(basename "$project_dir")
  if [ "$project_owner" = "" ]; then project_owner=$project_name; fi
  cd $(dirname "$project_dir")
  git clone git@github.com:$project_owner/$project_name.git
  cd "$project_dir"
fi

package_name=$(cat "$project_dir/Makefile" | \
               grep "PACKAGE_NAME" | \
               head -n 1 | cut -d "=" -f 2 | \
               $sed -e "s/\\s*//")
if [ "$public_key" != '' ]; then
  public_key=$(cat "$public_key" | \
               grep -v -E "^--" | \
               tr -d "\r" | tr -d "\n")
fi



update_manifest_json() {
  # for WebExtensions addons
  cp manifest.json manifest.json.bak

  # ナイトリービルド用として、manifest.jsonを書き換える。
  # バージョン番号の末尾に現在のリビジョン数を付ける。
  version=$(cat manifest.json |
              jq -r ".version" |
              $sed -e "s/$/.$(git log --oneline | wc -l)/")
  echo "$version" > nightly_version.txt
  cat manifest.json.bak |
    jq ".version |= \"$version\"" > manifest.json

  make

  rm manifest.json
  mv manifest.json.bak manifest.json
}

update_install_rdf() {
  cp install.rdf install.rdf.bak

  # ナイトリービルド用として、install.rdfを書き換える。
  # バージョン番号の末尾に今日の日付を付ける。
  $sed -e "s/(em:version=\"[^\"]+)\\.[0-9]{10}/\\1/" \
       -i install.rdf
  $sed -e "s/(em:version=\"[^\"]+)/\\1.$(date +%Y%m%d00)a$(date +%H%M%S)/" \
       -i install.rdf
  update_rdf="${package_name}.update.rdf"
  # update.rdfの参照先と、公開鍵を書き換える。
  $sed -e "s#/xul/update.rdf#/xul/xpi/nightly/updateinfo/${update_rdf}#" \
       -i install.rdf
  $sed -e "s#([^/]em:updateKey[=>\"]+)[^\"<]+#\\1${public_key}#" \
       -i install.rdf

  # 自動生成されたバージョン番号を控えておく。
  version=$(cat install.rdf | \
            grep "em:version" | head -n 1 | \
            $sed -e "s#[^\">]*[\">]([^\"<]+).*#\\1#" | \
            tr -d "\r" | tr -d "\n")
  echo "$version" > nightly_version.txt

  make

  rm install.rdf
  mv install.rdf.bak install.rdf
}



if [ -f manifest.json ]
then
  update_manifest_json
else
  update_install_rdf
  if [ -f webextensions/manifest.json ]
  then
    (cd webextensions &&
     update_manifest_json &&
     mv *.xpi ../)
  fi
fi

exit 0
