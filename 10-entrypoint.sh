#!/bin/ash
#
# Launch the podman service/process if not previously launched. If parameters are not provided
# launch as a process. If parameters provided fork the podman as a service.

echo "$0"
TEST="$(/usr/bin/pgrep coredns)"
if [ $? -eq 1 ] ; then
 echo "---------- [ DOMAIN NAME SERVICE(coredns) ] ----------"
 if [ -z "$ENTRYPOINT_PARAMS" ] ; then
  /usr/bin/coredns -conf /etc/coredns/Corefile
  return 1
 fi
fi
