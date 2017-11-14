#!/bin/bash
version=201711141050
WAS_INSTALL_ROOT=/opt/IBM/WebSphere/AppServer

profiles=`grep "<profile " ${WAS_INSTALL_ROOT}/properties/profileRegistry.xml | sed "s/.*path=\"\([a-zA-Z0-9\/]*\)\".*/\1/"` 

if [ "$1" == "Sync" ]; then
  echo "Stop Servers syncronous."
  options=
else
  options="-nowait"
fi

for i in $profiles; do
  echo "Profile: $i"
  pushd $i/servers > /dev/null 2>&1
  for D in *; do 
    if [ ! "$D" == "nodeagent" -a ! "$D" == "dmgr" ]; then
      stopServer=0
      if [ -f "$i/logs/${D}/${D}.pid" ]; then
        PID=$(cat $i/logs/${D}/${D}.pid)
        if [ "$PID" ]; then
          erg=$(ps -p $PID)
          if [ $? -eq 0 ]; then
            echo "Process with PID is running. Need to stop"
            stopServer=1
          fi
        fi
      fi
      if [ $stopServer -eq 1 ]; then
        if [ -f "$i/bin/stopServer.sh" ]; then
          echo "Stop Server $i - $D"
          $i/bin/stopServer.sh $D $options 
        fi
      fi
    fi
  done
  popd > /dev/null 2>&1
done

