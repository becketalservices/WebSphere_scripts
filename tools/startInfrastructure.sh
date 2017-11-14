#!/bin/bash
version=201711141000
BASEDIR=$(dirname "$0")

if [ "$EUID" == "0" ]; then
  echo "ERROR: Script must not be executed as root."
  exit 1
fi

echo "starting WebSphre infrastructure"
WAS_INSTALL_ROOT=/opt/IBM/WebSphere/AppServer
error=0

echo "Checking for dmgr"
dmgr=`grep "<profile .*profileTemplates/management" ${WAS_INSTALL_ROOT}/properties/profileRegistry.xml | sed "s/.*path=\"\([a-zA-Z0-9\/]*\)\".*/\1/"`

echo "Dmgr path: $dmgr"
if [ "$dmgr" ]; then
  if [ -d "$dmgr/servers/dmgr" ]; then
    startNode=1
    if [ -f "$dmgr/logs/dmgr/dmgr.pid" ]; then
      PID=$(cat $dmgr/logs/dmgr/dmgr.pid)
      if [ "$PID" ]; then
        erg=$(ps -p $PID)
        if [ $? -eq 0 ]; then
          echo "Process with PID is running. Do not start."
          startNode=0
        fi
      fi
    fi
    if [ $startNode -eq 1 ]; then
      if [ -f "$dmgr/bin/startManager.sh" ]; then
        $dmgr/bin/startManager.sh
        error=$?
        echo "Done starting dmgr with code $error"
      fi
    fi
  else
    echo "Profile has no dmgr."
  fi

else
  echo "No Dmgr on this system. Nothing to start."
fi
if [ $error == 0 ]; then
  echo "Starting Node Agents ..."
  $BASEDIR/startAllNodes.sh Sync
  error=$?
  echo "Done starting node agents with code $error"

  if [ $error == 0 ]; then
    echo "Starting Servers..."
    $BASEDIR/startAllServer.sh
  else
    echo "ERROR: Node start failed. Stopped starting infrastructure."
  fi
else
  echo "ERROR: Dmgr start failed. Stopped starting infrastructure."
fi
exit $error
