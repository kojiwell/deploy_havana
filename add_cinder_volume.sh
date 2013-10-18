#!/bin/bash -ex
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# build_all_in_one.sh - builds a all-in-one OpenStack Havana on Ubuntu 12.04 LTS.
#

source setuprc
source volumerc

grep ^$CINDER_VOLUME
if [[ if [[ $? -eq 0 ]]; then
    echo "$CINDER_VOLUME shows in /etc/fstab"
    exit 1
fi

df -ha | grep ^$CINDER_VOLUME
if [[ if [[ $? -eq 0 ]]; then
    echo "$CINDER_VOLUME is in used."
    exit 1
fi

pvcreate $CINDER_VOLUME
vgcreate cinder-volumes $CINDER_VOLUME

##############################################################################
## Install necessary packages
##############################################################################

aptitude update
apt-get install ubuntu-cloud-keyring
echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main >> /etc/apt/sources.list

aptitude update
aptitude -y dist-upgrade
aptitude -y install \
    ntp \
    python-mysqldb \
    python-memcache \
    python-keystoneclient \
    python-cinderclient \
    cinder-volume

##############################################################################
## Disable IPv6
##############################################################################

echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p


for i in /etc/nova/nova.conf \
         /etc/nova/api-paste.ini \
	 /etc/glance/glance-api.conf \
	 /etc/glance/glance-registry.conf \
	 /etc/keystone/keystone.conf \
         /etc/cinder/cinder.conf \
         /etc/cinder/api-paste.ini
do
	test -f $i.orig || cp $i $i.orig
done

CONF=/etc/cinder/cinder.conf
test -f $CONF.orig || cp $CONF $CONF.orig
cat << EOF >> $CONF
# LOGGING
log_file=cinder.log
log_dir=/var/log/cinder

# OSAPI
osapi_volume_extension = cinder.api.openstack.volume.contrib.standard_extensions
osapi_max_limit = 2000

# RABBIT
rabbit_host=$CONTROLLER_INTERNAL_ADDRESS
rabbit_virtual_host=/nova
rabbit_userid=nova
rabbit_password=$RABBIT_PASS

# MYSQL
sql_connection = mysql://openstack:$MYSQL_PASS@$CONTROLLER_INTERNAL_ADDRESS/cinder
EOF

CONF=/etc/cinder/api-paste.ini
test -f $CONF.orig || cp $CONF $CONF.orig
sed -e "s/^service_host *=.*/service_host = $CONTROLLER_PUBLIC_ADDRESS/" \
    -e "s/^auth_host *=.*/auth_host = $CONTROLLER_ADMIN_ADDRESS/" \
    -e 's/%SERVICE_TENANT_NAME%/service/' \
    -e 's/%SERVICE_USER%/cinder/' \
    -e "s/%SERVICE_PASSWORD%/$ADMIN_PASSWORD/" \
    $CONF.orig > $CONF

chown -R cinder /etc/cinder

start cinder-volume || restart cinder-volume
status cinder-volume
