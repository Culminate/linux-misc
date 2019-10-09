#!/bin/sh

help()
{
cat << HELP
Usage:
	$0 --deb <repo> --key <key>

$0 add repository and key

Options:
	--deb <repository>	add repository
	--debfile <file>	file for repository
	--key <key>			add key
	--keyfile <file>	file for key
HELP
}


while [ -n "$1" ]
do
case "$1" in
--deb)
	deb_array+=("$2")
	shift;;
--debfile)
	deb_file="$2"
	shift;;
--key)
	key_array+=("$2")
	shift;;
--keyfile)
	key_file="$2"
	shift;;
*)
	help
	exit
esac
shift
done

if [ -n "$deb_file" ]; then
	eval $(apt-config shell CODE_SOURCE Dir::Etc::sourceparts/d)
	CODE_SOURCE="${CODE_SOURCE}${deb_file}"
else
	eval $(apt-config shell CODE_SOURCE Dir::Etc::sourcelist/d)
fi

for deb in "${deb_array[@]}"; do 
	echo $deb | sudo tee $CODE_SOURCE
done

if [ -n "$key_file" ]; then
	eval $(apt-config shell CODE_TRUSTED Dir::Etc::trustedparts/d)
	CODE_TRUSTED="--keyring ${CODE_TRUSTED}${key_file}"
fi

for key in "${key_array[@]}"; do 
	wget -qO - $key | sudo apt-key $CODE_TRUSTED add -
done