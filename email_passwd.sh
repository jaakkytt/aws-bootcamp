#!/bin/bash

upass=~/upass.csv
sender_email="xxxx@yyyy.zz"
url="https://686359387277.signin.aws.amazon.com/console"

cat $upass | while read line;do
	email="$(echo $line | awk -F ';' '{print $1}')"
	pass="$(echo $line | awk -F ';' '{print $2}')"
	(
       		echo "Subject: AWS bootcamp account"
       	 	echo "From:AWS Bootcamp Team <${sender_email}>"
		echo "Return-Path: ${sender_email}"
		echo "Replay-To: ${sender_email}"
       	 	echo "Content-type: text/plain"
       	 	echo "To: $email"
       	 	echo "Hello"
		echo ""
		echo "Here are your AWS account details. Please take a couple of minutes to follow the instructions below and set your account password."
		echo ""
		echo "Head over to the sign-in page: $url"
		echo ""
       	 	echo "User Name: $email"
       	 	echo "Temporary Login Password: $pass" 
		echo "(Note that you have to leave "I have an MFA token" unchecked.)"
		echo ""
		echo "After signing in you'll be prompted to change your password."
       	 	echo ""
		echo "AWS Bootcamp Team"
	)|/usr/sbin/sendmail -t -f${sender_email}
done
