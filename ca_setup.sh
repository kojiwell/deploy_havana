source setuprc

##############################################################################
# Enable SSL on Horizon
##############################################################################
a2enmod ssl
a2ensite default-ssl
/etc/init.d/apache2 restart


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
        --publicurl "https://$CONTROLLER_PUBLIC_ADDRESS:\$(public_port)s/v2.0" \
        --adminurl "https://$CONTROLLER_ADMIN_ADDRESS:\$(admin_port)s/v2.0" \
        --internalurl "https://$CONTROLLER_INTERNAL_ADDRESS:\$(public_port)s/v2.0"

##############################################################################
# Recreate Keystone Service and Endpoint
##############################################################################
CONF=/etc/keystone/keystone.conf
test -f $CONF.nonssl || cp $CONF $CONF.nonssl
sed -e 's/\[ssl\]/\[ssl\]\
enable = True\
certfile = \/etc\/keystone\/ssl\/certs\/signing_cert.pem\
keyfile = \/etc\/keystone\/ssl\/private\/signing_key.pem\
ca_certs = \/etc\/keystone\/ssl\/certs\/ca.pem\
ca_key = \/etc\/keystone\/ssl\/certs\/cakey.pem\
key_size = 1024\
valid_days = 3650\
ca_password = None\
cert_required = False\
cert_subject = \/C=US\/ST=Unset\/L=Unset\/O=Unset\/CN=localhost/' \
    $CONF.nonssl > $CONF

CONF=admin_credential
test -f $CONF.nonssl || cp $CONF $CONF.nonssl
sed -e 's/OS_AUTH_URL=http/OS_AUTH_URL=https/' $CONF.nonssl > $CONF
echo export OS_CACERT=/etc/keystone/ssl/certs/ca.pem >> $CONF

restart keystone || start keystone
status keystone
keystone endpoint-list
