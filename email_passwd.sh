#!/bin/bash

upass=~/upass.csv
email="xxxxx@yyyyy.zz"

cat $upass | while read line;do
	email="$(echo $line | awk -F ';' '{print $1}')"
	pass="$(echo $line | awk -F ';' '{print $2}')"
	(
       		echo "Subject: AWS bootcamp credientials"
       	 	echo "From:AWS Bootcamp Team <${email}>"
       	 	echo "Content-type: text/plain"
       	 	echo "To: $email"
       	 	echo "Hi,"
		echo ""
		echo "Following information is needed during AWS bootcamp."
		echo ""
       	 	echo "url: https://686359387277.signin.aws.amazon.com/console"
       	 	echo "username: $email"
       	 	echo "password: $pass" 
		echo ""
		echo "If you have any questions or problems, then please let us know."
       	 	echo "AWS Bootcamp Team"
	)|/usr/sbin/sendmail -t
done
