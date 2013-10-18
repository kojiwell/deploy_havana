.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

setuprc example for 1NIC
========================

Diagram::

    Public Network
   +-------------------------------
       |                          
       | eth0 [123.123.123.123/24]
     +------------------+          
     | host01           |          
     | ================ |          
     | Keystone         |          
     | Glance           |          
     | Horizon          |          
     | Nova API         |          
     | Nova Scheduler   |          
     | Nova Compute     |          
     | Nova Network     |          
     | Nova Conductor   |
     | Cinder API       |
     | Cinder Scheduler |     
     +------------------+          

``setuprc``::

   # setuprc - configuration file for deploying OpenStack

   export PASSWORD='1234abcdEFGH'
   export ADMIN_PASSWORD=$PASSWORD
   export SERVICE_PASSWORD=$PASSWORD
   export ENABLE_ENDPOINTS=1
   MYSQL_ADMIN_PASS=$PASSWORD
   MYSQL_PASS=$PASSWORD
   RABBIT_PASS=$PASSWORD
   export CONTROLLER_PUBLIC_ADDRESS='123.123.123.123'
   export CONTROLLER_ADMIN_ADDRESS=$CONTROLLER_PUBLIC_ADDRESS
   export CONTROLLER_INTERNAL_ADDRESS=$CONTROLLER_ADMIN_ADDRESS
   FIXED_RANGE="192.168.201.0/24"
   MYSQL_ACCESS="123.123.123.%"
   PUBLIC_INTERFACE="br101"
   FLAT_INTERFACE="eth0"
   #CINDER_VOLUME=/dev/sdb1


