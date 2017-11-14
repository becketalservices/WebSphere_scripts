#!/bin/bash
version=201711141055
BASEDIR=$(dirname "$0")

if [ "$EUID" == "0" ]; then
  echo "ERROR: Script must not be executed as root."
  exit 1
fi

echo "starting WebSphre infrastructure"
WAS_INSTALL_ROOT=/opt/IBM/WebSphere/AppServer
error=0


echo "Stopping Servers..."
$BASEDIR/stopAllServer.sh Sync

echo "Stopping Node Agents ..."
$BASEDIR/stopAllNodes.sh Sync


echo "Checking for dmgr"
dmgr=`grep "<profile .*profileTemplates/management" ${WAS_INSTALL_ROOT}/properties/profileRegistry.xml | sed "s/.*path=\"\([a-zA-Z0-9\/]*\)\".*/\1/"`

echo "Dmgr path: $dmgr"
if [ "$dmgr" ]; then
  if [ -d "$dmgr/servers/dmgr" ]; then
    stopNode=0
    if [ -f "$dmgr/logs/dmgr/dmgr.pid" ]; then
      PID=$(cat $dmgr/logs/dmgr/dmgr.pid)
      if [ "$PID" ]; then
        erg=$(ps -p $PID)
        if [ $? -eq 0 ]; then
          echo "Process with PID is running. Need to stop."
          stopNode=1
        fi
      fi
    fi
    if [ $stopNode -eq 1 ]; then
      if [ -f "$dmgr/bin/stopManager.sh" ]; then
        $dmgr/bin/stopManager.sh
        error=$?
        echo "Done stopping dmgr with code $error"
      fi
    fi
  else
    echo "Profile has no dmgr."
  fi

else
  echo "No Dmgr on this system. Nothing to stop."
fi
