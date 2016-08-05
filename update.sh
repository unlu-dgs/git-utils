#!/bin/bash
# ------------------------------------------------------------------
# [Author] Tomas Delvechio
#          Ejecutar actualizacion de git via container con git-crypt
# ------------------------------------------------------------------

SUBJECT=update-git-crypt
VERSION=0.1.0
USAGE="Usage: update.sh [-h] [-v] pull <host_volume> <guest_volume> <container_name>"

# --- Option processing --------------------------------------------
while getopts ":vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "h")
        echo $USAGE
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

cmd=$1
volume_origin=$2
volume_guest=$3
container_name=$4
command="command_$1"

# -----------------------------------------------------------------
LOCK_FILE=/tmp/${SUBJECT}.lock

if [ -f "$LOCK_FILE" ]; then
echo "Script is already running"
exit
fi

# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

# -----------------------------------------------------------------
function command_test {
    echo "test"
}

function command_ping {
    echo "ping $param"
}

function setting_proxy {
    x=""
    if [ -z ${http_proxy+x} ]; then export $http_proxy=""; fi
    if [ -z ${https_proxy+x} ]; then export $https_proxy=""; fi
}

# Actualiza el repositorio utilizando el container con git-crypt
function command_pull {
    #docker run --volume "/home/tomas/Aplicaciones/gitlab":"/gitlab" -w /gitlab git-crypt git pull
    docker run --volume $2:$3 -w $3 -e "http_proxy="${http_proxy} -e "https_proxy="${https_proxy} $4 git pull
}

# Testing env vars
function command_export {
    docker run -e "http_proxy="${http_proxy} -e "https_proxy="${https_proxy} git-crypt /bin/bash -c export
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
if [ -n "$(type -t ${command})" ] && [ "$(type -t ${command})" = function ]; then
   ${command}
else
   echo "'${cmd}' is NOT a command";
fi

