#!/bin/bash
version=201711141050

WAS_INSTALL_ROOT=/opt/IBM/WebSphere/AppServer
profiles=`grep "<profile " ${WAS_INSTALL_ROOT}/properties/profileRegistry.xml | sed "s/.*path=\"\([a-zA-Z0-9\/]*\)\".*/\1/"` 
if [ "$1" == "Sync" ]; then
  echo "Stop Node Agents syncronous."
  options=
else
  options="-nowait"
fi

for i in $profiles; do
  echo "Profile: $i"
  if [ -d "$i/servers/nodeagent" ]; then
    stopNode=0
    if [ -f "$i/logs/nodeagent/nodeagent.pid" ]; then
      PID=$(cat $i/logs/nodeagent/nodeagent.pid)
      if [ "$PID" ]; then
        erg=$(ps -p $PID)
        if [ $? -eq 0 ]; then
          echo "Process with PID is running. Need to stop."
          stopNode=1
        fi
      fi
    fi
    if [ $stopNode -eq 1 ]; then
      if [ -f "$i/bin/stopNode.sh" ]; then
        $i/bin/stopNode.sh $options
      fi
    fi
  else
    echo "Profile has no nodeagent."
  fi
done

