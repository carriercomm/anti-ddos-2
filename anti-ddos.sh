#!/bin/sh
#
#
# Set here a minimum number of connections for action to be executed
#
FR_MIN_CONN=5000
TMP_PREFIX='/tmp/ofedosong'
TMP_FILE=`mktemp $TMP_PREFIX.XXXXXXXX`

# n - do not resolve ip to domain
# t - do not show tip info 
# u - ???
# f - show IPv4 only (without sockets)
netstat -ntu -f inet| awk '{if(NR>2 && NF=6) print $5}' | cut -d. -f1-4 | grep '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' | sort | uniq -c | sort -nr | grep -v "127.0.0.1" > $TMP_FILE

while read line; do

 CURR_LINE_CONN=$(echo $line | cut -d" " -f1)
 CURR_LINE_IP=$(echo $line | cut -d" " -f2)

 if [ $CURR_LINE_CONN -lt $FR_MIN_CONN ]; then
  break
 fi
 
 #
 # You can insert your own logic here (e.g. ban with your favourite firewall). Now it just prints the IP to console.
 #
 echo "Adding to ban: ${CURR_LINE_IP} (Conn: ${CURR_LINE_CONN}) $(/bin/date)"
 /sbin/ipfw table 10 add $CURR_LINE_IP

 echo "Report:"
 netstat -n | grep -i "${CURR_LINE_IP}"

done < $TMP_FILE

rm -f $TMP_PREFIX.*
