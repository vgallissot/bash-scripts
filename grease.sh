#!/bin/bash
# Tell me more, Tell me more ....
#set -x

######################################################
# Couleurs
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0;0m'  # Text Reset

######################################################
# Pour faire une sortie structurée colorée
function liste() {
    eval couleur='$'$2
    IFS=$'!'
    echo $3 | while read data
    do
        printf "%-15s=$couleur %-50s$txtrst\n" "$1" "$data"
    done
}
#~ liste "nom colonne 1" "couleur ci-dessus" "les datas en ligne"


# Récupération d'infos
ADDRIP=$(ip a|grep "global"|awk '{print $2}'|sed "s%\(.*\)\(\/.*\)%\1%g")
SERVICES=$(netstat -laputen|grep LISTEN|egrep -v "(sendmail|sshd|xinetd|rpcbind|cupsd|snmpd)"|tr '/' ' '|awk '{printf "\033[1;31m%-5s\033[0;0m \033[0;33m%-16s\033[0;0m \033[1;36m%s\033[0;0m\n",$1,$4,$10}')
CPUCOUNT=$(grep processor /proc/cpuinfo|wc -l)
RAMCOUNT="$(($(grep MemTotal /proc/meminfo|awk '{print $2}')/1024)) Mo"
DISKS=$(fdisk -l 2>/dev/null|egrep "Disk /dev/sd|Disque /dev/sd"|tr ',' ' '|awk '{printf "%s %s \n",$2,$3}')
PARTITIONSIZE=$(\df -h|\grep "^/"|\grep -v "^/proc"|\awk '{printf "\033[0;34m%-7s\033[0;0m %-5s libres (\033[1;33m%s\033[0;0m)\n",$6,$4,$5}')
VGFREESIZE=$(vgdisplay --columns | grep -v "Attr"|awk '{printf "%-5s %s libres\n",$1,$7}')


# Infos propres aux OS
grep -qi debian /etc/issue && OS=debian
grep -qi hat /etc/issue && OS=redhat
case $OS in
	debian)
		OSVER="Debian $(cat /etc/debian_version)"
	;;
	redhat)
		OSVER=$(cat /etc/redhat-release)
	;;
	*)
		OSVER=$(cat /etc/issue|head -1)
	;;
esac



liste "OS" bldblu "$OSVER"
liste "CPU" bldgrn $CPUCOUNT
liste "RAM" bldylw $RAMCOUNT
liste "Disque" txtcyn $DISKS
liste "Partition" txtrst $PARTITIONSIZE
liste "VG" txtgrn $VGFREESIZE
liste "IP" bldpur $ADDRIP
liste "Service" txtrst $SERVICES


exit 0
