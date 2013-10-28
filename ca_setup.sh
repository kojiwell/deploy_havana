#!/bin/bash -ex
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# ca_setup.sh - enable SSL on the all_in_one node.
#

source setuprc

##############################################################################
# Recreate Keystone Service and Endpoint
##############################################################################
CONF=/etc/keystone/keystone.conf

# Extract some info from Keystone's configuration file
if [[ -r "$CONF" ]]; then
    CONFIG_SERVICE_TOKEN=$(sed 's/[[:space:]]//g' $CONF | grep ^admin_token= | cut -d'=' -f2)
    CONFIG_ADMIN_PORT=$(sed 's/[[:space:]]//g' $CONF | grep ^admin_port= | cut -d'=' -f2)
fi

export SERVICE_TOKEN=${SERVICE_TOKEN:-$CONFIG_SERVICE_TOKEN}
if [[ -z "$SERVICE_TOKEN" ]]; then
    echo "No service token found."
    echo "Set SERVICE_TOKEN manually from keystone.conf admin_token."
    exit 1
fi

export SERVICE_ENDPOINT=${SERVICE_ENDPOINT:-http://$CONTROLLER_PUBLIC_ADDRESS:${CONFIG_ADMIN_PORT:-35357}/v2.0}

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}

KEYSTONE_SERVICE=$(get_id keystone service-get keystone)
KEYSTONE_ENDPOINT=$(keystone endpoint-list | grep $KEYSTONE_SERVICE|awk '{print $2}')
keystone endpoint-delete $KEYSTONE_ENDPOINT
keystone service-delete $KEYSTONE_SERVICE
KEYSTONE_SERVICE=$(get_id \
keystone service-create --name=keystone \
                        --type=identity \
                        --description="Keystone Identity Service")
keystone endpoint-create --region RegionOne --service-id $KEYSTONE_SERVICE \
        --publicurl "https://$COMMON_NAME:\$(public_port)s/v2.0" \
        --adminurl "https://$COMMON_NAME:\$(admin_port)s/v2.0" \
        --internalurl "https://$COMMON_NAME:\$(public_port)s/v2.0"

##############################################################################
# Recreate selfsigned CA and certificates with new COMMON_NAME
##############################################################################
CONF=/etc/keystone/keystone.conf
test -f $CONF.nonssl || cp $CONF $CONF.nonssl
sed -e "s/\[ssl\]/\[ssl\]\
enable = True\
certfile = \/etc\/keystone\/ssl\/certs\/signing_cert.pem\
keyfile = \/etc\/keystone\/ssl\/private\/signing_key.pem\
ca_certs = \/etc\/keystone\/ssl\/certs\/ca.pem\
ca_key = \/etc\/keystone\/ssl\/certs\/cakey.pem\
key_size = 1024\
valid_days = 3650\
ca_password = None\
cert_required = False\
cert_subject = \/C=US\/ST=Unset\/L=Unset\/O=Unset\/CN=$COMMON_NAME/" \
$CONF.nonssl > $CONF

mv /etc/keystone/ssl /etc/keystone/ssl.orig
keystone-manage ssl_setup --keystone-user keystone --keystone-group keystone

CONF=admin_credential
test -f $CONF.nonssl || cp $CONF $CONF.nonssl
sed -e "s/OS_AUTH_URL=http/OS_AUTH_URL=https:\/\/$COMMON_NAME:35357\/v2.0/" \
    $CONF.nonssl > $CONF
echo export OS_CACERT=/etc/keystone/ssl/certs/ca.pem >> $CONF

restart keystone || start keystone
status keystone
keystone endpoint-list

##############################################################################
# Enable SSL on Horizon
##############################################################################
CONF=/etc/openstack-dashboard/local_settings.py
test -f $CONF.nonssl || cp $CONF $CONF.nonssl
sed -e "s/OPENSTACK_HOST =.*/OPENSTACK_HOST = \"$COMMON_NAME\"/" \
    -e 's/OPENSTACK_KEYSTONE_URL = \"http/OPENSTACK_KEYSTONE_URL = \"https/' \
    -e 's/# OPENSTACK_SSL_NO_VERIFY/OPENSTACK_SSL_NO_VERIFY/' \
    -e "s/# OPENSTACK_SSL_CACERT =.*/OPENSTACK_SSL_CACERT = \'\/etc\/keystone\/ssl\/certs\/ca.pem\'/" \
    $CONF.nonssl > $CONF

a2enmod ssl
a2ensite default-ssl
/etc/init.d/apache2 restart

##############################################################################
# Enable SSL on Nova, Glance and Cinder
##############################################################################
for CONF in /etc/nova/api-paste.ini \
    /etc/cinder/api-paste.ini \
    /etc/glance/glance-api.conf \
    /etc/glance/glance-registry.conf
do
    test -f $CONF.nonssl || cp $CONF $CONF.nonssl
    sed -e "s/auth_host =.*/auth_host = $COMMON_NAME/" \
        -e 's/auth_protocol =.*/auth_protocol = https/' \
        $CONF.nonssl > $CONF
done

CONF=/etc/nova/nova.conf
test -f $CONF.nonssl || cp $CONF $CONF.nonssl
sed -e "s/keystone_ec2_url=.*/keystone_ec2_url=https:\/\/$COMMON_NAME:5000\/v2.0\/ec2tokens\/" \
    $CONF.nonssl > $CONF

./openstack.sh restart

echo Done
