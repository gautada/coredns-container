#!/bin/ash
if [ "root" == $(/usr/bin/whoami) ] ; then
 echo "Force user change to coredns"
 su coredns
 exit
fi


