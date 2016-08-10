#!/bin/bash
# ------------------------------------------------------------------
# [Author] Tomas Delvechio
#          Ejecutar actualizacion de git via container con git-crypt
# ------------------------------------------------------------------

SUBJECT=update-git-crypt
VERSION=0.5.0
USAGE="Usage: update.sh [-h] [-v] pull <host_volume> <guest_volume> <container_name>"


# Print all commands
function list_options {
    echo "Comandos disponibles"
    echo "  pull: Ejecuta git pull dentro del container usando git-crypt"
    echo "  export: Muestra variables de entorno del container"
    echo "  config: Muestra la configuracion"
    echo ""
}

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
        list_options
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

typeset -A config # init array
config=( # set default values in config array
    [volume_dir_host]="/var/gitlab"
    [volume_dir_guest]="/gitlab"
    [container_name]="git-crypt"
)

command="command_${cmd}"

# -----------------------------------------------------------------
LOCK_FILE=/tmp/${SUBJECT}.lock

if [ -f "$LOCK_FILE" ]; then
    echo "Script is already running"
    exit
fi

# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

# Actualiza el repositorio utilizando el container con git-crypt
function command_pull {
    #docker run --volume "/home/tomas/Aplicaciones/gitlab":"/gitlab" -w /gitlab git-crypt git pull
    setting_proxy
    load_config
    docker run --volume ${config[volume_dir_host]}:${config[volume_dir_guest]} -w ${config[volume_dir_guest]} -e "http_proxy="${http_proxy} -e "https_proxy="${https_proxy} ${config[container_name]} git pull
}

# Testing env vars
function command_export {
    docker run -e "http_proxy="${http_proxy} -e "https_proxy="${https_proxy} git-crypt /bin/bash -c export
}

function command_config {
    if [ ! -f conf ]; then
        echo "[INFO]: No existe archivo '`pwd`/conf'. Se utiliza configuracion por defecto. Si desea parametrizar el script, genere un archivo de configuracion a partir de conf.sample, de nombre 'conf'"
    else
        echo "Archivo 'conf' encontrado. Variables seteadas:"
        while read line
        do
            if echo $line | grep -F = &>/dev/null
            then
                param=$(echo "$line" | cut -d '=' -f 1)
                value=$(echo "$line" | cut -d '=' -f 2-)
                echo "$param=$value"
            fi
        done < conf
    fi
}

function setting_proxy {
    x=""
    if [ -z ${http_proxy+x} ]; then export $http_proxy=""; fi
    if [ -z ${https_proxy+x} ]; then export $https_proxy=""; fi
}

# Load file config if exist
function load_config {
    if [ ! -f conf ]; then
        echo "[INFO]: No existe archivo `pwd`/conf. Se utiliza configuracion por defecto. Si desea parametrizar el script, genere un archivo de configuracion a partir de conf.sample"
    else
        while read line
        do
            if echo $line | grep -F = &>/dev/null
            then
                varname=$(echo "$line" | cut -d '=' -f 1)
                config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
            fi
        done < conf
    fi
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
if [ -n "$(type -t ${command})" ] && [ "$(type -t ${command})" = function ]; then
   ${command}
else
   echo $USAGE
   echo "./update.sh -h para ver los comandos disponibles"
fi

