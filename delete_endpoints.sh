#!/usr/bin/env bash

source setuprc
source admin_credential

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}

#
# Nova service
#
NOVA_SERVICE=$(get_id keystone service-get nova)
NOVA_ENDPOINT=$(keystone endpoint-list|grep $NOVA_SERVICE| awk '{print $2}')
keystone endpoint-delete $NOVA_ENDPOINT

#
# Volume service
#
VOLUME_SERVICE=$(get_id keystone service-get volume)
VOLUME_ENDPOINT=$(keystone endpoint-list|grep $VOLUME_SERVICE| awk '{print $2}')
keystone endpoint-delete $VOLUME_ENDPOINT

#
# Image service
#
GLANCE_SERVICE=$(get_id keystone service-create glance)
GLANCE_ENDPOINT=$(keystone endpoint-list|grep $GLANCE_SERVICE| awk '{print $2}')
keystone endpoint-delete $GLANCE_ENDPOINT

#
# EC2 service
#
EC2_SERVICE=$(get_id keystone service-create ec2)
EC2_ENDPOINT=$(keystone endpoint-list|grep $EC2_SERVICE| awk '{print $2}')
keystone endpoint-delete $EC2_ENDPOINT


#
# Swift service
#
SWIFT_SERVICE=$(get_id keystone service-create swift)
SWIFT_ENDPOINT=$(keystone endpoint-list|grep $SWIFT_SERVICE| awk '{print $2}')
keystone endpoint-delete $SWIFT_ENDPOINT
