#!/bin/bash
#
#Copyright (c) 2014-2018 Oracle and/or its affiliates. All rights reserved.
#
#Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
# If AdminServer.log does not exists, container is starting for 1st time
# So it should start NM and also associate with AdminServer
# Otherwise, only start NM (container restarted)
#Define DOMAIN_HOME
echo "Domain Home is: " $DOMAIN_HOME
echo "Domain Name is: " $DOMAIN_NAME

ADD_DOMAIN=1
if [ ! -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log ]; then
    ADD_DOMAIN=0
fi

# Create Domain only if 1st execution
if [ $ADD_DOMAIN -eq 0 ]; then

if [ -z $ADMIN_PASSWORD ]; then
   # Auto generate Oracle WebLogic Server admin password
   while true; do
     s=$(cat /dev/urandom | tr -dc "A-Za-z0-9" | fold -w 8 | head -n 1)
     if [[ ${#s} -ge 8 && "$s" == *[A-Z]* && "$s" == *[a-z]* && "$s" == *[0-9]*  ]]; then
         break
     else
         echo "Password does not Match the criteria, re-generating..."
     fi
   done

   echo ""
   echo "    Oracle WebLogic Server Auto Generated Empty Domain:"
   echo ""
   echo "      ----> 'weblogic' admin password: $s"
   echo ""
else
   s=${ADMIN_PASSWORD}
   echo "      ----> 'weblogic' admin password: $s"
fi
sed -i -e "s|ADMIN_PASSWORD|$s|g" /u01/oracle/create-wls-domain.py

# Create an empty domain
wlst.sh -skipWLSModuleScanning /u01/oracle/create-wls-domain.py
mkdir -p ${DOMAIN_HOME}/servers/AdminServer/security/
echo "username=${ADMIN_USERNAME}" > $DOMAIN_HOME/servers/AdminServer/security/boot.properties
echo "password=$s" >> $DOMAIN_HOME/servers/AdminServer/security/boot.properties
${DOMAIN_HOME}/bin/setDomainEnv.sh
fi


# Start Admin Server and tail the logs
${DOMAIN_HOME}/startWebLogic.sh
touch ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log
tail -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log &

childPID=$!
wait $childPID
