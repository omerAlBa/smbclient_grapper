#!/bin/bash

# help function

if [ $1 == '--help' ];
then
	echo '############ Help Section ############ '
	echo " first argument is for targegt "
	echo " second argument is for ad_name "
	echo " third argument is for ad_user "
	echo " four argument is for ad_pass "
	exit
fi

# INIT Function
function download_share_content {
  smbclient \\\\$target\\$share $([ -n "$user" ] && echo "--user=${user}" || echo "-N") -c "ls" | while read line;
  do
	echo $line | grep -q -E 'anony.*|\. |\.\.'
	command_result=$?
	if [[ $command_result == 0 ]];
	then
		continue
	fi

  	# Extract the name and type (file or folder)
	name=$(echo "$line" | awk '{print $1}')
	type=$(echo "$line" | awk '{print $2}')

	if [[ "$type" == "D" ]]; then
		smbclient \\\\$target\\$share $([ -n "$user" ] && echo "--user=${user}" || echo "-N") -c "prompt OFF;recurse ON;mget *"
	fi
  done
}

# INIT Variable
# was ist das target?
target=$1
ad_name=$2
ad_user=$3
ad_password=$4


if [ -n "$ad_user" ] && [ -n "$ad_user" ] && [ -n $ad_name ];
then
	#create user credential
	user="${ad_name}/${ad_user}%${ad_password}"
fi

echo $user
# wo willst du die sachen hin haben?
desc_path='/tmp'


# list all shares
echo "[Config] traget is ${target}"

shares=$(smbclient -L \\\\$target\\ $([ -n "$user" ] && echo "--user=${user}" || echo "-N") | grep -E '^[[:space:]]+[A-Za-z0-9_]+' | grep -v 'Sharename' | awk '{print $1}')
command_result=$?

# ist die list leer?
if [ -z "$shares" ]; then
	echo 'not able to fetch or list is empty!'
	echo " command result is: $command_result"
	echo ' comannd will exit!'
	exit
fi

echo "[result] list of the shares:"
for share in $shares;
do
	echo "  $share"
done

# get all content of the shares
## what to do with not allowed?
echo '[share query]:'
for share in $shares;
do
	query=$(smbclient -L \\\\$target\\$share $([ -n "$user" ] && echo "--user=${user}" || echo "-N") -c "ls")
	command_result=$?

	if [ $command_result -eq 0 ];
	then
		echo "  $share is accessible"
		download_share_content "${query}"
	fi
done
