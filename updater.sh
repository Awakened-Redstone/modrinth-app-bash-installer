#!/bin/bash

if [ ! -d "$HOME/.appcustom" ]; then
  mkdir "$HOME/.appcustom"
fi

if [ ! -d "$HOME/.appcustom/modrinth" ]; then
  mkdir "$HOME/.appcustom/modrinth"
fi

cd ~/.appcustom/modrinth/ || exit

updates_json=$(curl -s https://launcher-files.modrinth.com/updates.json)
latest=$(echo "$updates_json" | jq -r .version)

if [ ! -f "version" ]; then
  current="0.0.0"
else
  current=$(cat version)
fi

if [ ! "$latest" == "$current" ]; then
  echo "Installing Modrinth App $latest"
  url=$(echo "$updates_json" | jq -r ".platforms.\"linux-x86_64\".install_urls[2]")
  wget --https-only -nd -q --show-progress \
    -O "modrinth_app.rpm" "$url" \
    --progress=dot:binary 2>&1 | \
    stdbuf -o0 grep -o "[0-9]\+%" | \
    stdbuf -o0 sed 's/%//g' | \
    zenity --progress \
      --title="Installing Modrinth App $latest" \
      --text="Downloading file..." \
      --percentage=0 \
      --auto-close \
      --auto-kill

  ark --batch ./modrinth_app.rpm
  rm modrinth_app.rpm
  if [ -d "./app" ]; then
    rm -r "./app.old"
    mv "./app" "./app.old"
  fi
  mkdir "app"
  mv usr/* "./app/"
  rm -r "./usr"
  echo "$latest" > version
fi

WEBKIT_DISABLE_COMPOSITING_MODE=1 ./app/bin/ModrinthApp
