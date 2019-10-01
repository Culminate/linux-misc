#!/bin/bash
# https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions

DEB="deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main"
KEY=https://packages.microsoft.com/keys/microsoft.asc

eval $(apt-config shell APT_SOURCE_PARTS Dir::Etc::sourceparts/d)
CODE_SOURCE_PART=${APT_SOURCE_PARTS}vscode.list

eval $(apt-config shell APT_TRUSTED_PARTS Dir::Etc::trustedparts/d)
CODE_TRUSTED_PART=${APT_TRUSTED_PARTS}microsoft.gpg

wget -qO - $KEY | sudo apt-key --keyring $CODE_TRUSTED_PART add -
echo $DEB | sudo tee $CODE_SOURCE_PART