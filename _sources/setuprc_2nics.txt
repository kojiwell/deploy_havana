.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

setuprc example for 2NICs
=========================

Diagram::

    Public Network
   +-------------------------------
       |                          
       | eth1 [123.123.123.123/24]
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
       | eth0 [192.168.100.1/24]
       |                          
   +-------------------------------
    Internal/Admin Network

``setuprc``::

   # setuprc - configuration file for deploying OpenStack

   export PASSWORD='1234ABCDefgh'
   export ADMIN_PASSWORD=$PASSWORD
   export SERVICE_PASSWORD=$PASSWORD
   export ENABLE_ENDPOINTS=1
   MYSQL_ADMIN_PASS=$PASSWORD
   MYSQL_PASS=$PASSWORD
   RABBIT_PASS=$PASSWORD
   export CONTROLLER_PUBLIC_ADDRESS="123.123.123.123"
   export CONTROLLER_ADMIN_ADDRESS="192.168.100.1"
   export CONTROLLER_INTERNAL_ADDRESS=$CONTROLLER_ADMIN_ADDRESS
   FIXED_RANGE="192.168.201.0/24"
   MYSQL_ACCESS="192.168.100.%"
   PUBLIC_INTERFACE="eth1"
   INTERNAL_INTERFACE="eth0"
