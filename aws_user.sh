#!/bin/bash

iam_group="AWSBootcamp"
users="/tmp/e-mails.csv"
upass=~/upass.csv

var=(
AWS_ACCESS_KEY
AWS_ACCESS_KEY_ID
AWS_SECRET_KEY
AWS_SECRET_ACCESS_KEY
)

function help {
        echo "usage: $0 --action [create|destroy]"
        exit 1
}


if [ "$#" -lt 2 ]; then
    help
fi

while test $# -gt 0
do
    case $1 in
        -a|--action)
	    action="$2"
	    shift
	    ;;
        -h|--help)
            help
            shift
            ;;
        *)
            help
            shift
            ;;
    esac
    shift
done

for v in "${var[@]}";do
        test -z "$(env | grep $v | grep -v grep)" && \
                echo Enviromental variable \"$v\" is missing.
done
pwgen > /dev/null || exit

test -f $users && awk -F ';' '/@/ {print $2}' $users | tr -d '\r' | sort | uniq | \
	while read email;do 
		if [ "$action" == "create" ];then
			aws iam create-user --user-name "${email}"
			aws iam add-user-to-group --user-name "${email}" --group-name "${iam_group}"
			pass="$(pwgen | head -n1)"
			aws iam create-login-profile --user-name "${email}" --password "${pass}"
			echo "${email};${pass}" >> "$upass"
		else 
			aws iam remove-user-from-group --group-name "${iam_group}" --user-name "${email}"
			aws iam delete-login-profile --user-name "${email}"
			aws iam delete-user --user-name "${email}"
		fi
	done	

test -f "$upass" && ( cat "$upass" && rm "$upass" )
