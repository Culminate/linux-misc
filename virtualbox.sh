#!/bin/bash
# https://www.virtualbox.org/wiki/Linux_Downloads#Debian-basedLinuxdistributions

DEB="deb https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib"
KEY1=https://www.virtualbox.org/download/oracle_vbox_2016.asc
KEY2=https://www.virtualbox.org/download/oracle_vbox.asc

eval $(apt-config shell APT_SOURCE_PARTS Dir::Etc::sourceparts/d)
CODE_SOURCE_PART=${APT_SOURCE_PARTS}virtualbox.list

eval $(apt-config shell APT_TRUSTED_PARTS Dir::Etc::trustedparts/d)
CODE_TRUSTED_PART=${APT_TRUSTED_PARTS}virtualbox.gpg

wget -qO - $KEY1 | sudo apt-key --keyring $CODE_TRUSTED_PART add -
wget -qO - $KEY2 | sudo apt-key --keyring $CODE_TRUSTED_PART add -
echo $DEB | sudo tee $CODE_SOURCE_PART