#!/bin/ash
#
# Launch the podman service/process if not previously launched. If parameters are not provided
# launch as a process. If parameters provided fork the podman as a service.

RETURN_VALUE=0
echo "---------- [ DOMAIN NAME SERVICE(coredns) ] ----------"
if [ -z "$ENTRYPOINT_PARAMS" ] ; then
 TEST="$(/usr/bin/pgrep /usr/bin/coredns)"
 if [ $? -eq 1 ] ; then
  /usr/bin/coredns -conf /etc/coredns/Corefile
  return 1
 fi
fi
unset ENTRYPOINT_PARAM
return $RETURN_VALUE
