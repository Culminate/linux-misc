#!/bin/sh
# https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions

../add_repo.sh --deb "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" \
	--key https://packages.microsoft.com/keys/microsoft.asc \
	--debfile vscode.list --keyfile microsoft.gpg