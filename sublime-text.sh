#!/bin/bash
# https://www.sublimetext.com/docs/3/linux_repositories.html#apt

DEB="deb https://download.sublimetext.com/ apt/stable/"
KEY=https://download.sublimetext.com/sublimehq-pub.gpg

eval $(apt-config shell APT_SOURCE_PARTS Dir::Etc::sourceparts/d)
CODE_SOURCE_PART=${APT_SOURCE_PARTS}sublimetext.list

eval $(apt-config shell APT_TRUSTED_PARTS Dir::Etc::trustedparts/d)
CODE_TRUSTED_PART=${APT_TRUSTED_PARTS}sublimetext.gpg

wget -qO - $KEY | sudo apt-key --keyring $CODE_TRUSTED_PART add -
echo $DEB | sudo tee $CODE_SOURCE_PART