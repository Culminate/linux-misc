#!/bin/bash
set -x
command -v curl >/dev/null 2>&1 || { echo >&2 "curl it's not installed. Aborting."; exit 1;}
command -v wget >/dev/null 2>&1 || { echo >&2 "wget it's not installed. Aborting."; exit 1;}
command -v jq   >/dev/null 2>&1 || { echo >&2 "jq it's not installed. Aborting."; exit 1;}

apigithub="https://api.github.com/repos/telegramdesktop/tdesktop/releases/latest"
installpath=/opt/bin/
tmpath=~/Downloads/

randpath=telegram-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)/
filepath=$tmpath$randpath

mkdir $filepath
cd $filepath

json=$(curl -s $apigithub)
tpath=$(echo -n $json | jq '.assets[] | select(.label == "Linux 64 bit: Binary") | .browser_download_url' | tr -d '"')
wget $tpath

mkdir -p $installpath
sudo tar xJf * -C $installpath
sudo ln -sf $installpath/Telegram/Telegram /usr/local/bin/telegram-desktop

rm -r $filepath