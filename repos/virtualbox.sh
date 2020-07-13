#!/bin/sh
# https://www.virtualbox.org/wiki/Linux_Downloads#Debian-basedLinuxdistributions

../add-repo.sh --deb "deb https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib"\
	--key https://www.virtualbox.org/download/oracle_vbox_2016.asc --key https://www.virtualbox.org/download/oracle_vbox.asc \
	--debfile virtualbox.list --keyfile virtualbox.gpg