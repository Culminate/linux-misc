#!/bin/sh
# https://www.sublimetext.com/docs/3/linux_repositories.html#apt

../add-repo.sh --deb "deb https://download.sublimetext.com/ apt/stable/" --key https://download.sublimetext.com/sublimehq-pub.gpg \
	--debfile sublimetext.list --keyfile sublimetext.gpg