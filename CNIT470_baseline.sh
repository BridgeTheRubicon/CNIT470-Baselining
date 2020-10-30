#!/bin/bash
#
#This is a baselining script for *NIX-like machines. This is specifically for CNIT470.
#Version: 1.0
#Author:  Andrew Burmeister
#Creation Date: 10/16/2020
#
#make the file
FILE = uname+date+".txt"
#place all the information into the file via tee.
#echo is just for spacing and formating.
uname -a > $FILE
echo "" | tee -a $FILE
rpm -qa | less and dpkg -l >> $FILE
echo "" | tee -a $FILE
ps -aux >> $FILE
echo "" | tee -a $FILE
crontab -u root -l >> $FILE
echo "" | tee -a $FILE
top >> $FILE
echo "" | tee -a $FILE
top >> $FILE
echo "" | tee -a $FILE
top >> $FILE
echo "" | tee -a $FILE
ifstat >> $FILE
echo "" | tee -a $FILE
sha1sum  /bin >> $FILE
sha1sum  /sbin >> $FILE
sha1sum  /dev >> $FILE
sha1sum  /etc >> $FILE
#making the FTP connection
HOST = "10.51.32.80"
USER = "blueteam"
PASS = "HandsNoSwiping!"
#making the transfer (is weird becuase ftp is an interactive command)
ftp -n $Host <<END
quote USER $USER
quote PASS $PASS
binary
put /home/blueteam/baseline/$FILE
quit
END
#end of script
exit 0
