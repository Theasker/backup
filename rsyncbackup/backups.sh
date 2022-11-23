#!/bin/bash
#==============================================================================
# title: ScriptBackup.sh
# description:  Automatic Backup Script in Bash Shell (rsync + rclone)
# author: Mauricio Segura Ariño
# date: 20220920
# usage: bash ScriptBackup.sh
# notes: Configure the initVars function and init de variables
# bash_version: 5.1.16(1)-release (x86_64-pc-linux-gnu)
# help links:
# https://www.proxadmin.es/blog/rsync-10-ejemplos-practicos-de-comandos-rsync/#:~:text=Las%20opciones%20m%C3%A1s%20comunes%20usadas,de%20los%20datos%20de%20origen).
# 
#==============================================================================

# Opciones más útiles
# Las opciones más comunes o útiles de rsync, ya sea de uso local o remoto son las siguientes:

# -a	--archive	Modo archive, es igual a indicar las opciones r,l,p,t,g,o y D
# -r	--recursive	Recursivo, copia recursivamente los directorios.
# -l	--links	Cuando encuentra symlinks (enlaces simbólicos), estos son recreados en el destino.
# -p	--perms	Opción que causa en el destino establecer los permisos igual que en el origen.
# -t	--times	Transfiere los tiempos de los archivos (atime, ctime, mtime) al destino
# -g	--group	Establece en el destino que el grupo del archivo copiado sea igual que el origen.
# -o	--owner	Establece en el destino que el propietario del archivo copiado sea igual que el origen.
# -D	 	Esto es igual que indicar las opciones --devices y --specials
# -b	--backup	make backups (see --suffix & --backup-dir)
# 	--backup-dir=DIR         make backups into hierarchy based in DIR
#	--suffix=SUFFIX          backup suffix (default ~ w/o --backup-dir)
# 	--exclude PATTERN	Excluye archivos que igualan el patrón o pattern indicado.
# 	--include PATTERN	Incluye archivos que igualan el patrón o pattern indicado.
# 	--devices	Transfiere archivos de dispositivos de bloque y caracter al destino donde son recreados. Esto solo puede suceder si en el destino se tienen permisos de root.
# 	--specials	Transfiere archivos especiales como fifos y named sockets.
# 	--version	Indica el número de versión de rsync
# -v	--verbose	Incrementa la cantidad de información que se informa durante la transferencia o copia de archivos. Es la opción contraria a --quiet
# -q	--quiet	Decremente la cantidad de información que se informa durante la transferecnia o copia de archivos. Generalmente se utiliza cuando rsync se utiliza en una tarea cron. Es la opción contraria a --verbose
# -I	--ignore-times	Una de las grandes virtudes de rsync es que al momento de copiar o transferir archivos, si estos son iguales en el destino en términos de tiempos y tamaño ya no lo copia, no hay cambios. Esta opción permite que esto sea ignorado y todos los archivos serán copiados/actualizados en el destino. (ver --size-only también)
# 	--size-only	Normalmente solo se transfieren archivos con los tiempos cambiados o el tamaño cambiado. Con esta opción se ignoran los tiempos de los archivos y se transfiere cualquiera con un tamaño distinto en el destino.
# -n	--dry-run	Crea una prueba de test de lo que realmente ocurrirá sin esta opción, sin realizar ningún cambio. Es decir, la salida mostrada será muy similar a lo que realmente pasará si no se incluye --dry-run. Generalmente se usa junto con la opción --verbose y la opción --itemize-changes
# -i	--itemize-changes	Reporta una lista de los cambios realizados en cada archivo, incluidos cambios en sus atributos. Esto es equivalente a utilizar -vv en versiones obsolteas de rsync.
# 	--remove-source-files	Remueve los archivos en el origen (no directorios) si en el destino estos fueron exitosamente duplicados o copiados.
# 	--timeout=TIEMPO	Especifica un timeout en segundos, si no datos son transferidos en tiempo indicado rsync terminará. El default es 0 segundos que quiere decir sin timeout.
# 	--log-file=ARCHIVO	Bitacoriza lo que se ha realizado en el ARCHIVO indicado.
# 	--stats	Imprime un conjunto informativo de datos estadísticos sobre la transferencia realizada.
# 	--progress	Muestra el avance o progreso de los archivos que están siendo transferidos.
# 	--bwlimit=KBPS	Permite establecer un límite de transferencia en kilobytes por segundo. Esta opción su default es 0, lo que indica no límite en el uso del ancho de banda en la transferencia.
# 	--max-size=TAMAÑO	No transfiere cualquier archivo más grande que el TAMAÑO indicado.
# 	--min-size=TAMAÑO	No transfiere cualquier archivo más pequeño que el TAMAÑO indicado.
# -z	--compress	Comprimir datos durante la transferencia.
#==============================================================================
# rsync -arvz -e 'ssh -p {{22 u otro puerto SSH}}' –progress /backup-local ayudalinux@10.0.1.5:/backup-remoto
# 


Leer más en: https://ayudalinux.com/backup-incremental-rsync-ssh/

DIRSOURCE=$PWD/source
DIRTARGET=$PWD/target

rsync -avh $DIRSOURCE $DIRTARGET
rsync -avhb
# -a 
#
