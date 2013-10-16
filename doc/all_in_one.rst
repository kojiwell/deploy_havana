.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Build All-in-One Node
==========================================================

Installation
------------

First, you need to update ``/etc/hosts`` for your environment. If your hostname is not resolvable,
``nova-network`` fails to start.

Switch to ``root`` user, and download the installation scripts.::

   su - root
   git clone https://github.com/kjtanaka/deploy_havana.git
   cd deploy_havana

Create your ``setuprc`` file and modify it for your environment, and execute
``build_all_in_one.sh``. Some examples of ``setuprc`` are given below.::

   cp setuprc_example_[1NIC/2NICs] setuprc
   vi setuprc
   bash -ex build_all_in_one.sh

If everything's went fine, the machine would be rebooted at the end of the script. Examples of ``setuprc`` are given below.

setuprc for 2NICs
-------------

Here's the diagram of a machine with 2 NICs.::

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

The setuprc file becomes like this::

   # setuprc - configuration file for deploying OpenStack

   export PASSWORD='1234ABCDefgh'
   export ADMIN_PASSWORD=$PASSWORD
   export SERVICE_PASSWORD=$PASSWORD
   export ENABLE_ENDPOINTS=1
   MYSQLPASS=$PASSWORD
   RABBIT_PASS=$PASSWORD
   export CONTROLLER_PUBLIC_ADDRESS="123.123.123.123"
   export CONTROLLER_ADMIN_ADDRESS="192.168.100.1"
   export CONTROLLER_INTERNAL_ADDRESS=$CONTROLLER_ADMIN_ADDRESS
   FIXED_RANGE="192.168.201.0/24"
   MYSQL_ACCESS="192.168.100.%"
   PUBLIC_INTERFACE="eth1"
   FLAT_INTERFACE="eth0"

setuprc for 1NIC
------------

Here's the diagram of a machine with 1 NIC.::

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

The setuprc file is like this::

   # setuprc - configuration file for deploying OpenStack

   export PASSWORD='1234abcdEFGH'
   export ADMIN_PASSWORD=$PASSWORD
   export SERVICE_PASSWORD=$PASSWORD
   export ENABLE_ENDPOINTS=1
   MYSQLPASS=$PASSWORD
   RABBIT_PASS=$PASSWORD
   export CONTROLLER_PUBLIC_ADDRESS='123.123.123.123'
   export CONTROLLER_ADMIN_ADDRESS=$CONTROLLER_PUBLIC_ADDRESS
   export CONTROLLER_INTERNAL_ADDRESS=$CONTROLLER_ADMIN_ADDRESS
   FIXED_RANGE="192.168.201.0/24"
   MYSQL_ACCESS="123.123.123.%"
   PUBLIC_INTERFACE="br101"
   FLAT_INTERFACE="eth0"


