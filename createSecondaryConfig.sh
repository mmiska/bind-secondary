#!/bin/bash

set -e

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


FORWARDER_STRING=


if [ -z "$SECONDARY_DOMAINS" ]
then
	echo "Keine Secondary-Domains angegeben!"
	exit 1
fi

if [ -z "$PRIMARY_SERVER" ]
then
	echo "kein Primary-Server angegeben!"
	exit 1
else
	if valid_ip $PRIMARY_SERVER
	then
		echo "Using $PRIMARY_SERVER as Primary Server"
	else
		echo "$PRIMARY_SERVER ist keine reguläre IP!"
		exit 1
	fi
fi



for DOMAIN in $(echo $SECONDARY_DOMAINS | sed 's/,/\n/g')
do
	echo "Creating Secondary Configuration for $DOMAIN ..."
	cat > /tmp/$DOMAIN.zoneconf << EOF
zone "$DOMAIN" IN {
	type slave;
	file "/etc/bind/zones/$DOMAIN.zone";
	masters { $PRIMARY_SERVER; };
};
EOF
done


for FORWARDER_ENTRY in $(echo $FORWARDER | sed 's/,/\n/g')
do
	FORWARDER_STRING=$(echo "$FORWARDER_STRING\t\t$FORWARDER_ENTRY;\n")
done
sed -i.bak "s|FORWARDER_VARIABLE|$FORWARDER_STRING|g" /etc/bind/named.conf.options


if [ -z "$RECURSION" ]
then
	RECURSION=none
fi	

for RECURSION_ENTRY in $(echo $RECURSION | sed 's/,/\n/g')
do
	RECURSION_STRING=$(echo "$RECURSION_STRING\t\t$RECURSION_ENTRY;\n")
done
sed -i.bak "s|RECURSION_VARIABLE|$RECURSION_STRING|g" /etc/bind/named.conf.options


if [ -z "$QUERY" ]
then
	QUERY="10/8,172.16/12,192.168/16"
fi
for QUERY_ENTRY in $(echo $QUERY | sed 's/,/\n/g')
do
	QUERY_STRING=$(echo "$QUERY_STRING\t\t$QUERY_ENTRY;\n")
done
sed -i.bak "s|QUERY_VARIABLE|$QUERY_STRING|g" /etc/bind/named.conf.options



cat /tmp/*.zoneconf >/tmp/named.conf.zones
mv named.conf.zones /etc/bind/named.conf.default-zones

named -u bind -c /etc/bind/named.conf -g
