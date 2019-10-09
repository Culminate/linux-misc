# Miscellaneous script for deb-based linux

## telegram_install.sh
Download lastest release telegram from github repository https://github.com/telegramdesktop/tdesktop/releases/latest.
Install in /opt/bin directory and create symbolic link to /usr/local/bin/telegram-desktop.
You can also remove it with the -r option.

## mangrep.sh
run grep for all man files

## sudowithoutpasswd.sh
allow use sudo without password for current user

## add-repo.sh
Tool for add repo and key
exaple:
```bash
add_repo.sh --deb "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" \
    --key https://packages.microsoft.com/keys/microsoft.asc \
    --debfile vscode.list --keyfile microsoft.gpg`
```

this string equivalent to:
```bash
# for clear debian
echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | apt-key /etc/apt/trusted.gpg.d/microsoft.gpg add -
```