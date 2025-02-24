#!/bin/basj


# INIT Function
function download_share_content {
  #smbclient \\\\$target\\$share -N -c "ls" | while read line;
  smbclient \\\\$target\\$share --user="active/SVC_TGS%GPPstillStandingStrong2k18" -c "ls" | while read line;
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
		#smbclient \\\\$target\\$share -N -c "prompt OFF;recurse ON;mget *"
		smbclient \\\\$target\\$share --user=SVC_TGS%GPPstillStandingStrong2k18 -c "prompt OFF;recurse ON;mget *"
	fi
  done
}

# INIT Variable
# was ist das target?
target=10.10.10.100

# wo willst du die sachen hin haben?
desc_path='/tmp'


# list all shares
echo "[Config] traget is ${target}"

#shares=$(smbclient -L \\\\$target\\ -N | grep -E '^[[:space:]]+[A-Za-z0-9_]+' | grep -v 'Sharename' | awk '{print $1}')
shares=$(smbclient -L \\\\$target\\ --user="active/SVC_TGS%GPPstillStandingStrong2k18" | grep -E '^[[:space:]]+[A-Za-z0-9_]+' | grep -v 'Sharename' | awk '{print $1}')
command_result=$?

# ist die list leer?
if [ -z "$shares" ]; then
	echo 'not able to fetch or list is empty!'
	echo " command result is: $command_result"
	echo ' comannd will exit!'
	exit
fi

echo "[result] list of the shares:"
for share in $share;
do 
	echo "  $share"
done

# get all content of the shares
## what to do with not allowed?
echo '[share query]:'
for share in $shares; 
do
	#query=$(smbclient \\\\$target\\$share -N -c "ls")
	query=$(smbclient \\\\$target\\$share --user="active/SVC_TGS%GPPstillStandingStrong2k18" -c "ls")
	command_result=$?

	if [ $command_result -eq 0 ];
	then
		echo "  $share is accessible"
		download_share_content "${query}"
	fi	
done
