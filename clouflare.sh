#!/usr/bin/env bash

#create zone
echo "creating zone: cloudflare"
firewall-cmd --permanent --new-zone=cloudflare
firewall-cmd --permanent --change-zone=ens3 --zone=cloudflare
echo "assigned interface ens3 to zone cloudflare"

# remove all public rules
IFS=$'\n'
for i in $(sudo firewall-cmd --list-rich-rules --zone=cloudflare); do
        echo "removing '$i'"
        sudo firewall-cmd --permanent --zone=cloudflare --remove-rich-rule "$i"
done

echo "reloading..."
sudo firewall-cmd --reload
#exit 1

# add new rules
echo "adding IPv4 HTTP port 80 -> 8080; 443 -> 8443"
for i in $(curl "https://www.cloudflare.com/ips-v4"); do
        echo "adding '$i'"
         firewall-cmd --permanent --zone=cloudflare --add-rich-rule='rule family="ipv4" source address="'$i'" forward-port port="80" protocol=tcp to-port="8080"'
  	 firewall-cmd --permanent --zone=cloudflare --add-rich-rule='rule family="ipv4" source address="'$i'" forward-port port="443" protocol="tcp" to-port="8443"'    
done

# SSH
firewall-cmd --add-service=ssh --permanent --zone=cloudflare
echo "reloading..."
sudo firewall-cmd --reload
