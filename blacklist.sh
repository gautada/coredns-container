#!/bin/sh

TMPDIR=$(mktemp -d -t ci-XXXXXXXXXX)

curl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts |  grep "^0\.0\.0\.0 " | cut -d' ' -f2 > $TMPDIR/tmp_hosts
curl https://adaway.org/hosts.txt |  grep "^127\.0\.0\.1 " | cut -d' ' -f2 >> $TMPDIR/tmp_hosts
curl https://v.firebog.net/hosts/AdguardDNS.txt >> $TMPDIR/tmp_hosts
curl https://v.firebog.net/hosts/Admiral.txt >> $TMPDIR/tmp_hosts
curl https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt |  grep "^0\.0\.0\.0 " | cut -d' ' -f2 >> $TMPDIR/tmp_hosts
curl https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt >> $TMPDIR/tmp_hosts

# cat hosts.sb | grep "^0\.0\.0\.0 " | cut -d' ' -f2 | sort -u  
#  grep "^0\.0\.0\.0 " | cut -d' ' -f2 | sort -u

input="$TMPDIR/tmp_hosts"
while IFS= read -r line
do
  echo "127.0.0.1 $line"
done < "$input"
