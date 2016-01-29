#!/bin/bash
# Will renew certs for installed hostnames in /etc/nginx/sites-enabled/

LOG=/var/log/letsencrypt/letsenrypt-updater.log

# Gen letsencrypt cert
# Args = domains seperated with ' -d '
function GETCERTS() {
    retry=5
    while [ $retry -gt 0 ]
    do
        /opt/letsencrypt/letsencrypt-auto certonly --keep-until-expiring --agree-tos --email vgallissot@peaks.fr -d "$@" >> $LOG
        RetVal="$?"
        if [ "$RetVal" -gt 0 ]
        then
            retry=$((retry-1))
        else
            retry=0
        fi
        echo "retry=$retry"
    done
    return $RetVal
}


service nginx stop
for vhost in $(ls /etc/nginx/sites-enabled/*)
do
    echo "Generating certs based on $vhost"
    GETCERTS $(grep server_name $vhost| sed 's,.*server_name\ \(.*\)\;,\1,g'|tr '\n' ' '|sed 's,\ ,\ -d ,g'|sed 's, -d $,\n,') && echo "Successfully generated certs for $vhost" || echo "Failed to generate certs for $vhost"
done
service nginx start


exit $?
