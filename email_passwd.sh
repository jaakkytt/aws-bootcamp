#!/bin/bash

upass=~/upass.csv
email="xxxxx@yyyyy.zz"

cat $upass | while read line;do
	email="$(echo $line | awk -F ';' '{print $1}')"
	pass="$(echo $line | awk -F ';' '{print $2}')"
	(
       		echo "Subject: AWS bootcamp credientials"
       	 	echo "From: SNU <${email}>"
       	 	echo "Content-type: text/plain"
       	 	echo "To: $email"
       	 	echo ""
       	 	echo "url: https://686359387277.signin.aws.amazon.com/console"
       	 	echo "username: $email"
       	 	echo "password: $pass" 
       	 	echo ""
	)|/usr/sbin/sendmail -t
done
