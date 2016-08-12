# Git Utils

A docker image with utils for git. This container will be useful to use git plugins on servers where thats plugins don't be availables.

## Plugines

 * [git-crypt](https://www.agwa.name/projects/git-crypt/)

## Git Crypt

Git Crypt isn't available on debian jessie. This container let you to use the command using the container.

# Configuración inicial

 * Clonar el repositorio

```
git clone https://github.com/unlu-dgs/git-utils.git
```

 * Descargar la imagen

```
git pull unludgs/git-utils:latest
```

 * Crear archivo conf y editar los parametros

```
$ cd git-utils
$ cp conf.sample conf
$ vim conf
```

[Ver parametros disponibles]()

# Forma de uso

Se asume el repositorio ya clonado.

## Desencriptar los archivos de forma local

Desde la carpeta de git-utils

```
./update.sh unlock
```

El comando no genera salida si tiene exito.

## Actualizar el repositorio desde el contenedor usando git crypt

```
./update.sh pull
```

## Loguearse al contenedor con el entorno configurado

```
./update.sh bash
```

# Parametros

El script acepta parametrizaciones via un archivo de nombre conf en la raiz. A continuación se detallan los parametros disponibles.

 * `volume_dir_host`: Path en el host al repositorio git sobre el cual se desea ejecutar los comandos. Default value: `/var/gitlab`.
 * `volume_dir_guest`: Path donde se montara `volume_dir_host` dentro del container. Default value: `/gitlab`.
 * `container_name`: El nombre de la imagen del container.
 * `simmetric_key`: Path de la clave simetrica dentro del container. Generalmente se ubica en `volume_dir_guest`.

# Troubleshootings

Se comprobó que el uso de este contenedor genera que desde afuera del mismo no se
podra utilizar en el repositorio destino el comando git. Esto se debe a que git-crypt
genera algunos hooks que al no estar instalados en el host, no pueden ser ejecutados.

Se recomienda que para tareas rutinarias, se cree un helper del comando git en
`update.sh`. Para tareas eventuales, es recomendable loguearse a este container
usando una consola interactiva:

```
./update.sh bash
```

# Builds automaticas

[Docker Hub](https://hub.docker.com/r/unludgs/git-utils/)
