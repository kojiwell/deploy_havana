.. Simple Deploy OpenStack Havana documentation master file, created by
   sphinx-quickstart on Wed Oct 16 15:15:10 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Enable SSL on Keystone and Horizon
==========================================================

When you enable SSL, the common name is the important thing.
Which should be Hostname + Domain Name like ``hostname.yoursite.org``.
You should be able to reach the host from anywhere with its common name.

The script ``ca_setup.sh`` does the lavor work for you. 
So, login to your management nost and setup ``COMMON_NAME`` on setuprc, 
and execute the script like this. ::

   cd deploy_havana
   echo COMMON_NAME=hostname.yoursite.org >> setuprc
   bash -ex ca_setup.sh

If the bash script finshed fine, you can try the follows.

Try client of Keystone, Nova and Glance
---------------------------------------

Setup your OpenStack environment and try some commands ::

   cd deploy_havana
   source admin_credential
   keystone endpoint-list
   nova list
   glance image-list

Try Horizon with HTTPS
----------------------

Try `<https://hostname.yoursite.org/horizon>`_ .

Update and restart Nova Compute nodes
-------------------------------------

Copy ``/etc/nova/api-paste.ini`` and ``/etc/nova/nova.conf`` to your compute node and restart the service. ::

   scp -p /etc/nova/api-paste.ini compute_node:/etc/nova/api-paste.ini
   ssh compute_node restart nova-compute
   ssh compute_node restart nova-network

Update and restart Cinder Volume nodes
--------------------------------------

