#!/bin/bash
# set -x # debug

apigithub="https://api.github.com/repos/telegramdesktop/tdesktop/releases/latest"
telegramlink=telegram-desktop
installpath=/opt/bin/
tmpath=~/Downloads/

help() {
	echo "
Telegram installer from github official repository
Usage:
	options:
	-i	install telegram
	-r	remove telegram
	"
}

check_command() {
	command -v $1 >/dev/null 2>&1 || { echo >&2 "$1 is not installed. Aborting."; exit 1;}
}

install() {
	randpath=telegram-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)/
	filepath=$tmpath$randpath

	mkdir $filepath
	cd $filepath

	json=$(curl -s $apigithub)
	tpath=$(echo -n $json | jq '.assets[] | select(.label == "Linux 64 bit: Binary") | .browser_download_url' | tr -d '"')
	wget $tpath

	sudo mkdir -p $installpath
	sudo tar xJf * -C $installpath
	sudo ln -sf $installpath\Telegram/Telegram /usr/local/bin/$telegramlink

	rm -r $filepath
	echo "Telegram successfully installed."
	exit 0;
}

remove() {
	linkpath=$(command -v $telegramlink 2>&1)
	if [ -n $linkpath ]; then
		echo "Symbolic link $telegramlink not found. Aborting."
		exit 1;
	fi
	tipath=$(readlink $linkpath)
	sudo rm -rf $(dirname $tipath)
	sudo rm -rf $linkpath

	echo "Telegram successfully deleted."
	exit 0;
}

check_command curl
check_command wget
check_command jq

if [ -n $1 ]; then
	help
fi

while [ -n "$1" ]
do
case "$1" in
-i)
	echo "install"
	install;;
-r)
	echo "remove";
	remove;;
*)
	help
esac
shift
done