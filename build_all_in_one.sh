#!/bin/bash -ex
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# build_all_in_one.sh - builds a all-in-one OpenStack Havana on Ubuntu 12.04 LTS.
#

source setuprc

HTTP_PROXY=$http_proxy
unset http_proxy

##############################################################################
## Install necessary packages
##############################################################################

aptitude update
apt-get install ubuntu-cloud-keyring
echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main \
     > /etc/apt/sources.list.d/havana.list

export DEBIAN_FRONTEND=noninteractive

aptitude update
aptitude -y dist-upgrade
aptitude -y install \
    ntp \
    python-mysqldb \
    python-memcache \
    rabbitmq-server \
    mysql-server \
    memcached \
    open-iscsi-utils \
    bridge-utils \
    keystone \
    glance \
    cinder-api \
    cinder-scheduler \
    nova-api \
    nova-cert \
    nova-compute \
    nova-compute-kvm \
    nova-objectstore \
    nova-network \
    nova-scheduler \
    nova-conductor \
    nova-doc \
    nova-console \
    nova-consoleauth \
    nova-novncproxy \
    novnc \
    openstack-dashboard

##############################################################################
## Disable IPv6
##############################################################################

echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

##############################################################################
## Disable virbr0
##############################################################################

virsh net-autostart default
virsh net-destroy default

##############################################################################
## Disable Ubuntu Theme
##############################################################################

apt-get remove --purge openstack-dashboard-ubuntu-theme

##############################################################################
## Configure memcached
##############################################################################
sed -i "s/127.0.0.1/$CONTROLLER_ADMIN_ADDRESS/" /etc/memcached.conf
service memcached restart

##############################################################################
## Make a script to start/stop all services
##############################################################################

cat << EOF > openstack.sh
#!/bin/bash

NOVA="conductor compute network scheduler cert consoleauth novncproxy api"
GLANCE="registry api"
CINDER="scheduler api"

case "\$1" in
start|restart|status)
	/sbin/\$1 keystone
	for i in \$GLANCE; do
		/sbin/\$1 glance-\$i
	done
	for i in \$NOVA; do
		/sbin/\$1 nova-\$i
	done
	for i in \$CINDER; do
		/sbin/\$1 cinder-\$i
	done
	;;
stop)
	for i in \$NOVA; do
		/sbin/stop nova-\$i
	done
	for i in \$GLANCE; do
		/sbin/stop glance-\$i
	done
	for i in \$CINDER; do
		/sbin/stop cinder-\$i
	done
	/sbin/stop keystone
	;;
esac
exit 0
EOF
chmod u+x openstack.sh

##############################################################################
## Stop all services.
##############################################################################

./openstack.sh stop

##############################################################################
## Modify configuration files of Nova, Glance and Keystone
##############################################################################

CONF=/etc/keystone/keystone.conf
test -f $CONF.orig || cp $CONF $CONF.orig
sed -e "s/^#*connection *=.*/connection = mysql:\/\/openstack:$MYSQL_PASS@$CONTROLLER_INTERNAL_ADDRESS\/keystone/" \
    -e "s/^#* *admin_token *=.*/admin_token = $ADMIN_PASSWORD/" \
    $CONF.orig > $CONF

CONF=/etc/nova/nova.conf
test -f $CONF.orig || cp $CONF $CONF.orig
cat << EOF > $CONF
[DEFAULT]
verbose=True
multi_host=True
allow_admin_api=True
api_paste_config=/etc/nova/api-paste.ini
instances_path=/var/lib/nova/instances
compute_driver=libvirt.LibvirtDriver
rootwrap_config=/etc/nova/rootwrap.conf
send_arp_for_ha=True
ec2_private_dns_show_ip=True
start_guests_on_host_boot=True
resume_guests_state_on_host_boot=True

# LOGGING
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova

# NETWORK
libvirt_use_virtio_for_bridges = True
network_manager=nova.network.manager.FlatDHCPManager
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
public_interface=$PUBLIC_INTERFACE
flat_interface=$FLAT_INTERFACE
flat_network_bridge=br101
fixed_range=$FIXED_RANGE
force_dhcp_release = True
flat_injected=false
use_ipv6=false
#auto_assign_floating_ip = True

# VNC
novncproxy_base_url=http://\$my_ip:6080/vnc_auto.html
vncserver_proxyclient_address=\$my_ip
vncserver_listen=0.0.0.0
keymap=en-us

#scheduler
scheduler_driver=nova.scheduler.filter_scheduler.FilterScheduler

# OBJECT
s3_host=$CONTROLLER_PUBLIC_ADDRESS
use_cow_images=yes

# GLANCE
image_service=nova.image.glance.GlanceImageService
glance_api_servers=$CONTROLLER_PUBLIC_ADDRESS:9292

# RABBIT
rabbit_host=$CONTROLLER_INTERNAL_ADDRESS
rabbit_virtual_host=/nova
rabbit_userid=nova
rabbit_password=$RABBIT_PASS

# DATABASE
sql_connection=mysql://openstack:$MYSQL_PASS@$CONTROLLER_INTERNAL_ADDRESS/nova

#use cinder
enabled_apis=ec2,osapi_compute,metadata
volume_api_class=nova.volume.cinder.API

#keystone
auth_strategy=keystone
keystone_ec2_url=http://$CONTROLLER_PUBLIC_ADDRESS:5000/v2.0/ec2tokens
EOF

CONF=/etc/nova/api-paste.ini
test -f $CONF.orig || cp $CONF $CONF.orig
sed -e "s/^auth_host *=.*/auth_host = $CONTROLLER_ADMIN_ADDRESS/" \
    -e 's/%SERVICE_TENANT_NAME%/service/' \
    -e 's/%SERVICE_USER%/nova/' \
    -e "s/%SERVICE_PASSWORD%/$ADMIN_PASSWORD/" \
    $CONF.orig > $CONF

CONF=/etc/glance/glance-api.conf
test -f $CONF.orig || cp $CONF $CONF.orig
sed -e "s/^auth_host *=.*/auth_host = $CONTROLLER_ADMIN_ADDRESS/" \
    -e 's/%SERVICE_TENANT_NAME%/service/' \
    -e 's/%SERVICE_USER%/glance/' \
    -e "s/%SERVICE_PASSWORD%/$ADMIN_PASSWORD/" \
    -e "s#^sql_connection *=.*#sql_connection = mysql://openstack:$MYSQL_PASS@$CONTROLLER_INTERNAL_ADDRESS/glance#" \
    -e 's[^#* *config_file *=.*[config_file = /etc/glance/glance-api-paste.ini[' \
    -e 's/^#*flavor *=.*/flavor = keystone/' \
    -e 's/^notifier_strategy *=.*/notifier_strategy = rabbit/' \
    -e "s/^rabbit_host *=.*/rabbit_host = $CONTROLLER_INTERNAL_ADDRESS/" \
    -e 's/^rabbit_userid *=.*/rabbit_userid = nova/' \
    -e "s/^rabbit_password *=.*/rabbit_password = $RABBIT_PASS/" \
    -e "s/^rabbit_virtual_host *=.*/rabbit_virtual_host = \/nova/" \
    -e "s/127.0.0.1/$CONTROLLER_PUBLIC_ADDRESS/" \
    -e "s/localhost/$CONTROLLER_PUBLIC_ADDRESS/" \
    $CONF.orig > $CONF

CONF=/etc/glance/glance-registry.conf
test -f $CONF.orig || cp $CONF $CONF.orig
sed -e "s/^auth_host *=.*/auth_host = $CONTROLLER_ADMIN_ADDRESS/" \
    -e 's/%SERVICE_TENANT_NAME%/service/' \
    -e 's/%SERVICE_USER%/glance/' \
    -e "s/%SERVICE_PASSWORD%/$ADMIN_PASSWORD/" \
    -e "s/^sql_connection *=.*/sql_connection = mysql:\/\/openstack:$MYSQL_PASS@$CONTROLLER_INTERNAL_ADDRESS\/glance/" \
    -e 's/^#* *config_file *=.*/config_file = \/etc\/glance\/glance-registry-paste.ini/' \
    -e 's/^#*flavor *=.*/flavor=keystone/' \
    -e "s/127.0.0.1/$CONTROLLER_PUBLIC_ADDRESS/" \
    -e "s/localhost/$CONTROLLER_PUBLIC_ADDRESS/" \
    $CONF.orig > $CONF

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

for i in keystone nova glance cinder
do
	chown -R $i /etc/$i
done

##############################################################################
## Configure RabbitMQ
##############################################################################

rabbitmqctl add_vhost /nova
rabbitmqctl add_user nova $RABBIT_PASS
rabbitmqctl set_permissions -p /nova nova ".*" ".*" ".*"
rabbitmqctl delete_user guest

##############################################################################
## Modify MySQL configuration
##############################################################################

mysqladmin -u root password $MYSQL_ADMIN_PASS
/sbin/stop mysql

CONF=/etc/mysql/my.cnf
test -f $CONF.orig || /bin/cp $CONF $CONF.orig
sed -e 's/^bind-address[[:space:]]*=.*/bind-address = 0.0.0.0/' \
    $CONF.orig > $CONF

start mysql
sleep 5

##############################################################################
## Create MySQL accounts and databases of Nova, Glance, Keystone and Cinder
##############################################################################

cat << EOF | /usr/bin/mysql -uroot -p$MYSQL_ADMIN_PASS
DROP DATABASE IF EXISTS keystone;
DROP DATABASE IF EXISTS glance;
DROP DATABASE IF EXISTS nova;
DROP DATABASE IF EXISTS cinder;
CREATE DATABASE keystone;
CREATE DATABASE glance;
CREATE DATABASE nova;
CREATE DATABASE cinder;
GRANT ALL ON keystone.* TO 'openstack'@'localhost'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON glance.*   TO 'openstack'@'localhost'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON nova.*     TO 'openstack'@'localhost'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON cinder.*   TO 'openstack'@'localhost'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON keystone.* TO 'openstack'@'$CONTROLLER_ADMIN_ADDRESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON glance.*   TO 'openstack'@'$CONTROLLER_ADMIN_ADDRESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON nova.*     TO 'openstack'@'$CONTROLLER_ADMIN_ADDRESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON cinder.*   TO 'openstack'@'$CONTROLLER_ADMIN_ADDRESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON keystone.* TO 'openstack'@'$MYSQL_ACCESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON glance.*   TO 'openstack'@'$MYSQL_ACCESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON nova.*     TO 'openstack'@'$MYSQL_ACCESS'   IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON cinder.*   TO 'openstack'@'$MYSQL_ACCESS'   IDENTIFIED BY '$MYSQL_PASS';
EOF

##############################################################################
## Initialize databases of Nova, Glance and Keystone
##############################################################################

#if [ -n $CINDER_VOL ]; then
#    pvcreate $CINDER_VOL
#    vgcreate cinder-volumes $CINDER_VOL
#fi

/usr/bin/keystone-manage db_sync
/usr/bin/glance-manage db_sync
/usr/bin/nova-manage db sync
/usr/bin/cinder-manage db sync

##############################################################################
## Start Keystone
##############################################################################

start keystone
sleep 5
status keystone

##############################################################################
## Create a sample data on Keystone
##############################################################################

sed -e "s#--publicurl http://localhost#--publicurl http://$CONTROLLER_PUBLIC_ADDRESS#g" \
    -e "s#--publicurl 'http://localhost#--publicurl 'http://$CONTROLLER_PUBLIC_ADDRESS#g" \
    -e "s#--adminurl http://localhost#--adminurl http://$CONTROLLER_ADMIN_ADDRESS#g" \
    -e "s#--adminurl 'http://localhost#--adminurl 'http://$CONTROLLER_ADMIN_ADDRESS#g" \
    -e "s#--internalurl http://localhost#--internalurl http://$CONTROLLER_INTERNAL_ADDRESS#g" \
    -e "s#--internalurl 'http://localhost#--internalurl 'http://$CONTROLLER_INTERNAL_ADDRESS#g" \
    /usr/share/keystone/sample_data.sh > /tmp/sample_data.sh
bash -ex /tmp/sample_data.sh

##############################################################################
## Create credentials
##############################################################################

cat << EOF > admin_credential
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASSWORD
export OS_TENANT_NAME=demo
export OS_AUTH_URL=http://$CONTROLLER_ADMIN_ADDRESS:35357/v2.0
export OS_NO_CACHE=1
EOF
chmod 600 admin_credential

cat << EOF > demo_credential
export OS_USERNAME=demo
export OS_PASSWORD=$ADMIN_PASSWORD
export OS_TENANT_NAME=demo
export OS_AUTH_URL=http://$CONTROLLER_PUBLIC_ADDRESS:5000/v2.0
export OS_NO_CACHE=1
EOF
chmod 600 demo_credential

##############################################################################
## Add Cinder on Keystone
##############################################################################

source admin_credential
keystone endpoint-delete $(keystone endpoint-list | grep 8776 | awk '{print $2}')
keystone service-delete $(keystone service-list | grep volume | awk '{print $2}')
SERVICE_PASSWORD=$ADMIN_PASSWORD
SERVICE_HOST=$CONTROLLER_PUBLIC_ADDRESS

function get_id () {
    echo `"$@" | awk '/ id / { print $4 }'`
}
ADMIN_ROLE=$(keystone role-list | grep " admin" | awk '{print $2}')
SERVICE_TENANT=$(keystone tenant-list | grep service | awk '{print $2}')

CINDER_USER=$(get_id keystone user-create \
        --name=cinder \
        --pass="$SERVICE_PASSWORD" \
        --tenant_id $SERVICE_TENANT \
        --email=cinder@example.com)
keystone user-role-add \
        --tenant_id $SERVICE_TENANT \
        --user_id $CINDER_USER \
        --role_id $ADMIN_ROLE
CINDER_SERVICE=$(get_id keystone service-create \
        --name=cinder \
        --type=volume \
        --description="Cinder Service")
keystone endpoint-create \
        --region RegionOne \
        --service_id $CINDER_SERVICE \
        --publicurl "http://$CONTROLLER_PUBLIC_ADDRESS:8776/v1/\$(tenant_id)s" \
        --adminurl "http://$CONTROLLER_ADMIN_ADDRESS:8776/v1/\$(tenant_id)s" \
        --internalurl "http://$CONTROLLER_INTERNAL_ADDRESS:8776/v1/\$(tenant_id)s"

##############################################################################
## Create a nova network
##############################################################################

nova-manage network create \
	--label private \
	--num_networks=1 \
	--fixed_range_v4=$FIXED_RANGE \
        --bridge_interface=$FLAT_INTERFACE \
	--network_size=256 \
        --multi_host=T

##############################################################################
## Start all srevices
##############################################################################

./openstack.sh start
sleep 5

##############################################################################
## Register Ubuntu-12.10 image on Glance
##############################################################################

http_proxy=$HTTP_PROXY wget \
http://uec-images.ubuntu.com/releases/precise/release/ubuntu-12.04-server-cloudimg-amd64-disk1.img

source admin_credential
glance image-create \
	--name ubuntu-12.04 \
	--disk-format qcow2 \
	--container-format bare \
	--file ubuntu-12.04-server-cloudimg-amd64-disk1.img

rm -f ubuntu-12.04-server-cloudimg-amd64-disk1.img

##############################################################################
## Add a key pair
##############################################################################

nova keypair-add key1 > key1.pem
chmod 600 key1.pem

##############################################################################
## Add ssh config
##############################################################################

echo StrictHostKeyChecking no >> ~/.ssh/config
echo UserKnownHostsFile=/dev/null >> ~/.ssh/config

##############################################################################
## Enable ssh and ping on default security Group
##############################################################################

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

##############################################################################
## Reboot
##############################################################################

reboot
